% preamble - gonna start this off with specific data then extract a
% function outta this script

data=load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat');

%i = condn; j = subj; k = trial;

i = 8; j = 10; k = 2;

DursCell = cell(1,3);
[DursCell{:}] = deal(data.DurationsCell{i,j,:});

nDatasets = length(DursCell);
%%
pars.window = 15; pars.step = .1;

for ind = 1:nDatasets
    Durs = DursCell{ind};
    ARP_data(ind) = ARP_durs_BUF(Durs,pars);
    titletext = sprintf('s %d, c %d, t %d',i,j,ind);
    plot_ARP_histBUFs(ARP_data(ind),titletext,0);
end

titletext = sprintf('s %d, c %d, all trials',i,j);
ARP_data_tot = combine_ARP_data(ARP_data);
plot_ARP_histBUFs(ARP_data_tot,titletext);



%% DATA

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

compute_combined_cum_history(DursCell,tauH,1);


[r r2 H1 H2 pVals sigFlag H11 H12 lnT1 lnT2] = compute_combined_cum_history(DursCell,tauH);

% split in half, find low H/ high H distr's, find slope of mean
[h11_sort ind] = sort(H11);
middle = round(length(ind)/2);
lowInds = ind(1:middle-1);
hiInds = ind(middle:end);

T1_lowH1 = exp(lnT1(lowInds));
T1_hiH1 = exp(lnT1(hiInds));

T2_lowH1 = exp(lnT2(lowInds));
T2_hiH1 = exp(lnT2(hiInds));

h(4) = NaN;

[h(1) foo foo lo_g1] = goodness_of_gamma_fit(T1_lowH1);

[h(2) foo foo hi_g1] = goodness_of_gamma_fit(T1_hiH1);

[h(3) foo foo lo_g2] = goodness_of_gamma_fit(T2_lowH1);

[h(4) foo foo hi_g2] = goodness_of_gamma_fit(T2_hiH1);


h = figure; 
set(gcf, 'Position', [1 1 1080 720]); % Maximize figure


    
    

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


%%

top = sum((groupedMat(:,1) - mean(groupedMat(:,1))) .* (groupedMat(:,3) - mean(groupedMat(:,3))));

bottom = std(groupedMat(:,1)) * std(groupedMat(:,3));

top/bottom

%%

i = 7; j = 14; k = 2;

DursCell = cell(1,3);
[DursCell{:}] = deal(data.DurationsCell{i,j,:});

nDatasets = length(DursCell);

Durs1t = [];
Durs2t = [];

for ind = 1:nDatasets
    Durs = DursCell{ind};
    Durs1t = [Durs1t; Durs(Durs(:,2)==1,1)];
    Durs2t = [Durs2t; Durs(Durs(:,2)==2,1)];
end

axmax = max([Durs1t(:,1);Durs2t(:,1)])
g1 = gamfit(Durs1t); g2 = gamfit(Durs2t);

figure; subplot(211);
histfit(Durs1t,20,'gamma'); xlim([0 axmax])
mk_Nice_Plot;
title(sprintf('DF= %d subj %d',data.DFvals(i),j))

subplot(212);
histfit(Durs2t,20,'gamma'); xlim([0 axmax])
mk_Nice_Plot
legend(sprintf('n = %d',length(Durs2t)))

    