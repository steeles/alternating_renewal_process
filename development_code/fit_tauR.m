function [tauH fval exitflag] = fit_tauR(DursCell,tau0)


if ~exist('tau0','var'), tau0 = abs(randn+.5); end

f = @(tau)compute_cumhist_corr(DursCell,tau);
g = @(tau)-f(tau);

%[tauH fval exitflag] = fminunc(g,tau0);

%LB = .5; UB = 60;
[tauH fval exitflag] = fminsearch(g,tau0);

