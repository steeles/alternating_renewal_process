% trying to make a principled way to get a good histogram that has the
% same heights as the underlying pdf (density estimator) and that has a
% good number of bins (based on scott's choice)
% http://en.wikipedia.org/wiki/Histogram#Number_of_bins_and_width
%
% source: http://www.mathwave.com/articles/create-use-histograms.html
% [count,bin] = mk_Nice_Hist(samples)

function [count,bin] = mk_Nice_Hist(samples)

standard_dev = std(samples);

% scott's choice
h = 3.5 * standard_dev / length(samples)^(1/3);
nBins = ceil(range(samples)/h);
[count,bin] = hist(samples,nBins);
count_norm = count/sum(count);

binWidth = max(unique(diff(bin)));

count = count_norm/binWidth;
bar(bin,count,1)

%set(gca,'fontsize',16,'fontweight','bold')
set(gca,'box','off')