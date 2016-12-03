function [rho_hat, pVal, r11, r22] = computeRho(Durs,tau)

[ZrCombined, r11, r22, z1, z2, p11, p22, n1, n2, pTot] = compute_cumhist_corr(Durs,tau);

rho_hat = ZrCombined; pVal= pTot;