% combine rows of R_array by NumSamples; I should get an rCombined for each
% column if I feed a 2D array

% for vectors, I should feed column vectors

function [rCombined ] = fisher_combine_corrs(R_array,NumSamples)

% R_array(isnan(R_array)) = 0;

tmp = size(NumSamples);

R_array(R_array==1) = .999999;

R_array(R_array==-1) = -.999999;

weights = NumSamples./repmat(sum(NumSamples,1),tmp(1),1);
% if NumSamples = 0, we should get a NaN
%weights(isnan(weights)) = 0;

rCombined = tanh(sum(weights .* atanh(R_array),1,'omitnan'));

if any(abs(rCombined)>1)
    error('averaged correlations go outside -1:1')
end
bogusCorrs = find(~any(~isnan(R_array)));

rCombined(bogusCorrs)=NaN;