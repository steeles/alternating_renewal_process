% this function takes a set of data, finds starting estimate, and runs the
% search to maximize likelihood

% k1 & k2 can be gamfit shape pars
% b1 & b2 (intercept) can be sample means?
% tau i could set with the tau that maximizes r;
% m1 & m2 i have no idea how to set

% i should overload my functions for Durs & Durs Cell

function [parmhat fval] = estimate_cumhist_pars(Durs, init)

if exist('init','var')
    pars0 = init;
else
    
    durs1 = Durs(Durs(:,2)==1,1);
    durs2 = Durs(Durs(:,2)==2,1);
    
    g1 = gamfit(durs1); g2 = gamfit(durs2);
    
    k1 = g1(1);
    b1 = k1 * g1(2);
    
    k2 = g2(1);
    b2 = k2 * g2(2);
    
    f = @(tau)compute_combined_cum_history(Durs,tau);
    g = @(tau)-f(tau);
    
    [tau fval] = fminsearch(g,b1/2);
    
    m1 = 1; m2 = 1;
    
    pars0 = log([k1 k2 b1 b2 m1 m2 tau]);
end

fun = @(pars)compute_cumhist_LL(Durs,pars);
nfun = @(pars)-fun(pars);

options = optimset('Display','iter');
[pars fval] = fminsearch(nfun, pars0,options);

%[pars fval] =fmincon(nfun, pars0, [], [], [], [], [0 0 0 0 0 0 0]);

parmhat = exp(pars);
%struct('k1',pars(1), 'k2', pars(2), 'b1', pars(3), 'b2', ...
%    pars(4), 'm1', pars(5), 'm2', pars(6), 'tau', pars(7));

