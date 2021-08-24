%
% Author, Rajesh Rao
% 
% Computing the pure difference of numerical entries in a matlab table
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: V  (type table)
%       A matlab table object with numerical quantities, and a datevector
%       in its first column
%   :param: method (type str)
%       The method implemented for computing the difference matrix
% 
% Outputs:
%   :param: mat (type table)
%       Returns the differnce matrix for all components of the target
%   


function mat = table_diff(V, method)
    
    assert(strcmp(method, 'pct') | strcmp(method, 'diff') | strcmp(method, 'log'), ...
    'Error: Weight parameter only accepts strings, pct, diff, or log')

    % compute the volatility measure percent gain and convert to table
    if strcmp(method, 'pct')
        calculation = (V{2:end, 2:end} - V{1:end-1, 2:end}) ./ V{1:end-1, 2:end};
    elseif strcmp(method, 'diff')
        calculation = V{2:end, 2:end} - V{1:end-1, 2:end};   
    elseif strcmp(method, 'log')
        calculation = log(V{2:end, 2:end} / V{1:end-1, 2:end});        
    end
            
    mat = array2table(calculation); 
    mat.DateTime = V{2:end, 1};
    mat = movevars(mat, 'DateTime', 'Before', mat.Properties.VariableNames{1});
    
    % re-assign table names accordingly
    mat.Properties.VariableNames(2:end) = V.Properties.VariableNames(2:end); 
    
end