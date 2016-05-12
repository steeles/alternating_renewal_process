% this function takes a set of data, finds starting estimate, and runs the
% search to maximize likelihood

% k1 & k2 can be gamfit shape pars
% b1 & b2 (intercept) can be sample means?
% tau i could set with the tau that maximizes r;
% m1 & m2 i have no idea how to set

% i should overload my functions for Durs & Durs Cell

function [parmhat fval parsMaxR output maxR] = estimate_cumhist_pars(Durs,bNull,init,bPlot)

if ~exist('bPlot','var')
    bPlot = 0;
end

if ~exist('init','var') || isempty(init)
    
    if iscell(Durs)
        Dursn = vertcat(Durs{:});
    end
    Durs = Durs(~cellfun('isempty',Durs));
    durs1 = Dursn(Dursn(:,2)==1,1);
    durs2 = Dursn(Dursn(:,2)==2,1);
    
    g1 = gamfit(durs1); g2 = gamfit(durs2);
    
    k1 = g1(1);
    b1 = k1 * g1(2);
    
    k2 = g2(1);
    b2 = k2 * g2(2);
%     
%     f = @(tau)compute_combined_cum_history(Durs,tau);
%     g = @(tau)-f(tau);
%     
%     [tau fval] = fminsearch(g,b1/2);
     
    [tau maxR] = fit_tauR(Durs);
    m1 = 1; m2 = 1;
    
    pars0 = [k1; k2; b1; b2; m1; m2; tau];
    
    [lnT1, lnT2, H11, H22] = Durs_to_H_pred_lnT(Durs,tau);
    
    [p11] = polyfit(H11, lnT1, 1); y11 = polyval(p11,H11);
    r2(1) = calc_rSquared(lnT1,y11);
    [p22] = polyfit(H22, lnT2, 1); y22 = polyval(p22,H22);
    r2(4) = calc_rSquared(lnT2, y22);
    
    parsMaxR = [k1; k2; p11(2); p22(2); p11(1); p22(1); tau];

else    
    pars0 = init;
    [tau maxR] = fit_tauR(Durs);
    parsMaxR = [tau];
end

fun = @(pars)compute_cumhist_LL_faster(Durs,pars);
nfun = @(pars)-fun(pars);

opts = optimoptions('fminunc','Algorithm','quasi-newton');

if exist('bNull','var') && logical(bNull)
    pars0(5:7) = [0;0;1];
    %keyboard;
    %options = optimset('Display','iter');
    
    [pars fval] = fmincon(nfun,pars0,[],[],[],[],[.1; .1; .1; .1; 0; 0; 1],...
        [Inf; Inf; Inf; Inf; 0; 0; 1],[]);%,options);
    
else
%    keyboard;
    [pars fval exitflag output] = fminunc(nfun, pars0,opts);
    if exitflag~=1
        [pars fval exitflag output] = fminunc(nfun,pars,opts);
        if exitflag~=1
            [pars fval exitflag output] = fminunc(nfun,pars,opts);
        end
    end
end
pars([1 2 7]) = abs(pars([1 2 7]));
parmhat = pars;

    
%struct('k1',pars(1), 'k2', pars(2), 'b1', pars(3), 'b2', ...
%    pars(4), 'm1', pars(5), 'm2', pars(6), 'tau', pars(7));

