% ARP_data script test hypotheses - 

% do i get back the same distribution?

% for now I'm going to ignore MaxR

% get summary stats

% plot k, mean for each subj/condn/trial (small dots) and across trials 
% k, mn, (big dot) and cumhist range (vert line)

% this is James Dataset with DF=5, 8 subjs, 5 reps (!!!)
load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF1_NSJ8_NREPS5.mat');


bPlot = 0;


% gamma pars
per_trial_stats1(2, NumReps, NumSubj) = 0;
% gamma pars with min/max model mean
grand_stats1(NumSubj,4) = 0;
TotDurs1{NumSubj} = [];

per_trial_stats2 = per_trial_stats1;
grand_stats2 = grand_stats1;
TotDurs2{NumSubj} = [];

% MLE cumhist pars
parmhat_cumhist(7,NumSubj) = 0;

fval_cumhist(NumSubj) = 0;

MaxR_parmhat(7,NumSubj) = 0;

ARP_parmhat(7,NumSubj) = 0;
fval_ARP(NumSubj) = 0;

rvals(2,NumSubj) = 0;

% i'm gonna want to do autocorr's on these by sample and the zero order holds
% i could also sum over the continuous H functions

H1cell{NumReps,NumSubj} = [];
H2cell{NumReps,NumSubj} = [];

mnscell1{NumReps,NumSubj} = [];
mnscell2{NumReps,NumSubj} = [];


%% Basic Stats
if bPlot
    h = bigFigure;
    cmap = colormap(jet(NumSubj));
end

for sInd = 1:NumSubj
    for rInd = 1:NumReps
        
        % gamma pars for the ARP
        
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
    
    % basic grand stats on distributions
    Durs1t = TotDurs1{sInd};
    kth = gamfit(Durs1t); mu = mean(Durs1t);
    grand_stats1(sInd,1:2) = [kth(1) mu];
    
    Durs2t = TotDurs2{sInd};
    kth = gamfit(Durs2t); mu = mean(Durs2t);
    grand_stats2(sInd,1:2) = [kth(1) mu];
    
    
    [H1cell(:,sInd) H2cell(:,sInd) mnsCell1(:,sInd) mnsCell2(:,sInd)] = ...
        find_Hs_and_mns(DursCell,parmhat_cumhist(:,sInd));
    
    mns1 = vertcat(mnsCell1{:,sInd}); mns2 = vertcat(mnsCell2{:,sInd});

    % not sure about this;
    grand_stats1(sInd,3) = min(mns1);
    grand_stats1(sInd,4) = max(mns1);
    grand_stats2(sInd,3) = min(mns2);
    grand_stats2(sInd,4) = max(mns2);
end

%% Cumhist stats; takes awhile

for sInd = 1:NumSubj
%%s    
    % now we start to look at cumhist model
    DursCell = {DurationsCell{1,sInd,:}};
    [parmhat_cumhist(:,sInd) fval_cumhist(sInd) MaxR_parmhat(:,sInd) output] = ...
        estimate_cumhist_pars(DursCell);
    
    % null model -- actually, the k's and betas from this should match with
    % the grand distributions/ marginals of the joint distr with H
    [ARP_parmhat(:,sInd) fval_ARP(sInd)] = estimate_cumhist_pars(DursCell,1);
    
    % look at some of the cumhist stats for this model. some questions we
    % might ask about these- are the r's significantly different from 0?
    [r r2 H1 H2 pVals sigFlag H11 H12 lnT1 lnT2 p11 p22 h1 y11 y22 r11 r22] = ...
        compute_combined_cum_history(DursCell,parmhat_cumhist(end,sInd),bPlot);
    
    rvals(:,sInd) = [r11; r22];
%%    
    
    if bPlot
        figure(h1);
        
        text(0.75, 1,sprintf('Subj %d', sInd),'HorizontalAlignment'...
            ,'center','VerticalAlignment', 'top', 'FontSize',20)
        title(sprintf('Subject %d', sInd));
        
        legtext1(sInd) = {sprintf('s%d, n = %d',sInd,length(Durs1t))};
        legtext2(sInd) = {sprintf('s%d, n = %d',sInd,length(Durs2t))};
    end
    
end

if bPlot
    figure(h); subplot(121);
    
    set(gca,'NextPlot','replacechildren')
    set(gca,'ColorOrder', cmap)
    errorbar(grand_stats1(:,1), grand_stats1(:,2), grand_stats1(:,2)-grand_stats1(:,3), ...
        grand_stats1(:,4)-grand_stats1(:,2),'k.'); hold on;
    
    gscatter(grand_stats1(:,1), grand_stats1(:,2),legtext1',cmap,'o',14);
    plot(squeeze(per_trial_stats1(1,:,:)), squeeze(per_trial_stats1(2,:,:)),...
        '.');
    mk_Nice_Plot; axis([0 3 0 40]); xlabel('k'); ylabel('mean')
    title('grouped')
    
    subplot(122);
    set(gca,'NextPlot','replacechildren')
    set(gca,'ColorOrder', cmap)
    errorbar(grand_stats2(:,1), grand_stats2(:,2), grand_stats2(:,2)-grand_stats2(:,3), ...
        grand_stats2(:,4)-grand_stats2(:,2),'k.'); hold on;
    
    gscatter(grand_stats2(:,1), grand_stats2(:,2),legtext2',cmap,'o',14);
    plot(squeeze(per_trial_stats2(1,:,:)), squeeze(per_trial_stats2(2,:,:)),...
        '.');
    mk_Nice_Plot; axis([0 3 0 40]);
    xlabel('k'); title('split')
end
%% for my next trick I will use the pars from the different models to check
%  what the deal is with the distributions and the r values

rvals_gen(2,NumSubj) = 0;

for sInd = 1:NumSubj
    
    MLE_pars = parmhat_cumhist(:,sInd);
    %MaxR_pars = MaxR_parmhat(:,sInd);
    
    [MLE_regen_Durs r11 r22] = generate_cumhist_func(MLE_pars,...
        length(TotDurs1{sInd}),1);
    gcf; text(0.75, 1,sprintf('Subj %d regen', sInd),'HorizontalAlignment'...
       ,'center','VerticalAlignment', 'top', 'FontSize',20)
    rvals_gen(:,sInd) = [r11; r22];
    durs1_regen = MLE_regen_Durs(MLE_regen_Durs(:,2)==1,1);
    durs2_regen = MLE_regen_Durs(MLE_regen_Durs(:,2)==2,1);
    
    %MaxR_regen_Durs = generate_cumhist_func(
   
    h2 = bigFigure; 
    
    ax_max = max([Durs1t; Durs2t]) * 1.2;
    
    subplot(221); g1_real = gamfit(TotDurs1{sInd});
    plot_gamma_hist_fit(TotDurs1{sInd},g1_real); 
    xlabel('grouped'); ylabel('observed (expt)')
    title(sprintf('k=%.1f, th=%.1f, r=%.2f',g1_real(1), ...
        g1_real(2), rvals(1,sInd)));
    xlim([0 ax_max])
    
    subplot(222); g2_real = gamfit(TotDurs2{sInd});
    plot_gamma_hist_fit(TotDurs2{sInd}, g2_real);
    xlabel('split');
    title(sprintf('k=%.1f, th=%.1f, r=%.2f',g2_real(1), ...
        g2_real(2), rvals(2,sInd)));
    xlim([0 ax_max])
    
    g1_gen = gamfit(durs1_regen);
    subplot(223); plot_gamma_hist_fit(durs1_regen, g1_gen);
    ylabel('cumhist model generated')
    title(sprintf('k=%.1f, th=%.1f,  r=%.2f',g1_gen(1), ...
        g1_gen(2),  rvals_gen(1,sInd)));
    xlim([0 ax_max])
    
    g2_gen = gamfit(durs2_regen);
    subplot(224); plot_gamma_hist_fit(durs2_regen, g2_gen);
    title(sprintf('k = %.2f, th = %.2f, r=%.2f',g2_gen(1), g2_gen(2),...
        rvals_gen(2,sInd)));
    xlim([0 ax_max])
    
    text(0.75, 1,sprintf('Subj %d regen', sInd),'HorizontalAlignment'...
       ,'center','VerticalAlignment', 'top', 'FontSize',20)
    
end
%%

% split this into I->S and S->I

ItoS_lag1_corr(NumSubj,NumReps) = 0;
StoI_lag1_corr(NumSubj,NumReps) = 0;

for sInd = 1:NumSubj
    for rInd = 1:NumReps
        Durs = DurationsCell{1,sInd,rInd};

        sampLen = length(Durs(:,2));
        
        IntInds = find(Durs(:,2)==1);
        IntPreInds = IntInds(IntInds<sampLen);
        SegInds = find(Durs(:,2)==2);
        SegPreInds = SegInds(SegInds<sampLen);
        
        Ipre = Durs(IntPreInds,1);
        Spost = Durs(IntPreInds+1,1);
        
        Spre = Durs(SegPreInds,1);
        Ipost = Durs(SegPreInds+1,1);
        
  

        rtmp = corrcoef(Ipre,Spost);
        ItoS_lag1_corr(sInd,rInd) = rtmp(1,2);
        rtmp = corrcoef(Spre,Ipost);
        StoI_lag1_corr(sInd,rInd) = rtmp(1,2);
    end
end

 figure;       
ItoS_lag1_corrVec = reshape(ItoS_lag1_corr,1,NumSubj*NumReps);
figure; subplot(211);
hist(ItoS_lag1_corrVec); %mk_Nice_Hist
xlabel('lag 1 corrs')
ylabel('trials'); title('I -> S');

StoI_lag1_corrVec = reshape(StoI_lag1_corr,1,NumSubj*NumReps);
subplot(212); hist(StoI_lag1_corrVec); %mk_Nice_Hist
title('S -> I');

%%
slopes = [parmhat_cumhist(5,:) parmhat_cumhist(6,:)];
taus = [parmhat_cumhist(7,:)];

figure; subplot(131); hist(slopes);mk_Nice_Plot; title('slopes (lnT vs H)'); 
subplot(132); hist(taus); mk_Nice_Plot; title('taus');
subplot(133); hist(reshape(rvals,1,numel(rvals))); 
mk_Nice_Plot; title('r vals (lnT vs H)')

%% twitchy data

s8_durs1 = TotDurs1{8};
s8_H1 = vertcat(H1cell{:,8});

s8_durs2 = TotDurs2{8};
s8_H2 = vertcat(H2cell{:,8});

figure; subplot(211); hist(s8_H1((s8_H1(:,1)<.5),1)); title('H1')
subplot(212); hist(s8_durs1(s8_durs1<1)); title('twitchy durs s8')

s7_durs1 = TotDurs1{7};
s7_durs2 = TotDurs2{7};

figure; subplot(211); hist(s7_durs1(s7_durs1<1)); title('s7 short durs 1')
subplot(212); hist(s7_durs2(s7_durs2<1)); title('s7 short durs 2')

%% look at this for all subjs

for sInd = 1:NumSubj
    durs1 = TotDurs1{sInd};
    durs2 = TotDurs2{sInd};
    
    figure; subplot(211); hist(durs1(durs1<1)); xlabel('duration (s)')
    title(sprintf('s%d twitch',sInd))
    subplot(212); hist(durs2(durs2<1)); 
end

%% start to look at likelihood landscape
for sInd = 1:NumSubj
    pars = parmhat_cumhist(:,sInd);
    DursCell = {DurationsCell{1,sInd,:}};
    make_likelihood_surface(DursCell, pars);
    title(sprintf('s%d likelihood', sInd))
end


%% investimigation
% pars for null model should match those for gamfit



