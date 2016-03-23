% H = compute_cum_history(Durs,tau)
% Hx gives History values for each switch time; nSwitches x 1


function [r r2 H1 H2 pVals sigFlag H11 H12 lnT1 lnT2 p11 p22 h y11 y22 r11 r22] = compute_combined_cum_history(DursCellin,tau,bPlot)


    
if ~exist('tau','var')
   tau = 1; 
end
if ~exist('bPlot','var')
   bPlot = 0; 
end
if ~iscell(DursCellin)
    tmp = DursCellin;
    DursCellin = [];
    DursCellin{1} = tmp;
end

%keyboard;
nDatasets = length(DursCellin);

H1_cell{nDatasets} = [];
H2_cell{nDatasets} = [];
DursCell{nDatasets} = [];
for ind = 1:nDatasets
    
    Dursin = DursCellin{ind};
    if length(Dursin)<5, continue; end
    %keyboard;
    if Dursin(1,1) ~=0
        Dursin = [0 0 ; Dursin];
    end
    
    [H1in H2in] = compute_H_2(Dursin,tau,0);
    
    % first values haven't stabilized yet, last might be censored... don't
    % want to throw off the correlation
    
    Durs = Dursin(4:end-1,:); H1 = H1in(3:end-2,1); H2 = H2in(3:end-2,1);
    
    %keyboard;
    DursCell{ind} = Durs;
    
    H1_cell{ind} = H1; H2_cell{ind} = H2;
    
end
%keyboard;
%% compute r
r = [];

Durs = vertcat(DursCell{:}); H1 = vertcat(H1_cell{:}); H2 = vertcat(H2_cell{:});

groupedInds = Durs(:,2)==1; splitInds = Durs(:,2)==2;

lnDurs = log(Durs(:,1));
    
mat = [H1 H2 lnDurs];
groupedMat = mat(groupedInds,:); splitMat = mat(splitInds,:);

 T1 = groupedMat(:,3); H11 = groupedMat(:,1); H21 = groupedMat(:,2);
 T2 = splitMat(:,3); H12 = splitMat(:,1); H22 = splitMat(:,2);




[rGrouped pGrouped] = corrcoef(groupedMat); 
[rSplit pSplit] = corrcoef(splitMat);
keyboard
pVals = [pGrouped; pSplit];
if any(pVals([1 2 4 5],3)<.05)
    sigFlag = 1;
else
    sigFlag = 0;
end

%keyboard;
% should be H1 x 1, H2 x 1, H1 x 2, H2 x 2
rAbs = abs([rGrouped(3,1:2) rSplit(3,1:2)]);

r = mean(rAbs);
nBoot = 10000;
% split into predictors and dependent vars. labels give H, dur identity

lnT1 = groupedMat(:,3); H11 = groupedMat(:,1); H21 = groupedMat(:,2);
lnT2 = splitMat(:,3); H12 = splitMat(:,1); H22 = splitMat(:,2);

%[rZ_H11 pValScram11] = compute_corrZ(lnT1,H11,nBoot); 
%[rX_2_H1 pValScram12] = compute_corrZ(lnT2,H12); 
r1 = corrcoef(lnT1,H11); r11 = r1(1,2);
r2 = corrcoef(lnT2,H22); r22 = r2(1,2);

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
    
   h = bigFigure; 
   subplot(2,1,1); plot(H11, lnT1, '.')
   mk_Nice_Plot; hold on
   % plot regression line
   plot(H11,y11,'r'); title(sprintf('r = %.2f',rAbs(1)))
   xlabel('H1'); ylabel('log(Durs1)'); xlim([0 1])
   
%    subplot(2,2,2); plot(H21, lnT1, '.')
%    mk_Nice_Plot; hold on
%    % plot regression line
%    plot(H21,y21,'r'); title(sprintf('r = %.2f',rAbs(2)))
%    xlabel('H2'); xlim([0 1])
   
   subplot(2,1,2); plot(H22, lnT2, '.')
   mk_Nice_Plot; hold on
   % plot regression line
   plot(H22,y22,'r'); title(sprintf('r = %.2f',rAbs(3)))
   xlabel('H2'); ylabel('log(Durs2)'); xlim([0 1])
   
%    subplot(2,2,4); plot(H22, lnT2, '.')
%    mk_Nice_Plot; xlim([0 1]); hold on
%    % plot regression line
%    plot(H22,y22,'r'); title(sprintf('r = %.2f',rAbs(4)))
   
%   keyboard;
   ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0
       1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
   
   text(0.5, 1,sprintf('tau = %.2f', tau),'HorizontalAlignment'...
       ,'center','VerticalAlignment', 'top', 'FontSize',20)
   
else
    h=0;
   
end

r2 = mean(abs(r2)); % this is maybe not right...






% rNeg = -r;


