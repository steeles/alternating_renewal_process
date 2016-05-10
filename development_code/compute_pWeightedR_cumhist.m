% so I'm going to use the fisher combination of the correlations by the
% standard errors to get a sort of super Z score for the correlation
% coefficient
% [ZrCombined, r11, r22, p11, p22] = ...
%     compute_pWeightedR_cumhist(Y1, Y2, X1, X2, bPlot)

function [ZrCombined, r11, r22, z1, z2, p11, p22, pTot] = ...
    compute_pWeightedR_cumhist(Y1, Y2, X1, X2, bPlot)

if ~exist('bPlot','var')
   bPlot = 0; 
end

if length(Y1)<3
    ZrCombined = NaN; r11 = NaN; r22 = NaN; z1 = NaN; z2 = NaN;
    p11 = NaN; p22 = NaN; pTot = NaN; return
end

[r11, p11] = corr(Y1,X1);
[r22, p22] = corr(Y2,X2);

se1 = 1/sqrt((length(Y1)-3));

se2 = 1/sqrt((length(Y2)-3));

z1 = atanh(r11)/se1; z2 = atanh(r22)/se2;

ZrCombined = sqrt(z1^2 + z2^2);
pTot = exp(-ZrCombined^2/2);
%pTot = 1/2*exp(-ZrCombined/2);
