function [Durs] = ... r11 r22 h1 h2 T1_mns T2_mns] = ...
    generate_cumhist_func(pars0,nSwitches,bPlot)

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

if ~exist('nSwitches','var')
    nSwitches = 2000;
end
if ~exist('bPlot','var')
    bPlot = 0;
end

Durs(nSwitches, 2) = 0;

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

%[r r2 H1 H2 pVals sigFlag H11 H12 lnT1 lnT2 p11 p22 h y11 y22 r11 r22] = compute_combined_cum_history(Durs,tau,bPlot);
    
