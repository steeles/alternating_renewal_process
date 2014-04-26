% added options, R^2 output

% edit 1/10/2013 to give BUFfit (BUFproposed) in same time resolution as
% BUF as an output

% remade 8/2/2013 to make bufpars a 2 vector, eg repeat 2 identical gamma
% densities

function [error Rsquared BUF_adj] = compare_buildup_functions2_par(bufpar1,BUF,tax,opt)

bufpars = [bufpar1 bufpar1];

if ~exist('opt','var')
   [BUFproposed t] = make_fourier_buildup_function(bufpars);
else
   [BUFproposed t] = make_fourier_buildup_function(bufpars,opt);
end

BUF_adj = interp1(t,BUFproposed,tax,'cubic','extrap');  % put the two BUFs on the same time res

error = sum((BUF_adj - BUF).^2);

Rsquared = 1-error/sum((BUF-mean(BUF)*ones(size(BUF))).^2);