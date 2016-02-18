% preamble - gonna start this off with specific data then extract a
 % function outta this script

data=load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat');

%i = condn; j = subj; k = trial;

i = 4; j = 3; k = 2;

for j = 1:data.NumSubj
    
    DursCell = cell(1,3);
    [DursCell{:}] = deal(data.DurationsCell{i,j,:});
    
    nDatasets = length(DursCell);
    
    pars.window = 15; pars.step = .1;
    
    for ind = 1:nDatasets
        Durs = DursCell{ind};
        ARP_data(ind) = ARP_durs_BUF(Durs,pars);
        titletext = sprintf('s %d, c %d, t %d',j,i,ind);
        %plot_ARP_histBUFs(ARP_data(ind),titletext,0);
    end
    
    titletext = sprintf('s %d, c %d, all trials',j,i);
    ARP_data_tot(j) = combine_ARP_data(ARP_data);
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
    
    
    [r r2 H1 H2 pVals sigFlag H11 H12 lnT1 lnT2] = compute_combined_cum_history(DursCell,tauH,1);
    
    % split in half, find low H/ high H distr's, find slope of mean
    [h11_sort ind] = sort(H11);
    middle = round(length(ind)/2);
    lowInds = ind(1:middle-1);
    hiInds = ind(middle:end);
    
    T1_lowH1 = exp(lnT1(lowInds));
    T1_hiH1 = exp(lnT1(hiInds));
    
    [h12_sort ind] = sort(H12);
    middle = round(length(ind)/2);
    lowInds = ind(1:middle-1);
    hiInds = ind(middle:end);
    
    T2_lowH1 = exp(lnT2(lowInds));
    T2_hiH1 = exp(lnT2(hiInds));
    
    bFit(4) = NaN;
    
    [bFit(1) foo foo lo_g1] = goodness_of_gamma_fit(T1_lowH1);
    
    [bFit(2) foo foo hi_g1] = goodness_of_gamma_fit(T1_hiH1);
    
    [bFit(3) foo foo lo_g2] = goodness_of_gamma_fit(T2_lowH1);
    
    [bFit(4) foo foo hi_g2] = goodness_of_gamma_fit(T2_hiH1);
    
    if 0
        
        h = figure;
        set(gcf, 'Position', [1 1 1080 720]); % Maximize figure
        
        subplot(2,2,3);
        plot_gamma_hist_fit(T1_lowH1, lo_g1);
        xlabel('durs1')
        ylabel('low H1')
        title(sprintf('k = %.2f, th = %.2f', lo_g1(1), lo_g1(2)));
        
        subplot(2,2,1);
        plot_gamma_hist_fit(T1_hiH1, hi_g1);
        ylabel('high H1')
        title(sprintf('k = %.2f, th = %.2f', hi_g1(1), hi_g1(2)));
        
        subplot(2,2,4);
        plot_gamma_hist_fit(T2_lowH1, lo_g2);
        xlabel('durs2')
        title(sprintf('k = %.2f, th = %.2f', lo_g2(1), lo_g2(2)));
        
        subplot(2,2,2);
        plot_gamma_hist_fit(T2_hiH1, hi_g2);
        title(sprintf('k = %.2f, th = %.2f', hi_g2(1), hi_g2(2)));
        
    end
    cumhist_data_tot(j) = v2struct(lo_g1, hi_g1, lo_g2, hi_g2);
    
end

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


