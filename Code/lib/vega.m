%
% Author, Rajesh Rao
% 
% Computes the vega of an option, by numerically differencing the price of
% the option provided small changes in implied volatility and then dividing
% by the change in implied volatility 
% 
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: rR (type double) 
%       The real USD rate taken as the differnce between the USD nominal Treasury 
%       rates and the current inflation swap price at that tenor  
%   :param: rN (type double) 
%       The nominal USD Treasury rate for a given maturity at a time
%   :param: K (type double) 
%       The strike corresponding with the inflation level of the cap/floor 
%   :param: I_base (type double)
%       The underlying inflation index for option (e.g. CPI) at time 0 
%   :param: I_trail (type double) 
%       The underlying inflation index for option (e.g. CPI) as a function of time 
%   :param: sigma (type double) 
%       The volatility used to price the inflation options
%   :param: T (type double) 
%       The time duration in years (e.g. 1 year = 1)
%   :param: method (type str)
%       Determine whether the option being priced is a cap or floor, we
%       default to using the cap pricer
% 
% Outputs:
%   :param: v (type double)
%       Returns the vega parameter for a given inflation option 


function v = vega(rR, rN, K, I_base, I_trail, sigma, T, method)
    
    delta = 0.01;
    
    % cap pricing form 
    if method
        % compute incremtal price change for changes in implied volatility 
        V1 = inf_option_black_mdl(rR, rN, K, I_base, I_trail, sigma, T, method);
        V2 = inf_option_black_mdl(rR, rN, K, I_base, I_trail, sigma+delta, T, ...
            method);
    
    % floor pricing form
    else
        % compute incremtal price change for changes in implied volatility
        V1 = inf_option_black_mdl(rR, rN, K, I_base, I_trail, sigma, T, method);
        V2 = inf_option_black_mdl(rR, rN, K, I_base, I_trail, sigma+delta, T, ...
            method); 
    
    end
    
    % compute numerical approximation to vega, as the change in price,
    % relative to incremental changes in implied volatilty 
    v = (V2 - V1) / delta;
    
end