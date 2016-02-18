% wrapper function to compute corrs for lnT1, H11, etc

function [rZOut r] = compute_cumhist_corrZ(DursCellin, tau, bPlot, nBoot)

if ~exist('bPlot','var')
    bPlot = 0;
end

if ~exist('nBoot','var')
    nBoot = 10000;
end

[H11 H12 lnT1 lnT2] = compute_combined_cum_history2(DursCellin,tau,bPlot);

[rNormZ1 sampleR11s] = compute_corrZ(H11, lnT1,nBoot);
[rNormZ2 sampleR12s] = compute_corrZ(H12, lnT2, nBoot);



rZOut = mean(abs([rNormZ1 rNormZ2]));

r = mean(abs([mean(sampleR11s) mean(sampleR12s)]));

if bPlot
    figure; subplot(121); hist(sampleR11s); xlabel('r lnT1 x H1')
    subplot(122); hist(sampleR12s); xlabel('r lnT2 x H1')
end