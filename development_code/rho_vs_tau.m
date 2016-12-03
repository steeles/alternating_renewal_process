% Plot rho vs tau for some given durs

function [rho_vals, tau_ax, r_vals] = rho_vs_tau(DursCell, tauRange, nTauHs)

    if ~iscell(DursCell)
        DursCell = {DursCell};
    end

    logTauLow = log10(tauRange(1));
    logTauHi = log10(tauRange(2));
    
    if ~exist('nTauHs','var')
        nTauHs = 20;
    end
    
    tau_ax = logspace(logTauLow,logTauHi,nTauHs);
    
    
    rho_vals(nTauHs) = 0;
    r_vals(nTauHs) = 0;
    for tInd = 1:nTauHs
        
        tau = tau_ax(tInd);
        
        [rhoVal, pVal, r11, r22] = computeRho(DursCell,tau);
        
        rho_vals(tInd) =  rhoVal;
        
        r_vals(tInd) = mean([r11 r22]);
        
    end
    