% function that plots histograms for every H

function hists_by_H_cumhist(Durs,pars,nBins,bAnnotate)

if ~exist('nBins','var'), nBins = 5; end

k1 = abs(pars(1)); % +
k2 = abs(pars(2)); % +

b1 = pars(3); % 
b2 = pars(4); % 

m1 = pars(5);
m2 = pars(6);
tau = abs(pars(7)); % +


th1 = exp(b1)/k1;
th2 = exp(b2)/k2;

[lnT1, lnT2, H11, H22] = Durs_to_H_pred_lnT(Durs,tau);
T1 = exp(lnT1); T2 = exp(lnT2);

edges1 = linspace(min(H11), max(H11), nBins + 1);
edges2 = linspace(min(H22), max(H22), nBins + 1);

[h1vec inds1] = sort(H11); [h2vec inds2] = sort(H22);

max1 = max(T1); max2 = max(T2);
T1sort = T1(inds1); T2sort = T2(inds2);

axmax1 = ceil(max1/5) * 5;
axmax2 = ceil(max2/5) * 5;

bigFigure;
for ind = 1:nBins
    LB = edges1(ind); UB = edges1(ind+1);
    h1X = (LB + UB)/2;
    u1_pred = exp(m1 * h1X + b1);
    gampars_pred = [k1 u1_pred/k1];

    inds1 = h1vec >= LB & h1vec <= UB;
    durs1_batch = T1sort(inds1);
    if length(durs1_batch)<1, durs1_batch = 0; end
    subplot(2,nBins,ind-1*2+1); 
    plot_gamma_hist_fit(durs1_batch,gampars_pred);
    title(sprintf('H1 = %.2f',h1X)); xlim([0 axmax1]);
    ht1 = ylim; hold on; plot([u1_pred u1_pred], [0 ht1(2)],'g',...
        'LineWidth',3); ylim(ht1);
    if bAnnotate, 
        text(axmax1*.8,ht1*.8,sprintf('k=%.2f %th=.25',...
            gampars_pred(1), gampars_pred(2)))
    end
    
    LB2 = edges2(ind); UB2 = edges2(ind+1);
    h2X = (LB2 + UB2)/2;
    u2_pred = exp(m2 * h2X + b2);
    gampars_pred2 = [k2 u2_pred/k2];
    
    inds2 = h2vec >= LB2 & h2vec <= UB2;
    durs2_batch = T2sort(inds2);
    if length(durs2_batch)<1, durs2_batch = 0; end
    subplot(2,nBins,ind+nBins); 
    plot_gamma_hist_fit(durs2_batch,gampars_pred2);
    title(sprintf('H2 = %.2f',h2X)); xlim([0 axmax2]);
    ht2 = ylim; hold on; plot([u2_pred u2_pred], [0 ht2(2)],'g',...
        'LineWidth',3); ylim(ht2);
    if bAnnotate,
        text(axmax2*.8,h2*.8, sprintf('k=%.2f %th=.25',...
            gampars_pred2(1), gampars_pred2(2)));
    end
    
end
