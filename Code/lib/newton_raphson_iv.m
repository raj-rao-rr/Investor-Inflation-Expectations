%
% Author, Rajesh Rao
% 
% Computes the static implied volatility for the inflation cap/floor, we
% implement the newton-raphson iterative method as detailed in the (Liu, Oosterlee 
% and Bohte, 2019) under 2.3 Numerical Methods for Implied Volatility
% 
% Link: [https://www.actuaries.org/Munich2009/papers/AFIR/Fri_10.00_AFIR_Kruse_Asset_pricing_Paper.pdf]
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: V (type double)
%       The price for the zero-coupon inflation option
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
%   :param: T (type double) 
%       The time duration in years (e.g. 1 year = 1)
%   :param: method (type str)
%       Determine whether the option being priced is a cap or floor, we
%       default to using the cap pricer
% 
% Outputs:
%   :param: iv (type double)
%       Returns the implied volatility measure for a given inflation option price 


function iv = newton_raphson_iv(V, rR, rN, K, I_base, I_trail, T, method)
    
    epsilon = 1 / 1e3;          % epislon for determining convergence
    prior_sigma = 0.01;         % initial assumption of the implied volatility 
    iv = NaN;                   % default implied volatility parameter
    
    % we check iteratively the expected volatility to satisfy a constraint
    for i = 1:1e2
        
        if method
            % compute the option value provided the underlying data 
            temp_V = inf_option_black_mdl(rR, rN, K, I_base, I_trail, ...
                prior_sigma, T, method);

            % vega greek for inflation option
            v = vega(rR, rN, K, I_base, I_trail, prior_sigma, T, method);           
        
        else
            temp_V = inf_option_black_mdl(rR, rN, K, I_base, I_trail, ...
                prior_sigma, T, method);
            v = vega(rR, rN, K, I_base, I_trail, prior_sigma, T, method);
            
        end
        
        % perform the Newton-Raphson method for the implied volatility
        next_sigma = prior_sigma - (temp_V - V) / v;    
        
        % if the epsilon is bounded we break the loop and return sigma
        if abs(next_sigma - prior_sigma) < epsilon 
            iv = next_sigma; break;
        end
        
        % assign prior with next sigma term in sequence (sequencing)
        prior_sigma = next_sigma;   
        
    end
    
end