% Compute the implied probability distributions from inflation option data

clearvars -except root_dir;

load DATA annual_cpi monthly_cpi ust_rates tips_rates bbg_eco_release ...

load SWAPS usd_inf_swaps

load OPTIONS usd_inflation_zc_caps usd_inflation_zc_floors

%% Initialize terms and strikes for caps and floors

caps_strikes_map = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 6.0];
caps_strikes_remap = {'1.0%', '1.5%', '2.0%', '2.5%', '3.0%', '3.5%', ...
                      '4.0%', '4.5%', '5.0%', '6.0%'};

floors_strikes_map = [-3.0, -2.0, -1.0, -0.5, 0.0, 0.5, 1.0, ...
    1.5, 2.0, 3.0];
floors_strikes_remap = {'-3.0%', '-2.0%', '-1.0%', '-0.5%', '0.0%', ...
                       '0.5%', '1.0%', '1.5%', '2.0%', '3.0%'};

term_remap = {'1 Year', '3 Year', '5 Year', '7 Year', '10 Year', ...
    '15 Year', '20 Year', '30 Year'};
term_map = {'01', '03', '05', '07', '10', '15', '20', '30'};

term_structure = [1, 3, 5, 7, 10, 15, 20, 30];

zc_caps = usd_inflation_zc_caps;
zc_floors = usd_inflation_zc_floors;

%% Convexity arbitrage check, remove dates that violate no-arbitrage theory

% iterate through each term (year) and filter out convexity violations
for i = 1:length(term_structure)
    
    term = term_remap(i);
    
    % ----------------------------------------
    % Convexity check for inflation caps
    % ----------------------------------------
    itm_strike = strcat("1.0% ", term);
    otm_strike = strcat("6.0% ", term);
    
    % the price of this spread should always be positive, since ITM options
    % should always be priced higher than OTM due to convexity arbitrage 
    cap_check = zc_caps{:, itm_strike} - zc_caps{:, otm_strike}; 
    
    % for each loop of year, we filter the corresponding series
    zc_caps = zc_caps(~(cap_check < 0), :);
    
    % ----------------------------------------
    % Convexity check for inflation floor
    % ----------------------------------------
    itm_strike = strcat("3.0% ", term);
    otm_strike = strcat("-3.0% ", term);
    
    % the price of this spread should always be positive, since ITM options
    % should always be priced higher than OTM due to convexity arbitrage 
    floor_check = zc_floors{:, itm_strike} - zc_floors{:, otm_strike}; 
    
    % for each loop of year, we filter the corresponding series
    zc_floors = zc_floors(~(floor_check < 0), :);
    
end

% filter the corresponding Treasury Rates from Gurkaynak, Sack and Wright (2007)
% find intersection of all dates to have one vector to filter
d1 = intersect(zc_caps{:, 'Dates'}, zc_floors{:, 'Dates'});
d2 = intersect(ust_rates{:, 'Date'}, d1);

% map new date to all price series
zc_caps = zc_caps(ismember(zc_caps{:, 'Dates'}, d2),:);
zc_floors = zc_floors(ismember(zc_floors{:, 'Dates'}, d2),:);
ust_rates = ust_rates(ismember(ust_rates{:, 'Date'}, d2),:);
tips_rates = tips_rates(ismember(tips_rates{:, 'Date'}, d2),:);

%% Compute the implied probability distributions (integer-butterflies)

inflation_strikes = {'-3.0%', '-2.0%', '-1.0%', '0.0%', '1.0%', '2.0%', ...
    '3.0%', '4.0%', '5.0%', '6.0%'};

cap_names = zc_caps.Properties.VariableNames;
floor_names = zc_floors.Properties.VariableNames;

% check flags for presence of cap and floor butterflies
cap_flag = 0;
floor_flag = 0;

% iterate through each term (year) and build implied pdf
for i = 1:length(term_structure)
    
    term = term_remap(i);
    N = length(inflation_strikes);
    
    % determine discounting factor from GSW Treasury (risk-free)
    r = ust_rates{:, i+1};
    n = term_structure(i);
    discount = exp(r*n);
    
    % initialize implied probability density function
    implied_proba = zeros(size(ust_rates, 1), N);
    
    % ----------------------------------------
    % BUTTERFLY SPREADS (center mass)
    % ----------------------------------------
    for strike = 2:N-1
        
        % determine column names for all strikes used in butterfly
        top_strike = strcat(inflation_strikes(strike+1), " ", term);
        mid_strike = strcat(inflation_strikes(strike), " ", term); 
        bot_strike = strcat(inflation_strikes(strike-1), " ", term);
        
        % we check to see whether we should make the spread of caps, floors
        % or if we should the average of both (caps + floors) / 2
        if ismember(top_strike, cap_names) && ismember(mid_strike, cap_names) ...
                && ismember(bot_strike, cap_names)
            
            % we compute the butterfly spread using zero-coupon inflation caps
            cap_butterfly = zc_caps{:, top_strike} - 2 * zc_caps{:, mid_strike} + ...
                zc_caps{:, bot_strike};
            cap_flag = 1;
        end
        
        if ismember(top_strike, floor_names) && ismember(mid_strike, floor_names) ...
                && ismember(bot_strike, floor_names)
            
            % we compute the butterfly spread using zero-coupon inflation caps
            floor_butterfly = zc_floors{:, top_strike} - 2 * zc_floors{:, mid_strike}  ...
                + zc_floors{:, bot_strike};
            floor_flag = 1;
        end
        
        % check to see whether we should compute the average for the spread
        if cap_flag == 1 && floor_flag == 1 
           butterfly_spread = ((cap_butterfly + floor_butterfly) / 2) .* discount;
        elseif cap_flag == 1 && floor_flag == 0 
           butterfly_spread = cap_butterfly .* discount;
        elseif cap_flag == 0 && floor_flag == 1 
           butterfly_spread = floor_butterfly .* discount; 
        end
        
        % map correct implied probability measure for each butterfly_spread
        implied_proba(:, strike) = butterfly_spread;
        
        % reset flag for caps and floor butterflies
        cap_flag = 0;
        floor_flag = 0; 
        
    end
    
    % ----------------------------------------
    % VERTICAL SPREADS (tail measures)
    % ----------------------------------------
    
    % determine column names for all strikes used in vertical
    left_strike1 = strcat("-3.0% ", term);
    left_strike2 = strcat("-2.0% ", term);
    
    right_strike1 = strcat("6.0% ", term);
    right_strike2 = strcat("5.0% ", term);
    
    % compute the left vertical spread to measure the tail probability 
    implied_proba(:, 1) = zc_floors{:, left_strike2} - zc_floors{:, left_strike1};
    implied_proba(:, N) = zc_caps{:, right_strike2} - zc_caps{:, right_strike1};
    
    % scaling each row by the sum of each row
    scaler_v = sum(implied_proba, 2);
    scaled_proba = implied_proba ./ scaler_v;   % each row sums to 1 now
    
    % organzing table columns for implied probability distributions
    implied_proba_tb = array2table(scaled_proba);
    implied_proba_tb.Properties.VariableNames = inflation_strikes;
    implied_proba_tb.Date = zc_caps{:, 1}; 
    implied_proba_tb = movevars(implied_proba_tb, 'Date', 'Before', '-3.0%'); 
    
    % exporting data table for implied probability
    name = strcat('Output/market_implied_probability/imp_proba_', ...
        strjoin(strsplit(term{:}), '_'), '_int_fly.csv');
    writetable(implied_proba_tb, name);
    
end

fprintf('Implied probabilites have been constructured from integer-butterflies.\n');

%% Compute implied probability distribution spline

for idx1 = 1:length(term_remap)
    
    year_name = term_remap(idx1);
    year_id = strsplit(year_name{:});
    year_name = strjoin(strsplit(year_name{:}), '_');
    
    year_str = term_map(idx1); 
    
    % reading in the implied probability distribution from the  butterflies
    name = strcat('Output/market_implied_probability/imp_proba_', year_name, ...
        '_int_fly.csv');
    tb = readtable(name, 'PreserveVariableNames', true);
    N = size(tb, 1);

    x_strikes = [-3, -2, -1, 0, 1, 2, 3, 4, 5, 6];  % all butterfly strikes 
    strike_interpolation = -3:0.01:6;               % interpolation region for
    cap_vol_interpolation = 1:0.01:6;               %   all series examined
    floor_vol_interpolation = -3:0.01:3; 
      
    % initialize array for memory allocation of splines
    proba_spline = zeros(N, length(strike_interpolation));
    cap_smile = zeros(N, length(cap_vol_interpolation));
    floor_smile = zeros(N, length(floor_vol_interpolation));
    
    for idx2 = 1:N
        
        % ----------------------------------------
        % Implied Probability Distribution
        % ----------------------------------------
        
        % compute the cubic spline for implied probability distributions
        imp_proba = tb{idx2, 2:end};
        interpolation = spline(x_strikes, imp_proba, strike_interpolation);
        
        % map corresponding row to spline array
        proba_spline(idx2, :) = interpolation;
        
    end
    
    % ----------------------------------------
    % Table Exportation for Figures
    % ----------------------------------------
    
    % determine actual year for identification purpose
    year_id = year_id(1);
    old_filename = strcat('Output/market_implied_probability/BFIL_FITS/imp_proba_', ...
        year_id{:}, 'y_spline_old.csv');
    
    % old data with longer historical data taken from Bloomberg BFIL
    old_proba_spline_tb = readtable(old_filename, 'ReadVariableNames', true, ...
        'PreserveVariableNames', true);
    
    % new data constructured from Bloomberg BFIM
    new_proba_spline_tb = array2table(proba_spline);
    new_proba_spline_tb.Properties.VariableNames = strsplit(num2str(strike_interpolation));
    new_proba_spline_tb.Date = tb{:, 'Date'}; 
    new_proba_spline_tb = movevars(new_proba_spline_tb, 'Date', 'Before', '-3'); 
    
    % merge both tables vertically along their shared axis 
    proba_spline_tb = outerjoin(old_proba_spline_tb, new_proba_spline_tb, 'Keys', ...
        [{'Date'}, intersect(old_proba_spline_tb.Properties.VariableNames, ...
        new_proba_spline_tb.Properties.VariableNames)], 'MergeKeys', true); 
    
    % return only the unique items in probability spline (first case rule)
    [~, idx] = unique(proba_spline_tb.Date);
    proba_spline_tb = proba_spline_tb(idx, :);
 
    
    export_name = strcat('Output/market_implied_probability/imp_proba_', ...
        year_name, '_spline.csv');
    writetable(proba_spline_tb, export_name);
  
end

fprintf('Finished computing spline probabilities and volatility smiles.\n');

%% Construct .mat file for each corresponding inflation probability bucket 

% iterate through each term (year) and build implied pdf
for i = 1:length(term_structure) 
    
    term = term_remap(i);
    term = strjoin(strsplit(term{:}), '_');
    
    % reading in the implied probability distribution
    name = strcat('Output/market_implied_probability/imp_proba_', ...
        term, '_spline.csv');
    tb = readtable(name, 'ReadVariableNames', true, ...
        'PreserveVariableNames', true);
    
    % plot each corresponding series
    target_0 = find(ismember(tb.Properties.VariableNames, '0') == 1); 
    target_0_5 = find(ismember(tb.Properties.VariableNames, '0.5') == 1);
    target_1 = find(ismember(tb.Properties.VariableNames, '1') == 1); 
    target_1_5 = find(ismember(tb.Properties.VariableNames, '1.5') == 1); 
    target_2 = find(ismember(tb.Properties.VariableNames, '2') == 1); 
    target_2_5 = find(ismember(tb.Properties.VariableNames, '2.5') == 1); 
    target_3 = find(ismember(tb.Properties.VariableNames, '3') == 1); 
    target_3_5 = find(ismember(tb.Properties.VariableNames, '3.5') == 1); 
    target_4 = find(ismember(tb.Properties.VariableNames, '4') == 1); 
     
    % construct matrix with each corresponding bucket
    mat = [sum(tb{:, 2:target_0-1}, 2), sum(tb{:, 2:target_0_5-1}, 2), ...
        sum(tb{:, 2:target_1-1}, 2), sum(tb{:, 2:target_1_5-1}, 2), ...
        sum(tb{:, 2:target_2-1}, 2),  sum(tb{:, target_2+1:end}, 2), ...
        sum(tb{:, target_2_5+1:end}, 2), sum(tb{:, target_3+1:end}, 2), ...
        sum(tb{:, target_3_5+1:end}, 2), sum(tb{:, target_4+1:end}, 2)];
    
    % convert matrix to a table
    export_tb = array2table(mat, 'VariableNames', {'<0.0%', '<0.5%', '<1.0%', ...
        '<1.5%', '<2.0%', '2.0%>', '2.5%>', '3.0%>', '3.5%>', '4.0%>'});
    export_tb.Date = tb{:, 1}; 
    export_tb = movevars(export_tb, 'Date', 'Before', '<0.0%'); 

    export_name = strcat('usd_imp_proba_bucket_', term);
    S.(export_name) = export_tb;
    save('Temp/PROBA.mat', '-struct', 'S') 
    
end

fprintf('All inflation bucket probabilities are calculated.\n');

%% Compute each implied netural inflation rate for each corresponding year 

% initialize the USD inflation rate matrix 
tb = readtable('Output/market_implied_probability/imp_proba_1_Year_spline.csv', ...
    'ReadVariableNames', true, 'PreserveVariableNames', true);
usd_imp_inflation_rate = zeros(size(tb, 1), 8); 

% iterate through each term (year) and build implied pdf
for i = 1:length(term_structure) 
    
    term = term_remap(i);
    term = strjoin(strsplit(term{:}), '_');

    % reading in the implied probability distribution
    name = strcat('Output/market_implied_probability/imp_proba_', ...
        term, '_spline.csv');
    tb = readtable(name, 'ReadVariableNames', true, ...
        'PreserveVariableNames', true);
    
    % create the cummulative distribution for each date, determine mid
    cum_dist = cumsum(tb{:, 2:end}, 2);
    mid_diff = abs(cum_dist - 50);
    
    % iterate through each row to find absolute minimum of mid difference
    for r = 1:size(mid_diff, 1)

        [~, I] = min(mid_diff(r, :));
        usd_imp_inflation_rate(r, i) = str2double(tb.Properties.VariableNames(I+1));

    end

end

% convert matrix to a table and add datatime vector (organizing datatable)
usd_imp_inflation_rate = array2table(usd_imp_inflation_rate);
usd_imp_inflation_rate.Properties.VariableNames = term_remap;
usd_imp_inflation_rate.Date = tb{:, 1}; 
usd_imp_inflation_rate = movevars(usd_imp_inflation_rate, 'Date', 'Before', '1 Year'); 

save('Temp/PROBA.mat', 'usd_imp_inflation_rate', '-append') 

fprintf('Risk netural inflation probabilites are done.\n');