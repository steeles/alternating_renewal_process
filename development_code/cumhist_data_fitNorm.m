% fit cumhist to corrected data
% we're going to start with the plot of corr vs tau?
clear;

load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/Corrected_All_DFsExtraTrials');

nTaus = 20;
tau_ax = logspace(-.5,1.75,nTaus);
    
equidom_condns_by_subj(1,2) = 0;
thresh_equidom = [.45,.55];

NormalizedDurs = cell(5,1);
% first goal is to try to see how new maxRbyP works
for cInd = 1:NumCond
   for sInd = 1:NumSubj
       
       rVals(nTaus) = 0;
       zVals(nTaus) = 0;
       DursCell = DurationsCell(cInd,sInd,:);
       DursCell = squeeze(squeeze(DursCell));
       DursCell = DursCell(~cellfun('isempty',DursCell));
       
       allDurs = vertcat(DursCell{:});
       mu1 = mean(allDurs(allDurs(:,2)==1,1));
       mu2 = mean(allDurs(allDurs(:,2)==2,1));
       
       % so basically, if on average, the durations are within 10% of each
       % other
       IntProp = mu1/(mu1+mu2);
       
       % go in and normalize each trial by its mean by type
       if IntProp > thresh_equidom(1) && IntProp < thresh_equidom(2) && length(allDurs)>8
           equidom_condns_by_subj = [equidom_condns_by_subj;sInd,cInd];
           tmp = size(NormalizedDurs);
           
           for rInd = 1:length(DursCell)
               foo=normalizeDurs(DursCell{rInd});
               
               NormalizedDurs{rInd,tmp(2)+1} = foo;
       
           end
       end
       
   end
end
       NormalizedDurs(:,1)=[];
       equidom_condns_by_subj(1,:) = [];
    %% 
    tmp = size(NormalizedDurs);
    % now step through, plot them all on one graph
    %bigFigure; hold on;
    colormap jet
    
    
for nInd = 1:tmp(2)

    
    DursCell = NormalizedDurs(:,nInd);
    DursCell = DursCell(~cellfun('isempty',DursCell));
    
    bar = vertcat(DursCell{:});
    
    foo = equidom_condns_by_subj(nInd,:);
    legText{nInd} = sprintf('s%d DF=%d N=%d',foo(1),DFvals(foo(2)),...
        length(bar(bar(:,1)~=0,1)));
    
    
       for tInd = 1:nTaus
        
            tau = tau_ax(tInd);
        
            [ZrCombined, r11, r22, p11, p22] = ...
    compute_cumhist_corr(DursCell,tau);
            
            rVals(tInd) = tanh(.5*(atanh(abs(r11)) + atanh(abs(r22))));
            zVals(tInd) = ZrCombined;
        
       end
       %h(:,nInd) = semilogx(tau_ax,rVals,':',tau_ax, zVals*.1); mk_Nice_Plot;
       
       h(:,nInd) = semilogx(tau_ax, zVals); mk_Nice_Plot;
       hold on;
       %legend('r_{absCombined}','z (se_r) * .1')
%        title(sprintf('s%d | DF=%d | N=%d | \\mu_1=%.2f | \\mu_2=%.2f',...
%            sInd, DFvals(cInd), length(allDurs),mu1,mu2));
%        
end
   xlabel('tau/mean'); ylabel('correlation strength (Z score)')
   legend(legText); title('r vs tau, normalized equidominant')
           
%end
%%
   


    %%
%     % find mean duration
%     Tbar = mean(vertcat(ARP_data_tot.durs1, ARP_data_tot.durs2));
%     
%     figure;
%     
%     [foo maxRi] = max(rVals);
%     
%     maxRtau = tau_ax(maxRi);
%     
%     semilogx(tau_ax,rVals,'g'); mk_Nice_Plot;
%     
%     title(sprintf('condn %d, subject %d, best ~ %.2f, mnDur = %.2f',i,j,maxRtau,Tbar))
%     legend('r','Location','Best'); xlabel('tau'); ylabel('corr')
%     xlim([min(tau_ax) max(tau_ax)])
%     
%     
%     tau = maxRtau;
%     
%     %i need to functionalize this
%     f = @(tau)compute_combined_cum_history(DursCell,tau);
%     g = @(tau)-f(tau);
%     
%     [tauH fval] = fminsearch(g,maxRtau);
%     
%     %compute_combined_cum_history(DursCell,tauH,1);
%     
%     
%     [r r2 H1 H2 pVals sigFlag H11 H12 lnT1 lnT2 p11 p12] = ...
%         compute_combined_cum_history(DursCell,tauH,1);
%     
%     % split in half, find low H/ high H distr's, find slope of mean
%     
%     cumhist_data_tot(j) = struct('mean_1', mean(exp(lnT1)), 'mean_2',  ...
%         mean(exp(lnT2)), 'k1', ARP_data_tot(j).g1(1), 'k2', ...
%         ARP_data_tot(j).g2(1), 'tau', tauH, ...
%                                 'r', -fval, 'p11',p11, 'p12', p12);
%     
% end
% 
% %%
% figure; plot([cumhist_data_tot.tau],[cumhist_data_tot.r],'.');
% mk_Nice_Plot
% xlabel('tau'); ylabel('r')