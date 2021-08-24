%
% Author, Rajesh Rao
% 
% Function for creating a pivot table from tabular data as provided 
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: base  (type table)
%       Original data table, with at least three columns present
%   :param: values (type str)
%       A string that represents the columns from the original base table
%       that you wish to preserve as the data in the pivot table
%   :param: index (type str)
%       A string that represents the column from the original base table
%       that you wish to serve as the index of the pivot table
%   :param: columns (type str)
%       A string the represents the columns from the original base table
%       that you wish to serve as the columns of the pivot table 
% 
% Outputs:
%   :param: pivot (type table)
%       Returns a pivot table organized by the specified index, column and
%       value scheme provided to the function
%   

function pivot = pivotTable(base, values, index, columns)
    
    % check the variable type entered 
    assert(isa(base, 'table'), ...
        'TypeError: base ');
    assert(isa(values, 'char') & isa(index, 'char') & isa(columns, 'char'), ...
        'TypeError: column names must all be of type char');
    
    
    % split data based on rows and columns features alongside values
    [~, indexV, columnV, valueV] = findgroups(base{:, index}, ...
        base{:, columns}, base{:, values});

    % format each filtered subset into a intermediate table 
    simplePivot = table(indexV, columnV, valueV);
    
    % create the pivot table with column names and values
    pivot = unstack(simplePivot, 'valueV', 'columnV', 'VariableNamingRule', ...
        'preserve');
   
    % fill all missing NaN values with 0 constant
    for col = pivot.Properties.VariableNames(2:end)
        [n, ~] = size(pivot(isnan(pivot{:, col}), col));    % size of NaNs
        
        % iterativley change columns, ignore left most index
        pivot(isnan(pivot{:, col}), col) = array2table(zeros(n,1));
    end
    
end