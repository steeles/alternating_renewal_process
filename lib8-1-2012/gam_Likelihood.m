
%%%%%%%%%%%%%%%%%%%%%%%%%
% this uses Beta, not Theta (scale).
function [error likelihood] = gam_Likelihood(g,x)

alpha = g(1); beta = 1/(g(2));


LogLik = alpha*log(beta)-log(gamma(alpha))...
    + (alpha-1).*log(x)-beta.*x;
error = -(sum(LogLik));

likelihood = exp(sum(LogLik));