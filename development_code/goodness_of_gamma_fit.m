function [h p ksstat gampars]= goodness_of_gamma_fit(data,gampars,bPlot,alpha)

if ~exist('gampars','var')
    gampars = gamfit(data);
end

[propDistr] = gamcdf(data,gampars(1),gampars(2));
cdfMatrix = [data propDistr];

if exist('alpha','var')
    [h p ksstat] = kstest(data,cdfMatrix,alpha);
else
    [h p ksstat] = kstest(data,cdfMatrix);
end

if exist('bPlot','var') && bPlot
    xax = .1:.1:max(data)+3;
    [foo xax] = ecdf(data);
    tmp = gamcdf(xax,gampars(1),gampars(2));
    figure; plot(xax,foo,'b',xax,tmp,'r--')
    title(num2str(gampars));
end