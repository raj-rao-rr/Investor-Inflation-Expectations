%
% Author, Rajesh Rao
% 
% Computes the static price of an inflation cap/floor, under the assumption that 
% the dynamics of the inflation index is given by a stochastic differential
% equation given by dI(t) = (rN - rR)I(t)dt + σI(t)dW(t). Futher details on
% the fomulation can be found in the Susanne Kruse (2011) paper Corollary 2.2.
% 
% LinK: [https://link.springer.com/article/10.1007/s13385-011-0022-4]
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
%   :param: V (type double)
%       Returns the price for a zero-coupon inflation option (e.g. caps &
%       floors) given the specifcation provided by user 


function [V, varargout] = inf_option_black_mdl(rR, rN, K, I_base, I_trail, ...
    sigma, T, varargin)
    
    if isempty(varargin)
        method = 1;             % if no additional arg. provided, default cap
    else
        method = varargin{1};   % 1 = cap price, 0 = floor price
    end

    % compute the d-variable measures used for cummualtive normal dist.
    num = log(I_trail / (I_base * (1 + K))) + (rN - rR + 0.5 * sigma^2) * T;
    den =  sigma * sqrt(T);
    
    d1 = num / den;             % left hand normal-cdf term  
    d2 = d1 - sigma*sqrt(T);    % right-hand normal-cdf term
    
    if method
        % we follow a black scholes formulation, assuming log-normality for the
        % underlying inflation response and differencing by the assigned strike 
        discounted_inflation_real = (I_trail / I_base) * exp(-rR * T) * normcdf(d1);                         
        discounted_strike_nominal = (1 + K) * exp(-rN * T) * normcdf(d2);
        
        % compute the value of the cap option 
        V = discounted_inflation_real - discounted_strike_nominal; 
    else
        discounted_inflation_real = (I_trail / I_base) * exp(-rR * T) * normcdf(-d1);                         
        discounted_strike_nominal = (1 + K) * exp(-rN * T) * normcdf(-d2);
        
        % compute the value of the floor option 
        V = discounted_strike_nominal - discounted_inflation_real; 
    end
    
    % conditional output contingent to number of output arguments provided
    if nargout > 1
       varargout(1) = {[rR, rN, K, I_base, I_trail, sigma, T]};
    end   
    
end