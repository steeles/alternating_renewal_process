% 7/28/2012 SS
% function to find parameters to fit a given empirical buildup function
% using the fourier pseudo-analytical method
%
% [bufpars_fit BUFfit t] = find_fourier_BUF_fit(BUF,tax,bPlot,opt,bufpars0)
function [bufpars_fit BUFfit t] = find_fourier_BUF_fit_given_mns(BUF,tax,mu0,mu1,bPlot,opt,shapepars0)

if ~exist('shapepars0','var') || isempty(shapepars0)
    shapepars0 = rand(1,2);
end

if ~exist('opt','var')
    opt.T = 40; opt.m = 12;
end

f = @(shapepars_fit)compare_buildup_functions_with_mns(shapepars_fit,BUF,tax,mu0,mu1);

options = optimset('MaxFunEvals', 100000, 'MaxIter', 100000);
[shapepars_fit fval exitFlag] = fminsearch(f,shapepars0,options);

scalepars_fit = [mu0 mu1] ./ shapepars_fit; 
bufpars_fit = [shapepars_fit(1),scalepars_fit(1),shapepars_fit(2),scalepars_fit(2)];
[BUFfit t] = make_fourier_buildup_function(bufpars_fit,opt);
if exist('bPlot','var') && bPlot
    BUFmax = max(BUF);
    plot(t,BUFfit,'r--',tax,BUF,'b'); axis([0 max(tax) 0 1.1*BUFmax]);
    title(num2str(bufpars_fit));
   
end
