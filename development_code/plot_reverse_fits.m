% plot_reverse_fits


bigFigure; subplot(1,2,1);
plot(taxta,BUFta,'b',t,BUFfit,'r--');
axis([0 15 0 1]);  mk_Nice_Plot;
%title(['LSE fit for BUF '...
%   num2str(g1) '|' num2str(g2) ', found ' num2str(bufpars_fit)]);

h1 = text(.2,.98,sprintf('underlying parameters %1.2f %1.2f, %1.2f %1.2f',...
    g1(1),g1(2),g2(1),g2(2)));
set(h1,'Color',[0 0 1],'FontSize',18)

h2 = text(.2,.93,sprintf('   least squares fit with %1.2f %1.2f, %1.2f %1.2f',...
    bufpars_fit(1),bufpars_fit(2),bufpars_fit(3),bufpars_fit(4)));
set(h2,'Color',[1 0 0],'FontSize',18)



subplot(2,2,2);

[h_bar1 sc] = plot_gamma_hist_fit(durs1S,bufpars_fit(1:2),g1); %title(['Subject ' num2str(ind)]);
hg1 = text(12,2400,sprintf('true parameters: %1.2f, %1.2f',g1(1),g1(2)));
set(hg1,'Color',[.3 .3 .3],'FontSize',18)
hg2 = text(12,1750,sprintf('found parameters: %1.2f, %1.2f',...
    bufpars_fit(1),bufpars_fit(2)));
set(hg2,'Color',[1 0 0],'FontSize',18)
title('grouped')
set(h_bar1, 'facecolor',[250,188,81]/255)

%text(30,1000,num2str(CI_gam1))
%hold on; plot(xax,g1pdf,'Color',[.3 .3 .3]);
%legend(sprintf('%d samples',length(durs1S)),sprintf('found k = %3f \theta = %3f', ...
%   bufpars_fit(1:2)), sprintf('true k = %3f \theta = %3f',g1));

subplot(2,2,4);
[h_bar2 sc] = plot_gamma_hist_fit(durs2S,bufpars_fit(3:4),g2); %title(['Subject ' num2str(ind)]);
hs1 = text(14,2400,sprintf('true parameters: %1.2f, %1.2f',g2(1),g2(2)));
set(hs1,'Color',[.3 .3 .3],'FontSize',18)
hs2 = text(14,2050,sprintf('found parameters: %1.2f, %1.2f',...
    bufpars_fit(3),bufpars_fit(4)));
set(hs2,'Color',[1 0 0],'FontSize',18)
title('split')
set(h_bar2, 'facecolor', [87,195,226]/255)