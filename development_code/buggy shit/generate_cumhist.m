% make 2 gamma distrs with cumhist

clear all;


% from i = 4, j = 2



k1 = 2;
th1_hat = 5.14;
k2 = 1.48;
th2_hat = 4;

tau = 2.07;

b1 = .7;
m1 = 1.4;
b2 = .32;
m2 = 1.02;

pars0 = [k1 k2 b1 b2 m1 m2 tau];
%%
k1 = pars0(1);
k2 = pars0(2);
b1 = pars0(3);
b2 = pars0(4);
m1 = pars0(5);
m2 = pars0(6);
tau = pars0(7);

% find th01 by lnT(0) = mx + B
th1 = exp(b1)/k1;
th2 = exp(b2)/k2;

nSwitches = 2000;

% H1(nSwitches) = 0;
% H2(nSwitches) = 0;
Durs(nSwitches,2) = 0;

% we're also curious what values the generator parameters take on
T1_mns(round(nSwitches/2))=0;
T2_mns(round(nSwitches/2))=0;

Durs(2,:) = [gamrnd(k1, th1) 1];
Durs(3,:) = [gamrnd(k2, th2) 2];

for ind = 4:nSwitches % first row is [0 0]
    
    [H1 H2] = compute_H_2(Durs(1:ind-1,:),tau);
    
    %keyboard;
    if mod(ind,2)==0

        E_lnT1 = b1 + m1*H1(ind-1,1);
        th1_new = exp(E_lnT1)/k1;
        T1_mns(ind) = th1_new*k1;
        Durs(ind,:) = [gamrnd(k1, th1_new) 1];
        
    else
        E_lnT2 = b2 + m2* H2(ind-1,1);
        th2_new = exp(E_lnT2)/k2;
        T2_mns(ind) = th2_new*k2;
        Durs(ind,:) = [gamrnd(k2, th2_new) 2];
        
    end
    
end
%%
[h1 h2] = compute_H_2(Durs,tau);

% durs1 should depend on H1, durs2 should depend on H2 BEFORE the switch

mat = [h1(3:end-2,1) h2(3:end-2,1) Durs(4:end-1,:)];

groupedInds = mat(:,4)==1; splitInds = mat(:,4)==2;

groupedMat = mat(groupedInds,:); splitMat = mat(splitInds,:);

[h1Sort sortOrder1] = sort(groupedMat(:,1));
[h2Sort sortOrder2] = sort(splitMat(:,1));

H1_Dur_Sort = groupedMat(sortOrder1,[1 3]);
H2_Dur_Sort = splitMat(sortOrder2,[2 3]);

h1vec = H1_Dur_Sort(:,1); h2vec = H2_Dur_Sort(:,1);
% split into 10 equally spaced parts and find expected distr and actual
% stats
nBins = 5;
edges1 = linspace(min(h1vec), max(h1vec), nBins+1);
edges2 = linspace(min(h2vec), max(h2vec), nBins+1);

bigFigure;
for ind = 1:nBins
    LB = edges1(ind); UB = edges1(ind+1);
    h1X = (LB + UB)/2;
    u1_pred = exp(m1 * h1X + b1);
    gampars_pred = [k1 u1_pred/k1];
    
    inds1 = h1vec >= LB & h1vec <= UB;
    durs1_batch = H1_Dur_Sort(inds1 ,2);
    subplot(2,nBins,ind); 
    plot_gamma_hist_fit(durs1_batch,gampars_pred);
    title(sprintf('H1 = %.2f',h1X))
    
    LB2 = edges2(ind); UB2 = edges2(ind+1);
    h2X = (LB2 + UB2)/2;
    u2_pred = exp(m2 * h2X + b2);
    gampars_pred2 = [k2 u2_pred/k2];
    
    inds2 = h2vec >= LB2 & h2vec <= UB2;
    durs2_batch = H2_Dur_Sort(inds2 ,2);
    subplot(2,nBins,ind+nBins); 
    plot_gamma_hist_fit(durs2_batch,gampars_pred2);
    title(sprintf('H2 = %.2f',h2X))
    
end

%%
[parmhat fval] = estimate_cumhist_pars(Durs);

lnT1_recovered_pred = parmhat(5) * h1vec + parmhat(3);
lnT2_recovered_pred = parmhat(6) * h2vec + parmhat(4);

%[k1; k2; b1; b2; m1; m2; tau];

lnT1_actual = pars0(5) * h1vec + parmhat(3);
lnT2_actual = pars0(6) * h2vec + parmhat(4);

bigFigure; subplot(211); 
plot(h1vec, log(H1_Dur_Sort(:,2)), '.')
hold on; plot(h1vec,lnT1_recovered_pred, 'r');
plot(h1vec, lnT1_actual, 'g');
mk_Nice_Plot; xlabel('H1'); ylabel('ln T1'); 
title(sprintf('g: %.2f , r: %.2f|',pars0, parmhat))
legend(sprintf('n=%d', nSwitches/2), 'Location', 'Best')

subplot(212); plot(h2vec(:,1), log(H2_Dur_Sort(:,2)), '.');
hold on; plot(h2vec,lnT2_recovered_pred, 'r');
plot(h2vec, lnT2_actual, 'g');
mk_Nice_Plot; xlabel('H2'); ylabel('ln T2'); 
legend('data','recovered', 'generating', 'Location', 'best')
%%

i = 4; j = 2;

data=load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat');

DursCell = cell(1,3);
[DursCell{:}] = deal(data.DurationsCell{i,j,:});
[r r2 H1 H2 pVals sigFlag H11 H12 lnT1_data lnT2_data p11 p12] = ...
        compute_combined_cum_history(DursCell,tau,1);
   %%

   
    
durs1_true = exp(lnT1_data); durs2_true = exp(lnT2_data);

lnT1_base = log(mean(durs1_true));
lnT2_base = log(mean(durs2_true));

h1_mn = (lnT1_base - b1)/m1
h2_mn = (lnT2_base - b2)/m2
    
% i think here is where the indexing gets screwy... lets change it up

% actually it's easier to follow the same procedure as from
% compute_combined_cumhist- make a matrix that forces the causality with
% indexing, and then sample from that by durs ID
H1 = compute_H_2(Durs,tau,1);

mat = [H1(3:end-1,1) Durs(4:end,:)]; % chop off first durs, make H predict Dur

grouped_mat = mat(mat(:,3)==1,1:2); 
H11 = grouped_mat(:,1); 
lnT1 = log(grouped_mat(:,2)); 

split_mat = mat(mat(:,3)==2,1:2);
H12 = split_mat(:,1);
lnT2 = log(split_mat(:,2));

r11 = corrcoef(lnT1, H11)
r12 = corrcoef(lnT2,H12)

[BUF tax] = make_switchTriggeredBUF(Durs(2:end,:),.01,15);
figure; plot(tax,BUF)

figure; subplot(211); plot(H11,lnT1,'.'); xlabel('lnT1 vs H1')
subplot(212); plot(H12,lnT2,'.'); xlabel('lnT2 vs H1')

figure; subplot(121); hist(T1_mns); title('T1 means');
hold on; plot([k1 * th1 k1 * th1], [0 nSwitches/5],'r')

subplot(122); hist(T2_mns); title('T2 means')
hold on; plot([k2 * th2 k2 * th2], [0 nSwitches/5],'r')

durs1 = exp(lnT1); durs2 = exp(lnT2);

figure; subplot(221); plot_gamma_hist_fit(durs1,gamfit(durs1),[k1 th1_hat]);
subplot(222); plot_gamma_hist_fit(durs2,gamfit(durs2), [k2 th2_hat]);

% compare with originating data:

subplot(223); plot_gamma_hist_fit(durs1_true,[k1 th1_hat]);
subplot(224); plot_gamma_hist_fit(durs2_true,[k2 th2_hat]);



        