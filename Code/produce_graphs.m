% Plot implied probability series for various buckets across tenor

clearvars -except root_dir;

load PROBA usd_imp_inflation_rate 

load DATA bbg_eco_release

term_remap = {'1 Year', '3 Year', '5 Year', '7 Year', '10 Year', ...
    '15 Year', '20 Year', '30 Year'};
term_structure = [1, 3, 5, 7, 10, 15, 20, 30];


%% Plot the probability series for <1% and >3% on continous distributions       

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
    fig = figure('visible', 'off');                         
    set(gcf, 'Position', [100, 100, 1250, 650]);   
    
    first_target = find(ismember(tb.Properties.VariableNames, '1') == 1); 
    second_target = find(ismember(tb.Properties.VariableNames, '3') == 1); 
    
    hold on; 
    h(1, 1) = plot(tb{:, 1}, sum(tb{:, 2:first_target-1}, 2), 'DisplayName', '<1%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, 2:first_target-1}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    h(1, 2) = plot(tb{:, 1}, sum(tb{:, second_target+1:end}, 2), 'DisplayName', '>3%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, second_target+1:end}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    % vertical measurement for date string
    xline(tb{end, 1}, '--k', datestr(tb{end, 1}), 'LineWidth', 1);

    hold off; 
    legend(h, 'location', 'northwest');
    title(strcat("Implied Probability Buckets for ", ...
        strjoin(strsplit(term, '_'), ' '), ' Tenor'));
    ylabel('Inflation Probability');
    
    export_name = strcat('Output/market_implied_probability_buckets/imp_proba_', ...
        term, '_1%3%_bucket.png');
    exportgraphics(fig, export_name)
    
end

%% Plot the probability series for <1.5% and >2.5% on continous distributions       

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
    fig = figure('visible', 'off');                         
    set(gcf, 'Position', [100, 100, 1250, 650]);   
    
    first_target = find(ismember(tb.Properties.VariableNames, '1.5') == 1); 
    second_target = find(ismember(tb.Properties.VariableNames, '2.5') == 1); 
    
    hold on; 
    h(1, 1) = plot(tb{:, 1}, sum(tb{:, 2:first_target-1}, 2), 'DisplayName', '<1.5%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, 2:first_target-1}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    h(1, 2) = plot(tb{:, 1}, sum(tb{:, second_target+1:end}, 2), 'DisplayName', '>2.5%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, second_target+1:end}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    % vertical measurement for date string
    xline(tb{end, 1}, '--k', datestr(tb{end, 1}), 'LineWidth', 1);

    hold off; 
    legend(h, 'location', 'northwest');
    title(strcat("Implied Probability Buckets for ", ...
        strjoin(strsplit(term, '_'), ' '), ' Tenor'));
    ylabel('Inflation Probability');
    
    export_name = strcat('Output/market_implied_probability_buckets/imp_proba_', ...
        term, '_1-5%2-5%_bucket.png');
    exportgraphics(fig, export_name)
    
end

%% Plot the probability series for <0% and >4% on continous distributions       

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
    fig = figure('visible', 'off');                         
    set(gcf, 'Position', [100, 100, 1250, 650]);   
    
    first_target = find(ismember(tb.Properties.VariableNames, '0') == 1); 
    second_target = find(ismember(tb.Properties.VariableNames, '4') == 1); 
    
    hold on; 
    h(1, 1) = plot(tb{:, 1}, sum(tb{:, 2:first_target-1}, 2), 'DisplayName', '<0.0%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, 2:first_target-1}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    h(1, 2) = plot(tb{:, 1}, sum(tb{:, second_target+1:end}, 2), 'DisplayName', '>4.0%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, second_target+1:end}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    % vertical measurement for date string
    xline(tb{end, 1}, '--k', datestr(tb{end, 1}), 'LineWidth', 1);

    hold off; 
    legend(h, 'location', 'northwest');
    title(strcat("Implied Probability Buckets for ", ...
        strjoin(strsplit(term, '_'), ' '), ' Tenor'));
    ylabel('Inflation Probability');
    
    export_name = strcat('Output/market_implied_probability_buckets/imp_proba_', ...
        term, '_0%4%_bucket.png');
    exportgraphics(fig, export_name)
    
end

%% Plot the probability series for <0.5% and >3.5% on continous distributions       

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
    fig = figure('visible', 'off');                         
    set(gcf, 'Position', [100, 100, 1250, 650]);   
    
    first_target = find(ismember(tb.Properties.VariableNames, '0.5') == 1); 
    second_target = find(ismember(tb.Properties.VariableNames, '3.5') == 1); 
    
    hold on; 
    h(1, 1) = plot(tb{:, 1}, sum(tb{:, 2:first_target-1}, 2), 'DisplayName', '<0.5%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, 2:first_target-1}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    h(1, 2) = plot(tb{:, 1}, sum(tb{:, second_target+1:end}, 2), 'DisplayName', '>3.5%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, second_target+1:end}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    % vertical measurement for date string
    xline(tb{end, 1}, '--k', datestr(tb{end, 1}), 'LineWidth', 1);

    hold off; 
    legend(h, 'location', 'northwest');
    title(strcat("Implied Probability Buckets for ", ...
        strjoin(strsplit(term, '_'), ' '), ' Tenor'));
    ylabel('Inflation Probability');
    
    export_name = strcat('Output/market_implied_probability_buckets/imp_proba_', ...
        term, '_0-5%3-5%_bucket.png');
    exportgraphics(fig, export_name)
    
end

%% Plot the probability series for >2.0% and >2.5% on continous distributions       

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
    fig = figure('visible', 'off');                         
    set(gcf, 'Position', [100, 100, 1250, 650]);   
    
    first_target = find(ismember(tb.Properties.VariableNames, '2') == 1); 
    second_target = find(ismember(tb.Properties.VariableNames, '2.5') == 1); 
    
    hold on; 
    h(1, 1) = plot(tb{:, 1}, sum(tb{:, first_target+1:end}, 2), 'DisplayName', '>2.0%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, first_target+1:end}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    h(1, 2) = plot(tb{:, 1}, sum(tb{:, second_target+1:end}, 2), 'DisplayName', '>2.5%', ...
        'LineWidth', 1.5);
    y = sum(tb{:, second_target+1:end}, 2); 
    text(tb{end, 1}, y(end), strcat(" (", num2str(round(y(end), 2)),")%"), ...
        'FontSize', 9, 'FontWeight', 'bold');
    
    % vertical measurement for date string
    xline(tb{end, 1}, '--k', datestr(tb{end, 1}), 'LineWidth', 1);

    hold off; 
    legend(h, 'location', 'northwest');
    title(strcat("Implied Probability Buckets for ", ...
        strjoin(strsplit(term, '_'), ' '), ' Tenor'));
    ylabel('Inflation Probability');
    
    export_name = strcat('Output/market_implied_probability_buckets/imp_proba_', ...
        term, '_2%2-5%_bucket.png');
    exportgraphics(fig, export_name)
    
end

%% Plot the implied inflation rate against realized U.S. CPI MoM rate 

% plot each corresponding series
fig = figure('visible', 'off');                         
set(fig, 'Position', [100, 100, 1150, 750]); 

hold on; 

% plot each implied inflation rate per year
a1 = plot(usd_imp_inflation_rate{:, 1}, usd_imp_inflation_rate{:, 2}, 'LineWidth', ...
    1.5, 'DisplayName', 'Inflation Expectations (1y)');
a2 = plot(usd_imp_inflation_rate{:, 1}, usd_imp_inflation_rate{:, 4}, 'LineWidth', ...
    1.5, 'DisplayName', 'Inflation Expectations (5y)');
a3 = plot(usd_imp_inflation_rate{:, 1}, usd_imp_inflation_rate{:, 6}, 'LineWidth', ...
    1.5, 'DisplayName', 'Inflation Expectations (10y)');
a4 = plot(usd_imp_inflation_rate{:, 1}, usd_imp_inflation_rate{:, 7}, 'LineWidth', ...
    1.5, 'DisplayName', 'Inflation Expectations (15y)');
a5 = plot(usd_imp_inflation_rate{:, 1}, usd_imp_inflation_rate{:, 9}, 'LineWidth', ...
    1.5, 'DisplayName', 'Inflation Expectations (30y)');

ylabel('Implied Neutral Inflation Rate \pi^Q'); 
legend([a1, a2, a3, a4, a5], 'Location', 'south');

export_name = strcat('Output/Realized_CPI_vs_Expectations.png');
exportgraphics(fig, export_name);

%% Plot the inflation forecast for 1y against realized U.S. CPI MoM rate 

cols = {'US CPI Urban Consumers MoM SA'};

% shifted_forecat probability
usd_imp_inflation_rate{:, 'Date'} = usd_imp_inflation_rate{:, 'Date'} + 365;

% compute pivot table with surprise z-score
beta1 = bbg_eco_release(ismember(bbg_eco_release.NAME, cols), :);
beta1 = pivotTable(beta1, 'ACTUAL_RELEASE', 'RELEASE_DATE', 'NAME');

% restrict the sample size for both forecasts and realized to match
beta1 = beta1(ismember(beta1{:, 1}, usd_imp_inflation_rate{:, 1}), :);
usd_imp_inflation_rate = usd_imp_inflation_rate(usd_imp_inflation_rate{:, 1} ....
    <= beta1{end, 1}, :);

% compute accuracy statistics of forecast
x1 = usd_imp_inflation_rate(ismember(usd_imp_inflation_rate{:, 1}, beta1{:, 1}), :);
rmse = sqrt(mean((x1{:, 2}-beta1{:, 2}).^2));                                         % Root-mean-square deviation
mape = (beta1{:, 2} - x1{:, 2}) ./ beta1{:, 2};                                       % Mean absolute percentage error 
mape = mean(mape(isfinite(mape)));
correlation = corr(x1{:, 2}, beta1{:, 2});                                            % Pearson-Correlation

% record prediciton accuracy statistics
comment = {strcat("RMSE: ", num2str(round(rmse, 3))), ...
    strcat("MAPE: ", num2str(100*round(mape, 3)), '%'), ...
    strcat("CORR: ", num2str(round(correlation, 3)))};

% plot each corresponding series
fig = figure('visible', 'off');                         
set(fig, 'Position', [100, 100, 1150, 750]); 
hold on; 

% plot each implied inflation rate per year
a1 = plot(usd_imp_inflation_rate{:, 1}, usd_imp_inflation_rate{:, 2}, 'LineWidth', ...
    1.5, 'DisplayName', 'Implied Inflation Forecast (1y)');

% plot the realized CPI data from Bloomberg annoucements
a6 = scatter(beta1{:, 1}, beta1{:, 2}, 'MarkerFaceColor', 'black', 'DisplayName', ...
    'Realized CPI YoY');

annotation('textbox', [.2 0 .3 .3], 'String', comment, 'FitBoxToText', 'on');
ylabel('Implied Neutral Inflation Rate Forecast \pi^Q'); 
legend([a1, a6], 'Location', 'south');

export_name = strcat('Output/Realized_CPI_vs_Forecasts.png');
exportgraphics(fig, export_name);

%% Produce regression graphs for a particular macro-economic annoucement

event = 'US CPI Urban Consumers MoM SA';

inflation_coefs = zeros(8,6);           % dimensions 8 tenors, 6 exogenous variables
inflation_col = [3, 5, 6, 7, 8, 10];    % <0.5%, <1.5%, <2.0%, 2.0%>, 2.5%>, 3.5%>
idx = 1; 

% iterate through each year 
for y = {'1y', '3y', '5y', '7y', '10y', '15y', '20y', '30y'}

    name = strcat('Output/regressions/usd_inflation_proba_', y, '_regression_bbg.csv');
    
    % read the corresponding table for a particular regression
    tb = readtable(name{:}, 'PreserveVariableNames', true);
    
    % retrieve inflation regression coefs for the following levels
    inflation = tb{strcmp(tb.Var, event), inflation_col};
    
    % develop matrix for tenor graph
    inflation_coefs(idx, :) = inflation;  
    idx = idx + 1;
    
end

% plot each corresponding series
fig = figure('visible', 'off');                         
set(gcf, 'Position', [100, 100, 1050, 750]); 

% plot corresponding graphs for each inflation bucket
hold on; 
plot(1:8, inflation_coefs, 'Marker', 'o', 'LineWidth', 1.5)
ylabel('Coefficent'); 
xticks(1:8)
xticklabels({'1y', '3y', '5y', '7y', '10y', '15y', '20y', '30y'})
xlabel('Tenors'); 
title(event);
legend(tb.Properties.VariableNames(inflation_col), 'Location', 'southeast') 

export_name = strcat('Output/US_CPI_MoM_Tenor_Coefs.png');
exportgraphics(fig, export_name)

fprintf('7. All plots have been created.\n\n');
