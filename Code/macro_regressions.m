% Perform cummulative return analysis for inflation basis against macroeconomic 
% variables, in addition to regressions against surprises 

clearvars -except root_dir;

load DATA basis_tb ust_rates tips_rates sp500 vix bbg_eco_release swanson_2019 ...
    nakamura_steinsson_2018

load PROBA usd_imp_proba_bucket_1_Year usd_imp_proba_bucket_3_Year usd_imp_proba_bucket_5_Year ...
    usd_imp_proba_bucket_7_Year usd_imp_proba_bucket_10_Year usd_imp_proba_bucket_15_Year ...
    usd_imp_proba_bucket_20_Year usd_imp_proba_bucket_30_Year usd_imp_inflation_rate


%% Measuring the aggregate impact of macro-annoucements on 10-y inflation basis

% iterate through each of the macro-annoucements, produce graphs
for event = unique(bbg_eco_release.NAME)'
 
    % filter the corresponding economic annoucments and retrieve the name
    macro_event = bbg_eco_release(ismember(bbg_eco_release.NAME, event), :);
    macro_name = macro_event{1, 'NAME'};
    
    % annoucement date for economic measurements
    % NOTE: This should always be the first column of the economic table
    annoucements = macro_event{:, 1};

    % find the intersection between date ranges for pre-post annoucement
    target_dates = find(ismember(basis_tb.Date, annoucements));
    
    % check to see whether target dates has an index of 1, if so we simply
    % move up the index by 1 (helps avoid differning error)
    if sum(target_dates == 1) > 0
        target_dates = target_dates(2:end, :);
    end
    
    other_dates = find(~ismember(basis_tb.Date, annoucements));

    % target date windows for pre-post announcement 
    post_annouce = basis_tb(target_dates, 'BASIS10Y');
    pre_annouce = basis_tb(target_dates-1, 'BASIS10Y');

    % all other macro dates (we avoid first row to compute change)
    post_other = basis_tb(other_dates(2:end), 'BASIS10Y');
    pre_other = basis_tb(other_dates(2:end)-1, 'BASIS10Y');

    % compute the change across tthe basis both abolsolute and raw differences
    % (we standardize by dividing each change by the length of the data set) 
    abs_anc_calc = abs(post_annouce{:, :} - pre_annouce{:, :}) ./ size(post_annouce, 1);
    abs_other_calc = abs(post_other{:, :} - pre_other{:, :}) ./ size(post_other, 1);

    raw_anc_calc = (post_annouce{:, :} - pre_annouce{:, :}) ./ size(post_annouce, 1);
    raw_other_calc = (post_other{:, :} - pre_other{:, :}) ./ size(post_other, 1);

    % -----------------------------------------------------------------------
    % Graph Each representation
    % -----------------------------------------------------------------------
    fig = figure('visible', 'off');                 % prevent display 
    set(gcf, 'Position', [100, 100, 1250, 650]);    % setting figure dims

    subplot(1, 2, 1); hold on; 
    title({'Response of Inflation Basis', 'Absolute Cumulative Changes'})
    h(1, 1) = plot(basis_tb{other_dates(2:end), 'Date'}, cumsum(abs_other_calc), ...
        'Color', 'blue', 'DisplayName', strcat('Non-', macro_name{:}), ...
        'LineWidth', 2, 'LineStyle', '--');
    h(1, 2) = plot(basis_tb{target_dates, 'Date'}, cumsum(abs_anc_calc), ...
        'Color', 'black', 'DisplayName', macro_name{:}, 'LineWidth', 3);

    % FED Quantitative Easing 1 (11/25/2008)
    qe1 = datetime(2008, 11, 25); xline(qe1, '--r', {'QE 1'}, 'LineWidth', 1);  

    % FED Quantitative Easing 2 (9/13/2010)
    qe2 = datetime(2010, 11, 3); xline(qe2, '--r', {'QE 2'}, 'LineWidth', 1);   

    % FED Quantitative Easing 3 (9/13/2012)
    qe3 = datetime(2012, 9, 13); xline(qe3, '--r', {'QE 3'}, 'LineWidth', 1);   

    legend(h, 'FontSize', 10, 'Location', 'Southeast')
    hold off

    % -----------------------------------------------------------------------

    subplot(1, 2, 2); hold on; 
    title({'Response of Inflation Basis', 'Raw Cumulative Changes'})
    h(1, 1) = plot(basis_tb{other_dates(2:end), 'Date'}, cumsum(raw_other_calc), ...
        'Color', 'blue', 'DisplayName', strcat('Non-', macro_name{:}), ...
        'LineWidth', 2, 'LineStyle', '--');
    h(1, 2) = plot(basis_tb{target_dates, 'Date'}, cumsum(raw_anc_calc), ...
        'Color', 'black', 'DisplayName', macro_name{:}, 'LineWidth', 3);

    % FED Quantitative Easing 1 (11/25/2008)
    qe1 = datetime(2008, 11, 25); xline(qe1, '--r', {'QE 1'}, 'LineWidth', 1);  

    % FED Quantitative Easing 2 (9/13/2010)
    qe2 = datetime(2010, 11, 3); xline(qe2, '--r', {'QE 2'}, 'LineWidth', 1);   

    % FED Quantitative Easing 3 (9/13/2012)
    qe3 = datetime(2012, 9, 13); xline(qe3, '--r', {'QE 3'}, 'LineWidth', 1);   

    legend(h, 'FontSize', 10, 'Location', 'Southeast')
    hold off
    
    exportgraphics(fig, strcat('Output/macro_response/', macro_name{:}, '.png'));
     
end

%% Regress changes in inflation probabilities against macro surprise z-scores

% select only economic releases with Bloomberg relevancy of 90> (bbg)
cols = unique(bbg_eco_release{bbg_eco_release.RELEVANCE_VALUE >= 90, 'TICKER'})';

% compute pivot table with surprise z-score
beta1 = bbg_eco_release(ismember(bbg_eco_release.TICKER, cols), :);
beta1 = pivotTable(beta1, 'SURPRISES', 'RELEASE_DATE', 'NAME');

% compute regressions tables with a 1-difference window for inflation probabilities 
tb1 = regression(beta1, usd_imp_proba_bucket_1_Year, 'diff');
tb2 = regression(beta1, usd_imp_proba_bucket_3_Year, 'diff');
tb3 = regression(beta1, usd_imp_proba_bucket_5_Year, 'diff');
tb4 = regression(beta1, usd_imp_proba_bucket_7_Year, 'diff');
tb5 = regression(beta1, usd_imp_proba_bucket_10_Year, 'diff');
tb6 = regression(beta1, usd_imp_proba_bucket_15_Year, 'diff');
tb7 = regression(beta1, usd_imp_proba_bucket_20_Year, 'diff');
tb8 = regression(beta1, usd_imp_proba_bucket_30_Year, 'diff');

writetable(tb1, 'Output/regressions/usd_inflation_proba_1y_regression_bbg.csv');
writetable(tb2, 'Output/regressions/usd_inflation_proba_3y_regression_bbg.csv');
writetable(tb3, 'Output/regressions/usd_inflation_proba_5y_regression_bbg.csv');
writetable(tb4, 'Output/regressions/usd_inflation_proba_7y_regression_bbg.csv');
writetable(tb5, 'Output/regressions/usd_inflation_proba_10y_regression_bbg.csv');
writetable(tb6, 'Output/regressions/usd_inflation_proba_15y_regression_bbg.csv');
writetable(tb7, 'Output/regressions/usd_inflation_proba_20y_regression_bbg.csv');
writetable(tb8, 'Output/regressions/usd_inflation_proba_30y_regression_bbg.csv');

fprintf('6. All regressions are completed.\n');
