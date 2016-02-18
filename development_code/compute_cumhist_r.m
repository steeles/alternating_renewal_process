
% CUMHIST = compute_cumhist_r(DursCell,tau_ax,bPlot)

function CUMHIST = compute_cumhist_r(DursCell,tau_ax,bPlot)

n = size(DursCell);
rVals(length(tau_ax)) = 0;

% these hold the H vects for each trial... filled with 

% there's going to have to be another subfunction to find Hs across trials
% that maximize the total correlation... basically search over tau, 
% for each one compute all the Hvecs for that Tau (each cell separate),
% chop off the first few and last entries like so:
% OK- chopping off first durs because they haven't stabilized; also cut off
% last Dur...
% Durs = Durs(4:end-1,:); H1 = H1(3:end-2); H2 = H2(3:end-2);
% THEN splice them together, then do the correlation
% find_max_corr_over_trials

H1Cell = cell(
H2Cell = cell(
for ind = 1:length(DursCell)
    Durs = DursCell{ind};
    

% combine multiple trials by having Durs be deeper? use a cell array

    for tInd = 1:length(tau_ax)
        tau = tau_ax(tInd);

        [r r2 H1 H2] = compute_cum_history(Durs,tau,bPlot);
        rVals(tInd) = r;
    end
        
    [foo maxRi] = max(rVals);
    
   
    maxRtau = tau_ax(maxRi);
    
    Tbar = mean(Durs(:,1));
    
    if exist('bPlot','var') && bPlot
        
        semilogx(tau_ax,rVals,'g'); hold on; mk_Nice_Plot;
        %semilogx(tau_ax,r2Vals,'r');
        title(sprintf('best ~ %.2f, mnDur = %.2f',maxRtau,Tbar))
%        'condn %d, subject %d, 
        %legend('r','Location','Best'); 
        xlabel('tau'); ylabel('r (H vs ln(T)')
        xlim([min(tau_ax) max(tau_ax)])
    end
    
    cumhist_datastruct = v2struct(rVals, tau);
end



function compute_r(Durs,H1,H2,bPlot)
r = [];

% OK so indexing looks a bit funky- the H value predicts the NEXT dur, so
% the last H values have nothing to predict. I think I can chop off the
% zeros in front of Durs and the last Hs to get stuff...

% the last dur is also probably censored... meh, cross that bridge when we
% come to it

% also, the H = 0 values might be a little weird?



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
   
   text(0.5, 1,sprintf('tau = %.2f', tau),'HorizontalAlignment'...
       ,'center','VerticalAlignment', 'top', 'FontSize',20)
   
end
end