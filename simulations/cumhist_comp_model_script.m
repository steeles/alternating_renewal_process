% cumhist comp model script

[u1 u2 s1 s2 tax n1 n2 iboth pars] = noise_adaptation;

% try messing with this to change nSamples:

tauax = [100 200 300 400 500 600 700 800 900 1000];

tauHats(length(tauax))=0;

for ind = 1:length(tauax)

pars.t_in_seconds = 1000;

% weak WTA - .3

pars.Gamma = 0.7;

pars.sig = .06;
pars.tau_slow = tauax(ind);%2000;

bPlot = 1;

[u1 u2 s1 s2 tax n1 n2 iboth pars] = noise_adaptation(pars,bPlot);
xlim([0 20]);
[T1 T2 Durs] = timecourse2durs(u1, u2, tax);

Durs = [0 0; Durs];

%
[parmhat fval maxr output] = estimate_cumhist_pars(Durs,0,[],1);
tauHats(ind) = parmhat(end);
end

%%

tauH = parmhat(end);


[H1 H2] = compute_H_2(Durs,parmhat(end));
[lnT1 lnT2 H11 H22] = bundle_H_pred_T(Durs,H1,H2);


switchInds = find(abs(diff(u1-u2>0)));

a1_switches = s1(switchInds);
a2_switches = s2(switchInds);

a1_switches = [0 a1_switches]';
a2_switches = [0 a2_switches]';


% third column gives switch times which will be useful
a1_H1 = [a1_switches H1(1:end-1,:)];
a2_H2 = [a2_switches H2(1:end-1,:)];

a11_inds = 1:2:(length(H1)-1);
a22_inds = 2:2:(length(H2)-1);

a1H1_pre_T2 = a1_H1(a11_inds,:);
a2H2_pre_T1 = a2_H2(a22_inds,:);
%%
bigFigure; subplot(211);
plot(a1H1_pre_T2(:,1), a1H1_pre_T2(:,2),'.');
mk_Nice_Plot; xlabel('A1'); ylabel(sprintf('H1, tau = %.2f',tauH));
title('A1 vs H1 at switches into Int');
legend(sprintf(...
    'G=%.1f, tauA=%.1f, sig=%.2f',...
    pars.Gamma,pars.tau_slow,pars.sig));

subplot(212); plot(a2H2_pre_T1(:,1), a2H2_pre_T1(:,2),'.');
mk_Nice_Plot; xlabel('A2'); ylabel('H2');
title('A2 vs H2 at switches into Seg');
%%
figure; plot(a1_H1(:,1), a1_H1(:,2),'.'); mk_Nice_Plot;
title('A1 vs H1 total')
%%
%[parmhat fval maxr output] = estimate_cumhist_pars(Durs,0,[],1);
%%
[parmNull, fnull] = estimate_cumhist_pars(Durs,1);
 

fstat = (fnull - fval)*2;
pVal_cumhist = 1-chi2cdf(fstat,3)

%%
bigFigure; subplot(211); 
plot(H11,lnT1,'.'); mk_Nice_Plot;
u1_pred = parmhat(5) * H11 + parmhat(3);
hold on; plot(H11,u1_pred,'r');
xlabel('H1'); ylabel('lnT1')
set(gca,'Xtick',[0 .5]);

subplot(212); plot(H22,lnT2,'.'); mk_Nice_Plot;
u2_pred = parmhat(6) * H22 + parmhat(4);
hold on; plot(H22,u2_pred,'r');
xlabel('H2'); ylabel('lnT2')
set(gca,'Xtick',[0 .5]);


fstat = (fnull - fval)*2;
pVal_cumhist = 1-chi2cdf(fstat,3)
%% try same thing with mk2gammas

Durs = make_2gamma_distrs([1.5 6],[1.5 6],1000);

[parmhat_arp fval_arp maxr output] = estimate_cumhist_pars(Durs,0,[],1);
[parmNull_arp fnull_arp] = estimate_cumhist_pars(Durs,1);

fstat_arp = (fnull_arp - fval_arp)*2;
pVal_cumhist_arp = 1-chi2cdf(fstat_arp,3)

%% construct joint distr

Hax = .01:.01:1;
yax = .1:.1:15;

joint_mat(length(yax),length(Hax)) = 0;

k1 = parmhat(1);
b1 = parmhat(3);
m1 = parmhat(5);

for ind = 1:length(Hax)
    mux = exp(m1 * Hax(ind) + b1)
    thx = mux/k1;
    
    ypdfx = gampdf(yax,k1,thx);
    
    joint_mat(:,ind) = ypdfx';
end

figure; surf(Hax,yax,joint_mat); xlabel('H'); ylabel('T'); 
    
    

