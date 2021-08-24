% Reads in data files and stores these variables to a .mat file

clearvars -except root_dir;

% creating certificate for web access, extending timeout to 10 seconds 
o = weboptions('CertificateFilename', "", 'Timeout', 10);

% sets current date time to retrieve current information
currentDate = string(datetime('today', 'Format','yyyy-MM-dd'));


%% VIX time series, taken from FRED 

url = 'https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=VIXCLS&scale=left&cosd=1990-01-02&coed=' + currentDate + '&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Daily%2C%20Close&fam=avg&fgst=lin&fgsnd=' + currentDate + '&line_index=1&transformation=lin&vintage_date=' + currentDate + '&revision_date=' + currentDate + '&nd=1990-01-02';

% read web data from FRED and stores it in appropriate file 
vix = webread(url, o);
vix.MONTH = month(vix.DATE);
vix.YEAR = year(vix.DATE);
vix = rmmissing(vix);
vix.SMA30 = movavg(vix.VIXCLS, 'simple', 100, 'fill'); 

%% S&P 500, taken from FRED 

url = 'https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=SP500&scale=left&cosd=2011-05-31&coed=' + currentDate + '&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Daily%2C%20Close&fam=avg&fgst=lin&fgsnd=' + currentDate + '&line_index=1&transformation=lin&vintage_date=' + currentDate + '&revision_date=' + currentDate + '&nd=2011-05-31';

% read web data from FRED and stores it in appropriate file 
sp500 = webread(url, o);
sp500.MONTH = month(sp500.DATE);
sp500.YEAR = year(sp500.DATE);
sp500 = rmmissing(sp500);

%% Daily Effective Federal Funds Rate, taken from FRED

% yearly consumer price index (DFF)
url = 'https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=DFF&scale=left&cosd=2011-05-26&coed=' + currentDate + '&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Daily%2C%207-Day&fam=avg&fgst=lin&fgsnd=' + currentDate + '&line_index=1&transformation=lin&vintage_date=' + currentDate + '&revision_date=' + currentDate + '&nd=1954-07-01';

% read web data from FRED and stores it in appropriate file 
fed_funds = webread(url, o);
fed_funds.MONTH = month(fed_funds.DATE);
fed_funds.YEAR = year(fed_funds.DATE);
fed_funds = rmmissing(fed_funds);

%% Consumer Price Index for All Urban Consumers, taken from FRED

% yearly consumer price index (CPALTT01USA659N)
url1 = 'https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=CPALTT01USA659N&scale=left&cosd=1960-01-01&coed=' + currentDate + '&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Annual&fam=avg&fgst=lin&fgsnd=' + currentDate + '&line_index=1&transformation=lin&vintage_date=' + currentDate + '&revision_date=' + currentDate + '&nd=1960-01-01';

% monthly consumer price index (CPALTT01USM657N)
url2 = 'https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=CPALTT01USM657N&scale=left&cosd=1960-01-01&coed=' + currentDate + '&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Monthly&fam=avg&fgst=lin&fgsnd=' + currentDate + '&line_index=1&transformation=lin&vintage_date=' + currentDate + '&revision_date=' + currentDate + '&nd=1960-01-01';

% read web data from FRED and stores it in appropriate file 
annual_cpi = webread(url1, o);
annual_cpi.MONTH = month(annual_cpi.DATE);
annual_cpi.YEAR = year(annual_cpi.DATE);
annual_cpi = rmmissing(annual_cpi);

monthly_cpi = webread(url2, o);
monthly_cpi.MONTH = month(monthly_cpi.DATE);
monthly_cpi.YEAR = year(monthly_cpi.DATE);
monthly_cpi = rmmissing(monthly_cpi);

%% Perform operation on inflation options data to remap CUSIP (stored in Temp)

% expressed path is of the form [compiler] -b [script path]
% NOTE THAT COMPILER PATH AND SCRIPT PATH ARE DEPENDENT ON USER SPECIFICATION
!/apps/Anaconda3-2019.03/bin/python -b '/home/rcerxr21/DesiWork/Policy/Inflation_Swap_Breakeven_Basis/Code/lib/option_remapping.py'

%% Inflation Options Data (Caps & Floors), taken from Bloomberg

% data is stored for each Term and Strike, in the order of Bid, Ask, Last Price
usd_inflation_zc_caps = readtable(strcat(root_dir, ...
    '/Temp/options/usd-zc-inflation-caps.csv'), 'PreserveVariableNames', true);
usd_inflation_yoy_caps = readtable(strcat(root_dir, ...
    '/Temp/options/usd-yoy-inflation-caps.csv'), 'PreserveVariableNames', true);

usd_inflation_zc_floors = readtable(strcat(root_dir, ...
    '/Temp/options/usd-zc-inflation-floors.csv'), 'PreserveVariableNames', true);
usd_inflation_yoy_floors = readtable(strcat(root_dir, ...
    '/Temp/options/usd-yoy-inflation-floors.csv'), 'PreserveVariableNames', true);

% remove NaNs and missing rows from the dataset
usd_inflation_zc_caps = rmmissing(usd_inflation_zc_caps);
usd_inflation_yoy_caps = rmmissing(usd_inflation_yoy_caps);

usd_inflation_zc_floors = rmmissing(usd_inflation_zc_floors);
usd_inflation_yoy_floors = rmmissing(usd_inflation_yoy_floors);

%% USD Inflation Zero-Coupon Swaps Data, taken from Bloomberg

InfSwap = readtable(strcat(root_dir, '/Input/swaps/usd-inflation-CPI-swaps.xlsx'), ...
    'PreserveVariableNames', true);

% select each corresponding inflation swap term by column
swap1y = InfSwap(:, 1:2); 
swap1y.Properties.VariableNames = {'Date', 'Swap1y'};

swap2y = InfSwap(:, 3:4); 
swap2y.Properties.VariableNames = {'Date', 'Swap2y'};

swap3y = InfSwap(:, 5:6); 
swap3y.Properties.VariableNames = {'Date', 'Swap3y'};

swap4y = InfSwap(:, 7:8); 
swap4y.Properties.VariableNames = {'Date', 'Swap4y'};

swap5y = InfSwap(:, 9:10); 
swap5y.Properties.VariableNames = {'Date', 'Swap5y'};

swap6y = InfSwap(:, 11:12); 
swap6y.Properties.VariableNames = {'Date', 'Swap6y'};

swap7y = InfSwap(:, 13:14); 
swap7y.Properties.VariableNames = {'Date', 'Swap7y'};

swap8y = InfSwap(:, 15:16); 
swap8y.Properties.VariableNames = {'Date', 'Swap8y'};

swap9y = InfSwap(:, 17:18); 
swap9y.Properties.VariableNames = {'Date', 'Swap9y'};

swap10y = InfSwap(:, 19:20); 
swap10y.Properties.VariableNames = {'Date', 'Swap10y'};

swap12y = InfSwap(:, 21:22); 
swap12y.Properties.VariableNames = {'Date', 'Swap12y'};

swap15y = InfSwap(:, 23:24); 
swap15y.Properties.VariableNames = {'Date', 'Swap15y'};

swap20y = InfSwap(:, 25:26); 
swap20y.Properties.VariableNames = {'Date', 'Swap20y'};

swap30y = InfSwap(:, 27:28); 
swap30y.Properties.VariableNames = {'Date', 'Swap30y'};

% perform inner join on all seperate inflation swap data
% NOTE MATLAB 2020b has no easy join beyond 2, requiring itterative join
col_order = {swap30y,swap20y, swap15y, swap12y, swap10y, swap9y, ...
    swap8y, swap7y, swap6y, swap5y, swap4y, swap3y, swap2y, swap1y};
usd_inf_swaps = col_order{1};

for k = 2:length(col_order)
   usd_inf_swaps = innerjoin(col_order{k}, usd_inf_swaps); 
end

%% EUR Inflation Zero-Coupon Swaps Data, taken from Bloomberg

InfSwap = readtable(strcat(root_dir, '/Input/swaps/eur-inflation-HICPxT-swaps.xlsx'), ...
    'PreserveVariableNames', true);

% select each corresponding inflation swap term by column
swap1y = InfSwap(:, 1:2); 
swap1y.Properties.VariableNames = {'Date', 'Swap1y'};

swap2y = InfSwap(:, 3:4); 
swap2y.Properties.VariableNames = {'Date', 'Swap2y'};

swap3y = InfSwap(:, 5:6); 
swap3y.Properties.VariableNames = {'Date', 'Swap3y'};

swap4y = InfSwap(:, 7:8); 
swap4y.Properties.VariableNames = {'Date', 'Swap4y'};

swap5y = InfSwap(:, 9:10); 
swap5y.Properties.VariableNames = {'Date', 'Swap5y'};

swap6y = InfSwap(:, 11:12); 
swap6y.Properties.VariableNames = {'Date', 'Swap6y'};

swap7y = InfSwap(:, 13:14); 
swap7y.Properties.VariableNames = {'Date', 'Swap7y'};

swap8y = InfSwap(:, 15:16); 
swap8y.Properties.VariableNames = {'Date', 'Swap8y'};

swap9y = InfSwap(:, 17:18); 
swap9y.Properties.VariableNames = {'Date', 'Swap9y'};

swap10y = InfSwap(:, 19:20); 
swap10y.Properties.VariableNames = {'Date', 'Swap10y'};

swap12y = InfSwap(:, 21:22); 
swap12y.Properties.VariableNames = {'Date', 'Swap12y'};

swap15y = InfSwap(:, 23:24); 
swap15y.Properties.VariableNames = {'Date', 'Swap15y'};

swap20y = InfSwap(:, 25:26); 
swap20y.Properties.VariableNames = {'Date', 'Swap20y'};

swap25y = InfSwap(:, 27:28); 
swap25y.Properties.VariableNames = {'Date', 'Swap25y'};

swap30y = InfSwap(:, 29:30); 
swap30y.Properties.VariableNames = {'Date', 'Swap30y'};

% perform inner join on all seperate inflation swap data
% NOTE MATLAB 2020b has no easy join beyond 2, requiring itterative join
col_order = {swap30y,swap25y, swap20y, swap15y, swap12y, swap10y, swap9y, ...
    swap8y, swap7y, swap6y, swap5y, swap4y, swap3y, swap2y, swap1y};
eur_inf_swaps = col_order{1};

for k = 2:length(col_order)
   eur_inf_swaps = innerjoin(col_order{k}, eur_inf_swaps); 
end

%% France Inflation Zero-Coupon Swaps Data, taken from Bloomberg

InfSwap = readtable(strcat(root_dir, '/Input/swaps/france-inflation-CPIxT-swaps.xlsx'), ...
    'PreserveVariableNames', true);

% select each corresponding inflation swap term by column
swap1y = InfSwap(:, 1:2); 
swap1y.Properties.VariableNames = {'Date', 'Swap1y'};

swap2y = InfSwap(:, 3:4); 
swap2y.Properties.VariableNames = {'Date', 'Swap2y'};

swap3y = InfSwap(:, 5:6); 
swap3y.Properties.VariableNames = {'Date', 'Swap3y'};

swap4y = InfSwap(:, 7:8); 
swap4y.Properties.VariableNames = {'Date', 'Swap4y'};

swap5y = InfSwap(:, 9:10); 
swap5y.Properties.VariableNames = {'Date', 'Swap5y'};

swap6y = InfSwap(:, 11:12); 
swap6y.Properties.VariableNames = {'Date', 'Swap6y'};

swap7y = InfSwap(:, 13:14); 
swap7y.Properties.VariableNames = {'Date', 'Swap7y'};

swap8y = InfSwap(:, 15:16); 
swap8y.Properties.VariableNames = {'Date', 'Swap8y'};

swap9y = InfSwap(:, 17:18); 
swap9y.Properties.VariableNames = {'Date', 'Swap9y'};

swap10y = InfSwap(:, 19:20); 
swap10y.Properties.VariableNames = {'Date', 'Swap10y'};

swap12y = InfSwap(:, 21:22); 
swap12y.Properties.VariableNames = {'Date', 'Swap12y'};

swap15y = InfSwap(:, 23:24); 
swap15y.Properties.VariableNames = {'Date', 'Swap15y'};

swap20y = InfSwap(:, 25:26); 
swap20y.Properties.VariableNames = {'Date', 'Swap20y'};

swap25y = InfSwap(:, 27:28); 
swap25y.Properties.VariableNames = {'Date', 'Swap25y'};

swap30y = InfSwap(:, 29:30); 
swap30y.Properties.VariableNames = {'Date', 'Swap30y'};

% perform inner join on all seperate inflation swap data
% NOTE MATLAB 2020b has no easy join beyond 2, requiring itterative join
col_order = {swap30y,swap25y, swap20y, swap15y, swap12y, swap10y, swap9y, ...
    swap8y, swap7y, swap6y, swap5y, swap4y, swap3y, swap2y, swap1y};
france_inf_swaps = col_order{1};

for k = 2:length(col_order)
   france_inf_swaps = innerjoin(col_order{k}, france_inf_swaps); 
end

%% UK Inflation (CPI) Zero-Coupon Swaps Data, taken from Bloomberg

InfSwap = readtable(strcat(root_dir, '/Input/swaps/uk-inflation-CPI-swaps.xlsx'), ...
    'PreserveVariableNames', true);

% select each corresponding inflation swap term by column
swap1y = InfSwap(:, 1:2); 
swap1y.Properties.VariableNames = {'Date', 'Swap1y'};

swap2y = InfSwap(:, 3:4); 
swap2y.Properties.VariableNames = {'Date', 'Swap2y'};

swap3y = InfSwap(:, 5:6); 
swap3y.Properties.VariableNames = {'Date', 'Swap3y'};

swap4y = InfSwap(:, 7:8); 
swap4y.Properties.VariableNames = {'Date', 'Swap4y'};

swap5y = InfSwap(:, 9:10); 
swap5y.Properties.VariableNames = {'Date', 'Swap5y'};

swap6y = InfSwap(:, 11:12); 
swap6y.Properties.VariableNames = {'Date', 'Swap6y'};

swap7y = InfSwap(:, 13:14); 
swap7y.Properties.VariableNames = {'Date', 'Swap7y'};

swap8y = InfSwap(:, 15:16); 
swap8y.Properties.VariableNames = {'Date', 'Swap8y'};

swap9y = InfSwap(:, 17:18); 
swap9y.Properties.VariableNames = {'Date', 'Swap9y'};

swap10y = InfSwap(:, 19:20); 
swap10y.Properties.VariableNames = {'Date', 'Swap10y'};

swap12y = InfSwap(:, 21:22); 
swap12y.Properties.VariableNames = {'Date', 'Swap12y'};

swap15y = InfSwap(:, 23:24); 
swap15y.Properties.VariableNames = {'Date', 'Swap15y'};

swap20y = InfSwap(:, 25:26); 
swap20y.Properties.VariableNames = {'Date', 'Swap20y'};

swap25y = InfSwap(:, 27:28); 
swap25y.Properties.VariableNames = {'Date', 'Swap25y'};

swap30y = InfSwap(:, 29:30); 
swap30y.Properties.VariableNames = {'Date', 'Swap30y'};

swap35y = InfSwap(:, 31:32); 
swap35y.Properties.VariableNames = {'Date', 'Swap35y'};

swap40y = InfSwap(:, 33:34); 
swap40y.Properties.VariableNames = {'Date', 'Swap40y'};

swap45y = InfSwap(:, 35:36); 
swap45y.Properties.VariableNames = {'Date', 'Swap45y'};

swap50y = InfSwap(:, 37:38); 
swap50y.Properties.VariableNames = {'Date', 'Swap50y'};

swap55y = InfSwap(:, 39:40); 
swap55y.Properties.VariableNames = {'Date', 'Swap55y'};

% perform inner join on all seperate inflation swap data
% NOTE MATLAB 2020b has no easy join beyond 2, requiring itterative join
col_order = {swap55y, swap50y, swap45y, swap40y, swap35y, swap30y, swap25y, ...
    swap20y, swap15y, swap12y, swap10y, swap9y, swap8y, swap7y, swap6y, swap5y, ...
    swap4y, swap3y, swap2y, swap1y};
uk_cpi_swaps = col_order{1};

for k = 2:length(col_order)
   uk_cpi_swaps = innerjoin(col_order{k}, uk_cpi_swaps); 
end

%% UK Inflation (CPI) Zero-Coupon Swaps Data, taken from Bloomberg

InfSwap = readtable(strcat(root_dir, '/Input/swaps/uk-inflation-RPI-swaps.xlsx'), ...
    'PreserveVariableNames', true);

% select each corresponding inflation swap term by column
swap1y = InfSwap(:, 1:2); 
swap1y.Properties.VariableNames = {'Date', 'Swap1y'};

swap2y = InfSwap(:, 3:4); 
swap2y.Properties.VariableNames = {'Date', 'Swap2y'};

swap3y = InfSwap(:, 5:6); 
swap3y.Properties.VariableNames = {'Date', 'Swap3y'};

swap4y = InfSwap(:, 7:8); 
swap4y.Properties.VariableNames = {'Date', 'Swap4y'};

swap5y = InfSwap(:, 9:10); 
swap5y.Properties.VariableNames = {'Date', 'Swap5y'};

swap6y = InfSwap(:, 11:12); 
swap6y.Properties.VariableNames = {'Date', 'Swap6y'};

swap7y = InfSwap(:, 13:14); 
swap7y.Properties.VariableNames = {'Date', 'Swap7y'};

swap8y = InfSwap(:, 15:16); 
swap8y.Properties.VariableNames = {'Date', 'Swap8y'};

swap9y = InfSwap(:, 17:18); 
swap9y.Properties.VariableNames = {'Date', 'Swap9y'};

swap10y = InfSwap(:, 19:20); 
swap10y.Properties.VariableNames = {'Date', 'Swap10y'};

swap12y = InfSwap(:, 21:22); 
swap12y.Properties.VariableNames = {'Date', 'Swap12y'};

swap15y = InfSwap(:, 23:24); 
swap15y.Properties.VariableNames = {'Date', 'Swap15y'};

swap20y = InfSwap(:, 25:26); 
swap20y.Properties.VariableNames = {'Date', 'Swap20y'};

swap25y = InfSwap(:, 27:28); 
swap25y.Properties.VariableNames = {'Date', 'Swap25y'};

swap30y = InfSwap(:, 29:30); 
swap30y.Properties.VariableNames = {'Date', 'Swap30y'};

swap35y = InfSwap(:, 31:32); 
swap35y.Properties.VariableNames = {'Date', 'Swap35y'};

swap40y = InfSwap(:, 33:34); 
swap40y.Properties.VariableNames = {'Date', 'Swap40y'};

swap45y = InfSwap(:, 35:36); 
swap45y.Properties.VariableNames = {'Date', 'Swap45y'};

swap50y = InfSwap(:, 37:38); 
swap50y.Properties.VariableNames = {'Date', 'Swap50y'};

% perform inner join on all seperate inflation swap data
% NOTE MATLAB 2020b has no easy join beyond 2, requiring itterative join
col_order = {swap50y, swap45y, swap40y, swap35y, swap30y, swap25y, ...
    swap20y, swap15y, swap12y, swap10y, swap9y, swap8y, swap7y, swap6y, swap5y, ...
    swap4y, swap3y, swap2y, swap1y};
uk_rpi_swaps = col_order{1};

for k = 2:length(col_order)
   uk_rpi_swaps = innerjoin(col_order{k}, uk_rpi_swaps); 
end

%% The U.S. Treasury Yield Curve: 1961 to the Present
% https://www.federalreserve.gov/pubs/feds/2006/200628/200628abs.html

url = 'https://www.federalreserve.gov/data/yield-curve-tables/feds200628.csv';

% read web data from Federal Reserve and stores it in appropriate file 
websave(strcat(root_dir, '/Input/treasury-curve.csv'), url, o);
ust_curve= readtable(strcat(root_dir, '/Input/treasury-curve.csv'));

% select zero-coupon Treasury yeild and corresponding date column
ust_curve1 = ust_curve(:, ismember(ust_curve.Properties.VariableNames, ...
    {'Date', 'SVENY01'}));
ust_curve3 = ust_curve(:, ismember(ust_curve.Properties.VariableNames, ...
    {'Date', 'SVENY03'}));
ust_curve5 = ust_curve(:, ismember(ust_curve.Properties.VariableNames, ...
    {'Date', 'SVENY05'}));
ust_curve7 = ust_curve(:, ismember(ust_curve.Properties.VariableNames, ...
    {'Date', 'SVENY07'}));
ust_curve10 = ust_curve(:, ismember(ust_curve.Properties.VariableNames, ...
    {'Date', 'SVENY10'}));
ust_curve15 = ust_curve(:, ismember(ust_curve.Properties.VariableNames, ...
    {'Date', 'SVENY15'}));
ust_curve20 = ust_curve(:, ismember(ust_curve.Properties.VariableNames, ...
    {'Date', 'SVENY20'}));
ust_curve30 = ust_curve(:, ismember(ust_curve.Properties.VariableNames, ...
    {'Date', 'SVENY30'}));

% perform inner join on all seperate treasury yeilds curves
% NOTE MATLAB 2020b has no easy join beyond 2, requiring itterative join
col_order = {ust_curve30, ust_curve20, ust_curve15, ust_curve10, ust_curve7, ...
    ust_curve5, ust_curve3, ust_curve1};
rates = col_order{1};

for k = 2:length(col_order)
    % inner join start from the back (longest tenor)
    rates = innerjoin(col_order{k}, rates); 
end

% remove NaNs and missing rows from the dataset
rates = rmmissing(rates);
rates= rates(rates.Date > '2000-01-01', :);

% re-create the rates for United States Treasury 
ust_rates = zeros(size(rates, 1), length(col_order));

for k = 2:length(rates.Properties.VariableNames)
    
    % check to see if the column is a double
    if ~isa(rates{:, k}, 'double')
        ust_rates(:, k-1) = str2double(rates{:, k});
    else
        ust_rates(:, k-1) = rates{:, k};
    end
   
end

% convert matrix to a table and add datatime vector (organizing datatable)
ust_rates = array2table(ust_rates);
ust_rates.Properties.VariableNames = rates.Properties.VariableNames(2:end);
ust_rates.Date = rates{:, 1}; 
ust_rates = movevars(ust_rates, 'Date', 'Before', 'SVENY01'); 

%% The U.S. TIPS Yield Curve: 1999 to the Present
% https://www.federalreserve.gov/data/tips-yield-curve-and-inflation-compensation.htm

url = 'https://www.federalreserve.gov/data/yield-curve-tables/feds200805.csv';

% read web data from Federal Reserve and stores it in appropriate file 
websave(strcat(root_dir, '/Input/tips-curve.csv'), url, o);
tips_curve= readtable(strcat(root_dir, '/Input/tips-curve.csv'));

% select zero-coupon TIPS yeild and corresponding date column
tips_curve3 = tips_curve(:, ismember(tips_curve.Properties.VariableNames, ...
    {'Date', 'TIPSY03'}));
tips_curve5 = tips_curve(:, ismember(tips_curve.Properties.VariableNames, ...
    {'Date', 'TIPSY05'}));
tips_curve7 = tips_curve(:, ismember(tips_curve.Properties.VariableNames, ...
    {'Date', 'TIPSY07'}));
tips_curve10 = tips_curve(:, ismember(tips_curve.Properties.VariableNames, ...
    {'Date', 'TIPSY10'}));
tips_curve15 = tips_curve(:, ismember(tips_curve.Properties.VariableNames, ...
    {'Date', 'TIPSY15'}));
tips_curve20 = tips_curve(:, ismember(tips_curve.Properties.VariableNames, ...
    {'Date', 'TIPSY20'}));

% perform inner join on all seperate treasury yeilds curves
% NOTE MATLAB 2020b has no easy join beyond 2, requiring itterative join
col_order = {tips_curve20, tips_curve15, tips_curve10, tips_curve7, ...
    tips_curve5, tips_curve3};
rates = col_order{1};

for k = 2:length(col_order)
    % inner join start from the back (longest tenor)
    rates = innerjoin(col_order{k}, rates); 
end

% remove NaNs and missing rows from the dataset
rates = rmmissing(rates);
rates= rates(rates.Date > '2000-01-01', :);

% re-create the rates for United States Treasury 
tips_rates = zeros(size(rates, 1), length(col_order));

for k = 2:length(rates.Properties.VariableNames)
    
    % check to see if the column is a double
    if ~isa(rates{:, k}, 'double')
        tips_rates(:, k-1) = str2double(rates{:, k});
    else
        tips_rates(:, k-1) = rates{:, k};
    end
   
end

% convert matrix to a table and add datatime vector (organizing datatable)
tips_rates = array2table(tips_rates);
tips_rates.Properties.VariableNames = rates.Properties.VariableNames(2:end);
tips_rates.Date = rates{:, 1}; 
tips_rates = movevars(tips_rates, 'Date', 'Before', 'TIPSY03'); 

%% Compute the inflation basis (UST - TIPS - SWAPS)

% find intersection of all dates to have one vector to filter
d1 = intersect(ust_rates{:, 'Date'}, tips_rates{:, 'Date'});
d2 = intersect(usd_inf_swaps{:, 'Date'}, d1);

% compute the basis figures over date intersection (select columns)
UST = ust_rates{ismember(ust_rates{:, 'Date'}, d2), ...
    {'SVENY03', 'SVENY05', 'SVENY07', 'SVENY10', 'SVENY15', 'SVENY20'}};
TIP = tips_rates{ismember(tips_rates{:, 'Date'}, d2), ...
    {'TIPSY03', 'TIPSY05', 'TIPSY07', 'TIPSY10', 'TIPSY15', 'TIPSY20'}};
SWP = usd_inf_swaps{ismember(usd_inf_swaps{:, 'Date'}, d2), ...
    {'Swap3y', 'Swap5y', 'Swap7y', 'Swap10y', 'Swap15y', 'Swap20y'}};

% perform calculation for basis identity
Basis = SWP - UST + TIP;

% organzing table columns for export
basis_tb = array2table(Basis);
basis_tb.Properties.VariableNames = {'BASIS03Y', 'BASIS05Y', 'BASIS07Y', ...
    'BASIS10Y', 'BASIS15Y', 'BASIS20Y'};
basis_tb.Date = d2; 
basis_tb = movevars(basis_tb, 'Date', 'Before', 'BASIS03Y'); 

%% Economic Annoucements, taken from Bloomberg 

% manipulate economic data releases (Bloomberg - ECO)
bbg_eco_release = readtable('bloomberg_economic_releases.csv', 'PreserveVariableNames', ...
    true);         

% selecting specific macro-economic annoucements
macroReleases = {'Adjusted Retail Sales Less Autos SA Monthly % Change', ...
    'US Employees on Nonfarm Payrolls Total MoM Net Change SA', ...
    'Conference Board Consumer Confidence SA 1985=100', ...
    'US CPI Urban Consumers MoM SA', 'US Durable Goods New Orders Industries MoM SA', ...
    'US Initial Jobless Claims SA', 'ISM Manufacturing PMI SA', ...
    'ISM Manufacturing PMI SA', 'GDP US Chained 2012 Dollars QoQ SAAR', ...
    'Federal Funds Target Rate - Upper Bound', ...
    'Philadelphia Fed Business Outlook Survey Diffusion Index General Conditions', ...
    'US PPI Final Demand Less Foods and Energy MoM SA', ...
    'University of Michigan Consumer Sentiment Index'};

bbg_eco_release = bbg_eco_release(ismember(bbg_eco_release.NAME, macroReleases), :);

% remove insignificant events and non-times
bbg_eco_release = bbg_eco_release(~isnat(bbg_eco_release{:, 'RELEASE_DATE'}), :);

% only select event dates with a median, actual, and std value (avoid NaN) 
bbg_eco_release = bbg_eco_release(~isnan(bbg_eco_release.BN_SURVEY_MEDIAN) & ...
    ~isnan(bbg_eco_release.ACTUAL_RELEASE) & ...
    ~isnan(bbg_eco_release.FORECAST_STANDARD_DEVIATION), :);    

%% Download measures of monetary response shocks

% --------------------------------------------------------------------------------
% Refer to links provided below for details on particular monetary-shocks:
% 
%   Swanson (2019)              Measuring the Effects of Federal Reserve Forward 
%                               Guidance and Asset Purchases on Financial Markets
%   Nakamura-Steinsson (2018)   High Frequency Identification of Monetary 
%                               Non-Neutrality: The Information Effect 
% --------------------------------------------------------------------------------

swanson_url = strcat('https://www.socsci.uci.edu/~swanson2/papers/pre-and-post', ...
    '-ZLB-factors-extended.xlsx');

% read web data from each corresponding link
swanson_2019 = webread(swanson_url, o);
nakamura_steinsson_2018 = readtable(strcat(root_dir, ...
    '/Input/nakamura_steinsson_shocks.xlsx'), 'Sheet', 2, ...
    'PreserveVariableNames', true);

swanson_2019 = rmmissing(swanson_2019);
nakamura_steinsson_2018 = rmmissing(nakamura_steinsson_2018);

%% save cleaned file data to mat file for future use

save('Temp/DATA', 'annual_cpi', 'monthly_cpi','ust_rates', 'tips_rates', ...
    'basis_tb',  'bbg_eco_release', 'fed_funds', 'sp500', 'vix', ...
    'swanson_2019', 'nakamura_steinsson_2018')

save('Temp/OPTIONS', 'usd_inflation_zc_caps', 'usd_inflation_yoy_caps', ...
    'usd_inflation_zc_floors', 'usd_inflation_yoy_floors')

save('Temp/SWAPS', 'usd_inf_swaps', 'uk_cpi_swaps', 'uk_rpi_swaps', ...
    'eur_inf_swaps', 'france_inf_swaps')

fprintf('All data has been downloaded.\n');
