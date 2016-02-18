% H = compute_cum_history(Durs,tau)
% Hx gives History values for each switch time; nSwitches x 1


function [H11 H12 lnT1 lnT2 H21 H22] = compute_combined_cum_history2(DursCellin,tau,bPlot)

nDatasets = length(DursCellin);
    
if ~exist('tau','var')
   tau = 1; 
end
if ~exist('bPlot','var')
   bPlot = 0; 
end

H1_cell{nDatasets} = [];
H2_cell{nDatasets} = [];
DursCell{nDatasets} = [];
for ind = 1:nDatasets
    
    Dursin = DursCellin{ind};
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
% 
% [rGrouped pGrouped] = corrcoef(groupedMat); 
% [rSplit pSplit] = corrcoef(splitMat);
% 
% pVals = [pGrouped; pSplit];
% if any(pVals([1 2 4 5],3)<.05)
%     sigFlag = 1;
% else
%     sigFlag = 0;
% end

% %keyboard;
% % should be H1 x 1, H2 x 1, H1 x 2, H2 x 2
% rAbs = abs([rGrouped(3,1:2) rSplit(3,1:2)]);

% r = mean(rAbs);

% split into predictors and dependent vars. labels give H, dur identity

lnT1 = groupedMat(:,3); H11 = groupedMat(:,1); H21 = groupedMat(:,2);
lnT2 = splitMat(:,3); H12 = splitMat(:,1); H22 = splitMat(:,2);


