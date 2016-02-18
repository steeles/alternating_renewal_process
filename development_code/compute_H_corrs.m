function [r r2] = compute_H_corrs(H1,H2,Durs,bPlot)



groupedInds = Durs(:,2)==1; splitInds = Durs(:,2)==2;

lnDurs = log(Durs(:,1));

mat = [H1 H2 lnDurs];
groupedMat = mat(groupedInds,:); splitMat = mat(splitInds,:);

rGrouped = corrcoef(groupedMat);
rSplit = corrcoef(splitMat);

% should be H1 x 1, H2 x 1, H1 x 2, H2 x 2
rAbs = abs([rGrouped(3,1:2) rSplit(3,1:2)]);

r = mean(rAbs);


% split into predictors and dependent vars. labels give H, dur identity

lnT1 = groupedMat(:,3); H11 = groupedMat(:,1); H21 = groupedMat(:,2);
lnT2 = splitMat(:,3); H12 = splitMat(:,1); H22 = splitMat(:,2);




% compute 4 corrs- H1 x T1, H1 x T2, H2 x T1, H2 x T2
% this might be wrong-- perhaps i want to do a regression and maximize
% rSquared?

% H's are independent vars and Durs are dependent vars; run polyfit
r2 = zeros(1,4);
% predictors for T1 and T2 and save coeffs to pXY
[p11] = polyfit(H11, lnT1, 1); y11 = polyval(p11,H11);
r2(1) = calc_rSquared(lnT1,y11);
[p21] = polyfit(H21, lnT1, 1); y21 = polyval(p21,H21);
r2(2) = calc_rSquared(lnT1, y21);
[p12] = polyfit(H12, lnT2, 1); y12 = polyval(p12,H12);
r2(3) = calc_rSquared(lnT2, y12);
[p22] = polyfit(H22, lnT2, 1); y22 = polyval(p22,H22);
r2(4) = calc_rSquared(lnT2, y22);

%%
if exist('bPlot','var') && bPlot
    
    bigFigure;
    subplot(2,2,1); plot(H11, lnT1, '.')
    mk_Nice_Plot; hold on
    % plot regression line
    plot(H11,y11,'r'); title(sprintf('R-square = %.2f',r2(1)))
    xlabel('H1'); ylabel('log(Durs1)'); xlim([0 1])
    
    subplot(2,2,2); plot(H21, lnT1, '.')
    mk_Nice_Plot; hold on
    % plot regression line
    plot(H21,y21,'r'); title(sprintf('R-square = %.2f',r2(2)))
    xlabel('H2'); xlim([0 1])
    
    subplot(2,2,3); plot(H12, lnT2, '.')
    mk_Nice_Plot; hold on
    % plot regression line
    plot(H12,y12,'r'); title(sprintf('R-square = %.2f',r2(3)))
    ylabel('log(Durs2)'); xlim([0 1])
    
    subplot(2,2,4); plot(H22, lnT2, '.')
    mk_Nice_Plot; xlim([0 1]); hold on
    % plot regression line
    plot(H22,y22,'r'); title(sprintf('R-square = %.2f',r2(4)))
    
    %   keyboard;
    ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0
        1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    
    
end

r2 = mean(abs(r2)); % this is maybe not right...