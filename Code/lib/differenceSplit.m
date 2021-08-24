%
% Author, Rajesh Rao
% 
% Computing the volatility difference between pre/post annoucements
% as well as the filtered economic data 
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: base  (type table)
%       Economic annoucments that track a particular event
%   :param: target (type table)
%       Target variable measure to track against economic event
%   :param: targetDate (type datetime array)
%       Intersecting dates for variables vectors 
%   :param: method (type str)
%       The method implemented for computing the difference matrix
% 
% Outputs:
%   :param: y (type matrix)
%       Returns the differnce matrix for all components of the target
%       variable, ignoring the first column of the target table
%   :param: X (type table)
%       Returns the economic variables filtered by the target datetime
%   
%   NOTE: diff and eco variables are not subject to same lengths
% 

function [y, X] = differenceSplit(base, target, targetDates, method)
    
    assert(strcmp(method, 'pct') | strcmp(method, 'diff') | strcmp(method, 'log'), ...
    'Error: Weight parameter only accepts strings, pct, diff, or log')

    yNames = target.Properties.VariableNames(2:end);

    % target date windows for pre-post announcement 
    post = target(targetDates, :);
    pre = target(targetDates-1, :);

    % compute the volatility measure percent gain and convert to table
    if strcmp(method, 'pct')
        calculation = (post{:, 2:end} - pre{:, 2:end}) ./ pre{:, 2:end};
    elseif strcmp(method, 'diff')
        calculation = post{:, 2:end} - pre{:, 2:end};   
    elseif strcmp(method, 'log')
        calculation = log(post{:, 2:end}) - log(pre{:, 2:end});        
    end
            
    y = array2table(calculation); 
    y.DateTime = post{:, 1};
    y = movevars(y, 'DateTime', 'Before', y.Properties.VariableNames{1});
    
    % re-assign table names accordingly
    y.Properties.VariableNames(2:end) = yNames; 
    
    % economic filtered data matching for y date time 
    X = base(ismember(base{:, 1}, target{targetDates, 1}), :);
    
end