% trying to find out what parameters for a gamma distribution make data x
% most likely; here I'm applying it to durations for bistable percepts
% Steeles 1/24/2012
% Rewrote 8/4/2012 to parameterize to k and theta, "shape" & "scale"

% 
function [g k theta fval exitFlags] = find_gamma_pars_proto(x)

g_mean=mean(x);
g_var=var(x);

theta = g_var/g_mean;
k = g_mean/theta;

[g fval exitFlags] = fminsearch(@gam_Likelihood,[k; theta],...
    [],x);


%%%%%%%%%%%%%%%%%%%%%%%%%
% this uses Beta, not Theta (scale).
function error = gam_Likelihood(g,x)

alpha = g(1); beta = 1/(g(2));


LogLik = alpha*log(beta)-log(gamma(alpha))...
    + (alpha-1).*log(x)-beta.*x;
error = -(sum(LogLik));