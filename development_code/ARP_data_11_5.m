% preamble - gonna start this off with specific data then extract a
 % function outta this script

data=load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat');

%i = condn; j = subj; k = trial;

i = 4; j = 3; k = 2;

% cumhist data struct for just one condition

cumhist_data_tot = struct('mean_1', {}, 'mean_2', {}, ...
                                'k1', {}, 'k2', {}, 'tau', {}, ...
                                'r', {}, 'p11', {}, 'p12', {});

                            
                            
%% get summary stats

% plot k, mean for each subj/condn/trial (small dots) and across trials 
% k, mn, (big dot) and cumhist range (vert line)

% this is James Dataset with DF=5, 8 subjs, 5 reps (!!!)
load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF1_NSJ8_NREPS5.mat');
  


% check out the colors
% figure; mesh(peaks); colormap(cmap);

per_trial_stats1(2, NumReps, NumSubj) = 0;
grand_stats1(NumSubj,4) = 0;
TotDurs1{NumSubj} = [];

per_trial_stats2 = per_trial_stats1;
grand_stats2 = grand_stats1;
TotDurs2{NumSubj} = [];

parmhat(7,NumSubj) = 0;

h = bigFigure; 
cmap = colormap(jet(NumSubj));

for sInd = 1:NumSubj
    for rInd = 1:NumReps
        Durs = DurationsCell{1,sInd,rInd};
        
        durs1 = Durs(Durs(:,2)==1);
        [kth] = gamfit(durs1); mu = mean(durs1);
        per_trial_stats1(:,rInd,sInd) = [kth(1); mu];
        TotDurs1{sInd} = [TotDurs1{sInd}; durs1];
        
        durs2 = Durs(Durs(:,2)==2);
        [kth] = gamfit(durs2); mu = mean(durs2);
        per_trial_stats2(:,rInd,sInd) = [kth(1); mu];
        TotDurs2{sInd} = [TotDurs2{sInd}; durs2];
        
    end
    
%     figure(h);
%     subplot(121); hold on;
%     plot(per_trial_stats1(1,:,sInd), per_trial_stats1(2,:,sInd), '.', ...
%         'Color',cmap(sInd,:));
    
    Durs1t = TotDurs1{sInd};
    kth = gamfit(Durs1t); mu = mean(Durs1t);
    grand_stats1(sInd,1:2) = [kth(1) mu];
    
    Durs2t = TotDurs2{sInd};
    kth = gamfit(Durs2t); mu = mean(Durs2t);
    grand_stats2(sInd,1:2) = [kth(1) mu];

    
%     plot(kth(1), mu, '.', 'Color', cmap(sInd,:), 'MarkerSize', 24)
    
    
%     subplot(122); hold on;
%     plot(per_trial_stats2(1,:,sInd), per_trial_stats2(2,:,sInd), '.', ...
%         'Color',cmap(sInd,:));

    DursCell = {DurationsCell{1,sInd,:}};
    [parmhat_cumhist(:,sInd) fval parsMaxR] = estimate_cumhist_pars(DursCell);
    
    [r r2 H1 H2 pVals sigFlag H11 H12 lnT1 lnT2 p11 p12 y11 y22] = ...
        compute_combined_cum_history(DursCell,parmhat_cumhist(end,sInd),1);
    
    figure(h1); set(gca,'Color',cmap(sInd,:));
    
    text(0.75, 1,sprintf('Subj %d', sInd),'HorizontalAlignment'...
       ,'center','VerticalAlignment', 'top', 'FontSize',20)
    
    grand_stats1(sInd,3) = exp(min(lnT1)); 
    grand_stats1(sInd,4) = exp(max(lnT1));
    grand_stats2(sInd,3) = exp(min(lnT2));
    grand_stats2(sInd,4) = exp(max(lnT2));
    
    
    title(sprintf('Subject %d', sInd));
    
    %for sInd = 1:NumSubj
    legtext1(sInd) = {sprintf('s %d, n = %d',sInd,length(Durs1t))};
    legtext2(sInd) = {sprintf('s %d, n = %d',sInd,length(Durs2t))};

end

figure(h); subplot(121);

set(gca,'NextPlot','replacechildren')
set(gca,'ColorOrder', cmap)
%errorbar(grand_stats1(:,1), grand_stats1(:,2), grand_stats1(:,2)-grand_stats1(:,3), ...
%    grand_stats1(:,4)-grand_stats1(:,2),'k.'); hold on;

gscatter(grand_stats1(:,1), grand_stats1(:,2),legtext1',cmap,'o',14);
plot(squeeze(per_trial_stats1(1,:,:)), squeeze(per_trial_stats1(2,:,:)),...
    '.');
mk_Nice_Plot; axis([0 3 0 100]); xlabel('k'); ylabel('mean')

subplot(122);
set(gca,'NextPlot','replacechildren')
set(gca,'ColorOrder', cmap)
%errorbar(grand_stats2(:,1), grand_stats2(:,2), grand_stats2(:,2)-grand_stats2(:,3), ...
%    grand_stats2(:,4)-grand_stats2(:,2),'k.'); hold on;

gscatter(grand_stats2(:,1), grand_stats2(:,2),legtext2',cmap,'o',14);
plot(squeeze(per_trial_stats2(1,:,:)), squeeze(per_trial_stats2(2,:,:)),...
    '.');
mk_Nice_Plot; axis([0 3 0 100]);

%plot(kth(1), mu, 'o', 'Color', cmap(sInd,:), 'MarkerSize', 24)

%%

%norm_cumhist_data(15,3) = ;

for j = 2%1:data.NumSubj
    
    DursCell = cell(1,3);
    [DursCell{:}] = deal(data.DurationsCell{i,j,:});
    
    nDatasets = length(DursCell);
    
    pars.window = 15; pars.step = .1;
    
    for ind = 1:nDatasets
        Durs = DursCell{ind};
        ARP_data(j,ind) = ARP_durs_BUF(Durs,pars);
        titletext = sprintf('subj %d, cond %d, t %d',j,i,ind);
        rvals(ind) = corrcoef(Durs(1:end-1),Durs(2:end))
        %plot_ARP_histBUFs(ARP_data(ind),titletext,0);
    end
    
    titletext = sprintf('subj %d, cond %d, all trials',j,i);
    ARP_data_tot(j) = combine_ARP_data(ARP_data(j,:));
    %plot_ARP_histBUFs(ARP_data_tot(j),titletext);
    

    % DATA
    
    
    nTaus = 20;
    tau_ax = logspace(-.5,1.75,nTaus);
    
    
    rVals(nTaus) = 0;
    sigRVal(nTaus) = 0;
    
    for tInd = 1:nTaus
        
        tau = tau_ax(tInd);
        
        %[foo rVals(tInd)] = compute_cumhist_corrZ(DursCell,tau);
        [foo rVals(tInd)] = compute_combined_cum_history(DursCell,tau);
        
        
        if foo > 2
            sigRVal(tInd) = 1;
        end
        
        
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
    
    cumhist_data_tot(j) = struct('mean_1', mean(exp(lnT1)), 'mean_2',  ...
        mean(exp(lnT2)), 'k1', ARP_data_tot(j).g1(1), 'k2', ...
        ARP_data_tot(j).g2(1), 'tau', tauH, ...
                                'r', -fval, 'p11',p11, 'p12', p12);
    
end

%%
figure; plot([cumhist_data_tot.tau],[cumhist_data_tot.r],'.');
mk_Nice_Plot
xlabel('tau'); ylabel('r')

figure; plot([cumhist_data_tot.mean_1], [cumhist_data_tot.k1] , '.');
mk_Nice_Plot
xlabel('mean durs1'); ylabel('k1 (shape)');


figure; plot([cumhist_data_tot.mean_2], [cumhist_data_tot.k2] , '.');
mk_Nice_Plot
xlabel('mean durs2'); ylabel('k2 (shape)');

%%


for j = 1:data.NumSubj
    
    DursCell = cell(1,3);
    
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
    


%%
h = figure;
set(gcf, 'Position', [1 1 1080 720]); % Maximize figure

lo_g1s = vertcat(cumhist_data_tot.lo_g1);
hi_g1s = vertcat(cumhist_data_tot.hi_g1);

lo_g2s = vertcat(cumhist_data_tot.lo_g2);
hi_g2s = vertcat(cumhist_data_tot.hi_g2);

subplot(1,2,1);
plot(lo_g1s(:,1), lo_g1s(:,2), 'b.', hi_g1s(:,1), hi_g1s(:,2), 'r.')
mk_Nice_Plot
xlabel('k'); ylabel('th'); title('grouped gamma pars')
legend('low H1', 'high H1');

subplot(1,2,2);
plot(lo_g2s(:,1), lo_g2s(:,2), 'b.', hi_g2s(:,1), hi_g2s(:,2), 'r.')
mk_Nice_Plot
xlabel('k'); ylabel('th'); title('split gamma pars')
legend('low H1', 'high H1');

g1_diffs = hi_g1s - lo_g1s;

g2_diffs = hi_g2s - lo_g2s;

figure; subplot(1,2,1);
plot(g1_diffs(:,1),g1_diffs(:,2),'.');
xlabel('k'); ylabel('th'); title('grouped gamma pars hi H1 - lo H1')

subplot(1,2,2);
plot(g2_diffs(:,1), g2_diffs(:,2),'.');
xlabel('k'); ylabel('th'); title('split gamma pars hi H1 - lo H1')

mean_diffs_g1 = g1_diffs(:,1) .* g1_diffs(:,2);
mean_diffs_g2 = g2_diffs(:,1) .* g2_diffs(:,2);

figure; subplot(1,2,1); hist(mean_diffs_g1); title('changes in mean T1 for hi vs lo H1')
subplot(1,2,2); hist(mean_diffs_g2); title('changes in mean T2 for hi vs lo H1')


%% check if ARP shows cumhist

DursCell = []; DursCell{1} = make_2gamma_distrs([1 2], [2 1], 200);


%%%%%
rVals(nTaus) = 0;
sig_rVals(nTaus) = 0;



for tInd = 1:nTaus
    
    tau = tau_ax(tInd);
    
    [rVals(tInd), ~,~,~,~, sig_rVals(tInd)] = compute_combined_cum_history(DursCell,tau);
    
    
end

% find mean duration
Tbar = mean(vertcat(ARP_data_tot.durs1, ARP_data_tot.durs2));

figure;


[foo maxRi] = max(rVals);

maxRtau = tau_ax(maxRi);

semilogx(tau_ax,rVals,'g'); mk_Nice_Plot; hold on;
semilogx(tau_ax(logical(sig_rVals)),rVals(logical(sig_rVals)),'r','LineWidth',4)

title(sprintf('condn %d, subject %d, best ~ %.2f, mnDur = %.2f',i,j,maxRtau,Tbar))
legend('r','Location','Best'); xlabel('tau'); ylabel('corr')
xlim([min(tau_ax) max(tau_ax)])

tau = 1;

%i need to functionalize this
f = @(tau)compute_combined_cum_history(DursCell,tau);
g = @(tau)-f(tau);

[tauH fval] = fminsearch(g,maxRtau);

compute_combined_cum_history(DursCell,tauH,1);


%% scramble durs/Hs

T2scram = T2(randperm(length(T2)));

H12scram = H12(randperm(length(H12)));
compute_corr(H12scram,T2scram)
[r p] = corrcoef([H12scram,T2scram])


