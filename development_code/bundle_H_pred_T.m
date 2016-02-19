% groups h11 and lnT1, h22 x lnt2 together causally

% [lnT1 lnT2 h11 h22] = bundle_H_pred_T(Durs,H1,H2)

function [lnT1 lnT2 H11 H22] = bundle_H_pred_T(Durs,H1,H2,bTrimmed)

if ~bTrimmed || ~exist('bTrimmed','var')
    disp('trimming!')
    bTrimmed = 0;
    Durs = Durs(4:end-1,:);
    H1 = H1(3:end-2,1);
    H2 = H2(3:end-2,1);
end

if iscell(Durs) && iscell(H1) && iscell(H2)
    Durs = vertcat(DursCell{:}); 
    H1 = vertcat(H1_cell{:}); 
    H2 = vertcat(H2_cell{:});
end


groupedInds = Durs(:,2)==1; splitInds = Durs(:,2)==2;

lnDurs = log(Durs(:,1));
    
mat = [H1 H2 lnDurs];
groupedMat = mat(groupedInds,:); splitMat = mat(splitInds,:);

lnT1 = groupedMat(:,3); H11 = groupedMat(:,1); H21 = groupedMat(:,2);
lnT2 = splitMat(:,3); H12 = splitMat(:,1); H22 = splitMat(:,2);
