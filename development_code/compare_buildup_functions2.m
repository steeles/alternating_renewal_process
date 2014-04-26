% added options, R^2 output

% edit 1/10/2013 to give BUFfit (BUFproposed) in same time resolution as
% BUF as an output



function [error Rsquared BUF_adj] = compare_buildup_functions2(bufpars,BUF,tax,opt)

if ~exist('opt','var')
   [BUFproposed t] = make_fourier_buildup_function(bufpars);
else
   [BUFproposed t] = make_fourier_buildup_function(bufpars,opt);
end

BUF_adj = interp1(t,BUFproposed,tax,'cubic','extrap');  % put the two BUFs on the same time res

error = sum((BUF_adj - BUF).^2);

Rsquared = 1-error/sum((BUF-mean(BUF)*ones(size(BUF))).^2);