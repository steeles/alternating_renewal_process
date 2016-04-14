function [ZrCombined, r11, r22, z1, z2, p11, p22] = ...
    compute_cumhist_corr(Durs,tau)

[lnT1, lnT2, H11, H22] = Durs_to_H_pred_lnT(Durs,tau);

[ZrCombined, r11, r22, z1, z2, p11, p22] = ...
    compute_pWeightedR_cumhist(lnT1, lnT2, H11, H22);