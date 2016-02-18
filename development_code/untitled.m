DursCell = cell(1,3);

for j = 1:data.NumSubj
    
    
    
    %normalize Durs
    for tInd = 1:3
        Durs = data.DurationsCell{i,j,tInd};
        Durs(Durs(:,2)==1,1) = Durs(Durs(:,2)==1,1)/cumhist_data_tot(j).mean_1;
        Durs(Durs(:,2)==2,1) = Durs(Durs(:,2)==2,1)/cumhist_data_tot(j).mean_2;
        DursCell{j,tInd} = Durs;
    end
    
end

foo = size(DursCell);


DursCell = reshape(DursCell,[foo(1) * foo(2), 1]);
    
    
    nDatasets = length(DursCell);
    
    pars.window = 15; pars.step = .1;
    
    for ind = 1:nDatasets
        Durs = DursCell{ind};
        ARP_data(j,ind) = ARP_durs_BUF(Durs,pars);
        titletext = sprintf('subj %d, cond %d, t %d',j,i,ind);
        %plot_ARP_histBUFs(ARP_data(ind),titletext,0);
    end
    
    titletext = sprintf('subj %d, cond %d, all trials',j,i);
    ARP_data_tot(j) = combine_ARP_data(ARP_data(j,:));
    %plot_ARP_histBUFs(ARP_data_tot(j),titletext);
    

    % DATA
    
    
    nTaus = 20;
    tau_ax = logspace(-.5,1.75,nTaus);
    
    
    rVals(nTaus) = 0;
    for tInd = 1:nTaus
        
        tau = tau_ax(tInd);
        
        rVals(tInd) = compute_combined_cum_history(DursCell,tau);
        
        
    end
    
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
    
    norm_cumhist_data_tot = struct('mean_1', mean(exp(lnT1)), 'mean_2',  ...
        mean(exp(lnT2)), 'k1', ARP_data_tot(j).g1(1), 'k2', ...
        ARP_data_tot(j).g2(1), 'tau', tauH, ...
                                'r', -fval, 'p11',p11, 'p12', p12);
    
