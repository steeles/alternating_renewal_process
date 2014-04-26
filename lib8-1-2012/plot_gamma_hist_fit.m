% plot_gamma_hist_fit(durs,g)

function [h_bar scale h_plt] = plot_gamma_hist_fit(durs,g,gtrue)

[count bin] = hist(durs); h_bar = bar(bin,count,1); hold on;
scale = max(unique(diff(bin)));
x = linspace(0,max(durs)+2,200);
y = gampdf(x,g(1),(g(2)));

if exist('gtrue','var')
    y2 = gampdf(x,gtrue(1),gtrue(2));
    plot(x,y2*length(durs)*scale,'Color',[.3,.3,.3])
end

hold on; h_plt = plot(x,y*length(durs)*scale,'r--'); 

mk_Nice_Plot;
%legend([num2str(length(durs)) ' samples'],['k = ' num2str(g(1),3) ' \theta = ' num2str(g(2),3)]);
xlabel('duration (s)')
% should I add the mean? or leave that to a separate analysis?