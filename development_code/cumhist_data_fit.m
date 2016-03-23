% fit cumhist to corrected data
% we're going to start with the plot of corr vs tau?
clear;

load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/Corrected_All_DFsExtraTrials');

nTaus = 20;
tau_ax = logspace(-.5,1.75,nTaus);
    


% first goal is to try to see how new maxRbyP works
for cInd = 4
   for sInd = 1:NumSubj
       
       rVals(nTaus) = 0;
       zVals(nTaus) = 0;
       DursCell = DurationsCell(cInd,sInd,:);
       DursCell = squeeze(squeeze(DursCell));
       
       for tInd = 1:nTaus
        
            tau = tau_ax(tInd);
        
            [ZrCombined, r11, r22, p11, p22] = ...
    compute_cumhist_corr(DursCell,tau);
            
            rVals(tInd) = tanh(.5*(atanh(abs(r11)) + atanh(abs(r22))));
            zVals(tInd) = ZrCombined;
        
       end
       figure; plot(tau_ax,rVals,tau_ax, zVals); mk_Nice_Plot
       legend('r_{absCombined}','z (se_r)')
       xlabel('tau'); ylabel('correlation strength')
       title(sprintf('s%d DF=%d N=%d', sInd, DFvals(cInd),...
           length(vertcat(DursCell{:}))));
       
   end
           
           
end
%%
   
    
    % find mean duration
    Tbar = mean(vertcat(ARP_data_tot.durs1, ARP_data_tot.durs2));
    
    figure;
    
    [foo maxRi] = max(rVals);
    
    maxRtau = tau_ax(maxRi);
    
    semilogx(tau_ax,rVals,'g'); mk_Nice_Plot;
    
    title(sprintf('condn %d, subject %d, best ~ %.2f, mnDur = %.2f',i,j,maxRtau,Tbar))
    legend('r','Location','Best'); xlabel('tau'); ylabel('corr')
    xlim([min(tau_ax) max(tau_ax)])
    
    
    tau = maxRtau;
    
    %i need to functionalize this
    f = @(tau)compute_combined_cum_history(DursCell,tau);
    g = @(tau)-f(tau);
    
    [tauH fval] = fminsearch(g,maxRtau);
    
    %compute_combined_cum_history(DursCell,tauH,1);
    
    
    [r r2 H1 H2 pVals sigFlag H11 H12 lnT1 lnT2 p11 p12] = ...
        compute_combined_cum_history(DursCell,tauH,1);
    
    % split in half, find low H/ high H distr's, find slope of mean
    
    cumhist_data_tot(j) = struct('mean_1', mean(exp(lnT1)), 'mean_2',  ...
        mean(exp(lnT2)), 'k1', ARP_data_tot(j).g1(1), 'k2', ...
        ARP_data_tot(j).g2(1), 'tau', tauH, ...
                                'r', -fval, 'p11',p11, 'p12', p12);
    
end

%%
figure; plot([cumhist_data_tot.tau],[cumhist_data_tot.r],'.');
mk_Nice_Plot
xlabel('tau'); ylabel('r')