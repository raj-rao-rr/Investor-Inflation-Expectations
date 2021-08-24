%
% Author, Rajesh Rao
% 
% Peforms a regression on varaibles 'X', 'y'. Where 'X' is a table of 
% economic data releases provided by Bloomberg and y is the measured 
% target. These targets include our measure for variance risk premia, 
% implied volatility and realized volatiltity 
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: X (type table) 
%       The economic surprises from Bloomberg to regress on 
%   :param: y (type table) 
%       The volatility measures (include IV, RV and VRP)
%   :param: map (type collection) 
%       The column from the economic surprises, to regress on 
%       e.g. "SurpriseZscore", "Surprises"
%   :param: method (type str)
%       The method implemented for computing the difference matrix
% 
% Outputs:
%   :param: coefTB (type table)
%       A regression table with specific column indicators as provided
%       (Estimate, Standard Error, tStat, pValue, BetaNames, LHV Name)
%   :param: coefTB (type table)
%       A regression parameter table with specific column indicators
%       (R-Squared, Adj. R-Squared, Root MSE, Y-Name)

function modelTB = regression(X, y, method)
    
    % retrieve the column number for the each variable 
    [~, n] = size(y.Properties.VariableNames);
    [~, k] = size(X.Properties.VariableNames);
    
    % initialize the columns that will be exported for regressed figures
    modelTB = zeros(2*(k-1) + 3, 1);
    modelCol = zeros(2*(k-1), 1); 
    modelRow = cell(2*(k-1) + 3, 1);
    
    % computing the positional shifts for the Estimates & Standard Errors
    pos1 = 1:2:(2*(k-1));
    pos2 = 2:2:(2*(k-1));
    
    % find the intersection between date ranges of X and y variables
    targetDates = matchingError(X, y);
    
    % computes difference and economic surprise
    [diff, eco] = differenceSplit(X, y, targetDates, method);
    
    % return the variable names for y and X
    yNames = diff.Properties.VariableNames(2:end);
    xNames = X.Properties.VariableNames(2:end);
    
    % compute the linear regression for each y-value, we assume
    % we make the assumption that the first column is our date index
    for index = 2:n
        
        % fit the linear model for each y-value provided 
        mdl = fitlm(eco{:, 2:end}, diff{:, index});
        
        estimate = mdl.Coefficients.Estimate(2:end);    % Estimates
        p_value = mdl.Coefficients.pValue(2:end);       % p-values
        
        % retrive the essential regression values
        rsquared = mdl.Rsquared.Ordinary;       % R-squared
        rMSE = mdl.RMSE;                        % Root Mean Squared Error
        nObs = size(diff, 1);                   % number of observations     
        
        % get positions to fill the Estimates and pValue measures
        modelCol(pos1) = estimate;
        modelCol(pos2) = p_value; 
        
        % assign rows for the model table
        modelTB(:, index-1) = round([modelCol; rsquared; rMSE; nObs], 5);
        
    end 
    
    % convert cell matrix to a table 
    modelTB = array2table(modelTB); 
    modelTB.Properties.VariableNames = yNames;
    
    % determine the x-variable names as accompanying figures 
    modelRow(pos1) = xNames;
    modelRow(pos2) = {''}; 
    modelRow(end-2) = {'R^2'}; 
    modelRow(end-1) = {'RMSE'}; 
    modelRow(end) = {'nObs'};

    modelTB.Var = modelRow;
    
    % re-order the columns for Var to be the first column 
    modelTB = movevars(modelTB, 'Var', 'Before', ...
        modelTB.Properties.VariableNames{1});
end
