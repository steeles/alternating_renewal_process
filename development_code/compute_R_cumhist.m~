% needs to be causal; how does preceding H predict Tnext? this is done by
% "trimming" or cutting the appropriate number of values off the front of
% the Durs and H vectors

% Durs and Hs could be a cell, in which case it's going to be trimmed by 
% the time it gets here (along with H1 and H2 vals)
function [r r11 r22 sigFlag] = compute_R_cumhist(Durs,H1,H2,bTrimmed,bBootstrap)

if ~bTrimmed || ~exist('bTrimmed','var')
    bTrimmed = 0;
    Durs = Durs(4:end-1,:);
    H1 = H1(3:end,1);
    H2 = H2(3:end,1);
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

T1 = groupedMat(:,3); H11 = groupedMat(:,1); H21 = groupedMat(:,2);
T2 = splitMat(:,3); H12 = splitMat(:,1); H22 = splitMat(:,2);

[rGrouped pGrouped] = corrcoef([T1 H11]); 
[rSplit pSplit] = corrcoef([T2 H22]);

pVals = [pGrouped; pSplit];
if any(pVals([1 2 4 5],3)<.05)
    sigFlag = 1;
else
    sigFlag = 0;
end

%keyboard;
% should be H1 x 1, H2 x 1, H1 x 2, H2 x 2
r11 = rGrouped(1,2); r22 = rSplit(1,2);

r = mean(abs([r11 r22]));