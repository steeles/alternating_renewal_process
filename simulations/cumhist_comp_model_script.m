% cumhist comp model script

[u1 u2 s1 s2 tax n1 n2 iboth pars] = noise_adaptation;

pars.t_in_seconds = 2000;
pars.Gamma = 0.7;
pars.sig = .07;

bPlot = 1;

[u1 u2 s1 s2 tax n1 n2 iboth pars] = noise_adaptation(pars,bPlot);

[T1 T2 Durs] = timecourse2durs(u1, u2, tax);

Durs = [0 0; Durs];

[parmhat fval maxr output] = estimate_cumhist_pars(Durs);


[parmNull fnull] = estimate_cumhist_pars(Durs,1);

[H1 H2] = compute_H_2(Durs,parmhat(end));
[lnT1 lnT2 H11 H22] = bundle_H_pred_T(Durs,H1,H2);

bigFigure; subplot(211); 
plot(H11,lnT1,'.'); mk_Nice_Plot;
u1_pred = parmhat(5) * H11 + parmhat(3);
hold on; plot(H11,u1_pred,'r');
xlabel('H1'); ylabel('lnT1')
set(gca,'Xtick',[0 .9]);

subplot(212); plot(H22,lnT2,'.'); mk_Nice_Plot;
u2_pred = parmhat(6) * H22 + parmhat(4);
hold on; plot(H22,u2_pred,'r');
xlabel('H2'); ylabel('lnT2')
set(gca,'Xtick',[0 .9]);


fstat = (fnull - fval)/2;
pVal_cumhist = chi2pdf(fstat,3)



