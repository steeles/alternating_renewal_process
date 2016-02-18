% make 2 gamma distrs with cumhist

clear all;

data=load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat');

% from i = 4, j = 2

i = 4; j = 2;


    

k1 = .97;
th1_hat = 5.14;
k2 = 1.48;
th2_hat = 4;

tau = 2.07;

b1 = 1.7;
m1 = -3.4;
b2 = .32;
m2 = 1.02;

% find th01 by lnT(0) = mx + B
th1 = exp(b1)/k1;
th2 = exp(b2)/k2;

DursCell = cell(1,3);
[DursCell{:}] = deal(data.DurationsCell{i,j,:});
[r r2 H1 H2 pVals sigFlag H11 H12 lnT1_data lnT2_data p11 p12] = ...
        compute_combined_cum_history(DursCell,tau,1);
   
    
durs1_true = exp(lnT1_data); durs2_true = exp(lnT2_data);

lnT1_base = log(mean(durs1_true));
lnT2_base = log(mean(durs2_true));

h1_mn = (lnT1_base - b1)/m1
h2_mn = (lnT2_base - b2)/m2
    
    
    

nSwitches = 1000;

H1(nSwitches) = 0;
Durs(nSwitches,2) = 0;

% we're also curious what values the generator parameters take on
T1_mns(round(nSwitches/2))=0;
T2_mns(round(nSwitches/2))=0;

Durs(2,:) = [gamrnd(k1, th1) 1];
Durs(3,:) = [gamrnd(k2, th2) 2];

for ind = 4:nSwitches % first row is [0 0]
    
    H1 = compute_H_2(Durs(1:ind-1,:),tau);
    
    %keyboard;
    if iseven(ind)

        E_lnT1 = b1 + m1*H1(ind-1,1);
        th1_new = exp(E_lnT1)/k1;
        T1_mns(ind) = th1_new*k1;
        Durs(ind,:) = [gamrnd(k1, th1_new) 1];
        
    else
        E_lnT2 = b2 + m2* H1(ind-1,1);
        th2_new = exp(E_lnT2)/k2;
        T2_mns(ind) = th2_new*k2;
        Durs(ind,:) = [gamrnd(k2, th2_new) 2];
        
    end
    
end

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



        