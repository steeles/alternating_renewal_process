% 7/28/2012 SS
% function to find parameters to fit a given empirical buildup function
% using the fourier pseudo-analytical method
%
% [bufpars_fit BUFfit t] = find_fourier_BUF_fit(BUF,tax,bPlot,opt,bufpars0)
function [bufpars_fit BUFfit t] = find_fourier_BUF_fit_2par(BUF,tax,bPlot,opt,bufpars0)

if ~exist('bufpars0','var') || isempty(bufpars0)
    randBounds = [1 3];
    bufpars0 = rand(1,2)*diff(randBounds).*[1 5] + randBounds(1);
end

if ~exist('opt','var')
    opt.T = 40; opt.m = 12;
end

f = @(bufpars_fit)compare_buildup_functions2_par(bufpars_fit,BUF,tax,opt);

options = optimset('MaxFunEvals', 100000, 'MaxIter', 100000);
[bufpars_fit fval exitFlag] = fminsearch(f,bufpars0,options);

bufpars_fit = [bufpars_fit bufpars_fit];
[BUFfit t] = make_fourier_buildup_function(bufpars_fit,opt);
if exist('bPlot','var') && bPlot
    BUFmax = max(BUF);
    plot(t,BUFfit,'r--',tax,BUF,'b'); axis([0 max(tax) 0 1.1*BUFmax]);
    title(num2str(bufpars_fit));
   
end
