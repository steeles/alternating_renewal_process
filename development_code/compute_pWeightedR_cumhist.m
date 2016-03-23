% so I'm going to use the fisher combination of the correlations by the
% standard errors to get a sort of super Z score for the correlation
% coefficient

function [ZrCombined, r11, r22, p11, p22] = ...
    compute_pWeightedR_cumhist(lnT1, lnT2, H11, H22, bPlot)

if ~exist('bPlot','var')
   bPlot = 0; 
end

[r11, p11] = corr(lnT1,H11);
[r22, p22] = corr(lnT2,H22);

se1 = 1/sqrt((length(lnT1)-3));

se2 = 1/sqrt((length(lnT2)-3));

z1 = atanh(r11)*se1; z2 = atanh(r22)*se2;

ZrCombined = z1 + z2;