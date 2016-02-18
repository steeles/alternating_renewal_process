function [g1 g2 CI_gam1 CI_gam2] = ...
    plot_BUF_and_hists(Durs,BUF,tax,BUFfit,taxfit,bufpars)


bigFigure; subplot(1,2,1);
 plot(tax,BUF,'b',taxfit,BUFfit,'r--');
 axis([0 10 0 1]);  mk_Nice_Plot; %title(['LSE fit for BUF '...
    % [num2str(g1(ind,:)) num2str(g2(ind,:))] ', found ' num2str(bufpars_fit)]);
 
 durs1S = Durs(Durs(:,2)==1,1); durs2S = Durs(Durs(:,2)==2,1);
 subplot(2,2,2);
 plot_gamma_hist_fit(durs1S,bufpars(1:2)); title(['Subject ' num2str(ind)]);
 [g1 CI_gam1] = gamfit(durs1S); %disp(CI_gam1)
 subplot(2,2,4);
 plot_gamma_hist_fit(durs2S,bufpars(3:4))
 [g2 CI_gam2] = gamfit(durs2S); %disp(CI_gam2)