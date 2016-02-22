

% plot_lnT_vs_H(H11,lnT1,H22,lnT2,parmhat,pars0)
% still haven't added functionality to see H1_true for generating pars
% so pars0 is useless right now

function plot_lnT_vs_H(H11,lnT1,H22,lnT2,parmhat,pars0);



bigFigure; subplot(211); 
plot(H11,lnT1,'.'); mk_Nice_Plot;
u1_pred = parmhat(5) * H11 + parmhat(3);
hold on; 

plot(H11,u1_pred,'r');
xlabel('H1'); ylabel('lnT1')
set(gca,'Xtick',[0 .9]);

subplot(212); plot(H22,lnT2,'.'); mk_Nice_Plot;
u2_pred = parmhat(6) * H22 + parmhat(4);
hold on; plot(H22,u2_pred,'r');
xlabel('H2'); ylabel('lnT2')
set(gca,'Xtick',[0 .9]);