% Compute the implied probability distributions from inflation option data

clearvars -except root_dir;

load DATA annual_cpi monthly_cpi ust_rates tips_rates bbg_eco_release

load SWAPS usd_inf_swaps


%% Initialize terms and strikes for caps and floors

caps_strikes_map = [1.00, 1.50, 2.00, 2.50, 3.00, 3.50, 4.00, 4.50, 5.00, 6.00];
caps_strikes_remap = {'1.00%', '1.50%', '2.00%', '2.50%', '3.00%', '3.50%', ...
                      '4.00%', '4.50%', '5.00%', '6.00%'};

floors_strikes_map = [-3.00, -2.00, -1.00, -0.50, 0.00, 0.50, 1.00, ...
    1.50, 2.00, 3.00];
floors_strikes_remap = {'-3.00%', '-2.00%', '-1.00%', '-0.50%', '0.00%', ...
                       '0.50%', '1.00%', '1.50%', '2.00%', '3.00%'};

term_remap = {'1y', '3y', '5y', '7y', '10y', '15y', '20y', '30y'};
term_map = {'01', '03', '05', '07', '10', '15', '20', '30'};

term_structure = [1, 3, 5, 7, 10, 15, 20, 30];

%% Read in filtered zero-coupon option data and perform cleaning operations

% data is stored for each Term and Strike, in the order of Bid, Ask, Last Price
zc_caps = readtable(strcat(root_dir, '/Temp/options/usd-zc-inflation-caps.csv'), ...
    'PreserveVariableNames', true);

zc_floors = readtable(strcat(root_dir, '/Temp/options/usd-zc-inflation-floors.csv'), ...
    'PreserveVariableNames', true);

%% Convexity arbitrage check, remove dates that violate no-arbitrage theory

% iterate through each term (year) and filter out convexity violations
for i = 1:length(term_structure)
    
    term = term_remap(i);
    
    % ----------------------------------------
    % Convexity check for inflation caps
    % ----------------------------------------
    itm_strike = strcat(term, "_1.00% Last Price");
    otm_strike = strcat(term, "_6.00% Last Price");
    
    % the price of this spread should always be positive, since ITM options
    % should always be priced higher than OTM due to convexity arbitrage 
    cap_check = zc_caps{:, itm_strike} - zc_caps{:, otm_strike}; 
    
    % for each loop of year, we filter the corresponding series
    zc_caps = zc_caps(~(cap_check < 0), :);
    
    % ----------------------------------------
    % Convexity check for inflation floor
    % ----------------------------------------
    itm_strike = strcat(term, "_3.00% Last Price");
    otm_strike = strcat(term, "_-3.00% Last Price");
    
    % the price of this spread should always be positive, since ITM options
    % should always be priced higher than OTM due to convexity arbitrage 
    floor_check = zc_floors{:, itm_strike} - zc_floors{:, otm_strike}; 
    
    % for each loop of year, we filter the corresponding series
    zc_floors = zc_floors(~(floor_check < 0), :);
    
end

% filter the corresponding Treasury Rates from Gurkaynak, Sack and Wright (2007)
% find intersection of all dates to have one vector to filter
d1 = intersect(zc_caps{:, 'Start Date'}, zc_floors{:, 'Start Date'});
d2 = intersect(ust_rates{:, 'Date'}, d1);

% map new date to all price series
zc_caps = zc_caps(ismember(zc_caps{:, 'Start Date'}, d2),:);
zc_floors = zc_floors(ismember(zc_floors{:, 'Start Date'}, d2),:);
ust_rates = ust_rates(ismember(ust_rates{:, 'Date'}, d2),:);
tips_rates = tips_rates(ismember(tips_rates{:, 'Date'}, d2),:);

%% Compute the implied probability distributions (integer-butterflies)

inflation_strikes = {'-3.00%', '-2.00%', '-1.00%', '0.00%', '1.00%', '2.00%', ...
    '3.00%', '4.00%', '5.00%', '6.00%'};

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
        top_strike = strcat(term, "_", inflation_strikes(strike+1), " Last Price");
        mid_strike = strcat(term, "_", inflation_strikes(strike), " Last Price");
        bot_strike = strcat(term, "_", inflation_strikes(strike-1), " Last Price");
        
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
    left_strike1 = strcat(term, "_", "-3.00% Last Price");
    left_strike2 = strcat(term, "_", "-2.00% Last Price");
    
    right_strike1 = strcat(term, "_", "6.00% Last Price");
    right_strike2 = strcat(term, "_", "5.00% Last Price");
    
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
    implied_proba_tb = movevars(implied_proba_tb, 'Date', 'Before', '-3.00%'); 
    
    % exporting data table for implied probability
    name = strcat('Output/market_implied_probability/imp_proba_', term, '_int_fly.csv');
    writetable(implied_proba_tb, name{:});
    
end

fprintf('Implied probabilites have been constructured from integer-butterflies.\n');

%% Compute implied probability distribution spline and volatility smile (SLOW)
% currently having errors with pricing, we will work on this later but 
% currently we comment out the code to be worked on later

for idx1 = 1:length(term_remap)
    
    year_name = term_remap(idx1);
    year_str = term_map(idx1); 
    
    % reading in the implied probability distribution from the  butterflies
    name = strcat('Output/market_implied_probability/imp_proba_', year_name{:}, ...
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
        
%         % ----------------------------------------
%         % Volatility Smile Graph (Caps vs Floors) 
%         % ----------------------------------------
%         
%         if ismember(year_str, {'03', '05', '07', '10', '15', '20'})
%         
%             % store prices for caps and floors, determine prices series for
%             % each corresponding year (e.g. 1y, -3.00% to 6.00%)
%             cap_names = cellfun(@(i) strcat(year_name, "_", i, " Last Price"), ...
%                 caps_strikes_remap);
%             floor_names = cellfun(@(i) strcat(year_name, "_", i, " Last Price"), ...
%                 floors_strikes_remap);
% 
%             % retrieve the correct cap and floor series corresponding to
%             % implied probability measures computed from butterflies
%             caps = zc_caps{idx2, cap_names};
%             floors = zc_floors{idx2, floor_names};
% 
%             % retrieve information relevant to cap/floor prices 
%             rN = ust_rates{idx2, strcat('SVENY', year_str)};                          % nominal rate (UST)
%             rR = tips_rates{idx2, strcat('TIPSY', year_str)};                          % real rate (TIPS)
% 
%             current_date = tb{idx2, 1};         % current date for option price
%             mm = month(current_date);           % current month
%             yy = year(current_date);            % current year
% 
%             % CPI inflation index corresponding to current/prior year and prior
%             % month, in order to avoid lookahead bias
%             inflation = monthly_cpi{ismember(monthly_cpi.YEAR, yy) & ...
%                 ismember(monthly_cpi.MONTH, mm-1), 'CPALTT01USM657N'};
% 
%             % compute the volatility smile from the cap prices
%             %   V: we scale the cap prices by 10000, since their priced in bps
%             %   K: we scale the inflation strikes by 100 to reduce to pct terms
%             vol_cap_smile = arrayfun(@(V, K) newton_raphson_iv(V/10000, rR/100, ...
%                 rN/100, K/100, inflation/100, inflation/100, str2double(year_str), 1),   ...
%                 caps, caps_strikes_map);  
%             vol_floor_smile = arrayfun(@(V, K) newton_raphson_iv(V/10000, rR/100, ...
%                 rN/100, K/100, inflation/100, inflation/100, str2double(year_str), 0),   ...
%                 floors, floors_strikes_map);  
%             
%             % condition ensures all prices re-derive an implied volatility 
%             if sum(isnan(vol_cap_smile)) == 0
%                
%                 % interpolate the implied volatility over strike range
%                 interpolation = spline(caps_strikes_map, vol_cap_smile, ...
%                     cap_vol_interpolation);
% 
%                 % map the corresponding interpolated volatility 
%                 cap_smile(idx2, :) = interpolation;
% 
%             end
%             
%             % condition ensures all prices re-derive an implied volatility 
%             if sum(isnan(vol_floor_smile)) == 0
%                
%                 % interpolate the implied volatility over strike range
%                 interpolation = spline(floors_strikes_map, vol_floor_smile, ...
%                     floor_vol_interpolation);
% 
%                 % map the corresponding interpolated volatility 
%                 floor_smile(idx2, :) = interpolation;
% 
%             end
%             
%         end 
        
    end
    
    % ----------------------------------------
    % Table Exportation for Figures
    % ----------------------------------------
    
    proba_spline_tb = array2table(proba_spline);
    proba_spline_tb.Properties.VariableNames = strsplit(num2str(strike_interpolation));
    proba_spline_tb.Date = tb{:, 'Date'}; 
    proba_spline_tb = movevars(proba_spline_tb, 'Date', 'Before', '-3'); 
    
%     % construct the volatility smiles for caps & floors
%     cap_smile_tb = array2table(cap_smile);
%     cap_smile_tb.Properties.VariableNames = strsplit(num2str(cap_vol_interpolation));
%     cap_smile_tb.Date = tb{:, 'Date'}; 
%     cap_smile_tb = movevars(cap_smile_tb, 'Date', 'Before', '1'); 
%     
%     floor_smile_tb = array2table(floor_smile);
%     floor_smile_tb.Properties.VariableNames = strsplit(num2str(floor_vol_interpolation));
%     floor_smile_tb.Date = tb{:, 'Date'}; 
%     floor_smile_tb = movevars(floor_smile_tb, 'Date', 'Before', '-3'); 
    
    export_name1 = strcat('Output/market_implied_probability/imp_proba_', ...
        year_name, '_spline.csv');
%     export_name2 = strcat('Output/market_implied_probability/imp_proba_', ...
%         year_name, '_cap_smile.csv');
%     export_name3 = strcat('Output/market_implied_probability/imp_proba_', ...
%         year_name, '_floor_smile.csv');
    
    writetable(proba_spline_tb, export_name1{:});
%     writetable(cap_smile_tb, export_name2{:});
%     writetable(floor_smile_tb, export_name3{:});
     
end

fprintf('Finished computing spline probabilities and volatility smiles.\n');

%% Construct .mat file for each corresponding inflation probability bucket 

% iterate through each term (year) and build implied pdf
for i = 1:length(term_structure) 
    
    term = term_remap(i);
    
    % reading in the implied probability distribution
    name = strcat('Output/market_implied_probability/imp_proba_', ...
        term, '_spline.csv');
    tb = readtable(name{:}, 'ReadVariableNames', true, ...
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
    S.(export_name{:}) = export_tb;
    save('Temp/PROBA.mat', '-struct', 'S') 
    
end

fprintf('All inflation bucket probabilities are calculated.\n');

%% Compute each implied netural inflation rate for each corresponding year 

% initialize the USD inflation rate matrix (DO NOT HARDCODE SIZE CHANGE TO BE MORE DYNAMIC FOR FUTURE USE) 
usd_imp_inflation_rate = zeros(1969, 8); %

% iterate through each term (year) and build implied pdf
for i = 1:length(term_structure) 
    
    term = term_remap(i);

    % reading in the implied probability distribution
    name = strcat('Output/market_implied_probability/imp_proba_', term, ...
        '_spline.csv');
    tb = readtable(name{:}, 'ReadVariableNames', true, ...
        'PreserveVariableNames', true);
    
    % create the cummulative distribution for each date, determine mid
    cum_dist = cumsum(tb{:, 2:end}, 2);
    mid_diff = abs(cum_dist - 50);
    
    % iterate through each row to find absolute minimum of mid difference
    for r = 1:1921

        [~, I] = min(mid_diff(r, :));
        usd_imp_inflation_rate(r, i) = str2double(tb.Properties.VariableNames(I+1));

    end

end

% convert matrix to a table and add datatime vector (organizing datatable)
usd_imp_inflation_rate = array2table(usd_imp_inflation_rate);
usd_imp_inflation_rate.Properties.VariableNames = term_remap;
usd_imp_inflation_rate.Date = tb{:, 1}; 
usd_imp_inflation_rate = movevars(usd_imp_inflation_rate, 'Date', 'Before', '1y'); 

save('Temp/PROBA.mat', 'usd_imp_inflation_rate', '-append') 
