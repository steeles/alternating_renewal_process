function [lnT1, lnT2, H11, H22] = Durs_to_H_pred_lnT(DursCellin,tau)

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

nDatasets = length(DursCellin);

H1_cell{nDatasets} = [];
H2_cell{nDatasets} = [];
DursCell{nDatasets} = [];

for ind = 1:nDatasets
    
    Dursin = DursCellin{ind};
    if length(Dursin)<5, continue; end
    if Dursin(1,1) ~=0
        Dursin = [0 0 ; Dursin];
    end
    
    [H1in H2in] = compute_H_2(Dursin,tau,0);
    
    % need to get causality so H predicts T; computed as H at end of an
    % interval.
    % first values haven't stabilized yet, don't
    % want to throw off the correlation; "trimming"
    
    Durs = Dursin(4:end,:); H1 = H1in(3:end-1,1); H2 = H2in(3:end-1,1);
    
    DursCell{ind} = Durs; H1_cell{ind} = H1; H2_cell{ind} = H2;
end

foo = cellfun('isempty',DursCell);
if all(foo), lnT1 = NaN; lnT2 = NaN; H11 = NaN; H22 = NaN; return, end

DursCell = DursCell(~foo);

Durs = vertcat(DursCell{:});
H1 = vertcat(H1_cell{:});
H2 = vertcat(H2_cell{:});

groupedInds = Durs(:,2)==1; splitInds = Durs(:,2)==2;

lnDurs = log(Durs(:,1));
    
mat = [H1 H2 lnDurs];
groupedMat = mat(groupedInds,:); splitMat = mat(splitInds,:);

lnT1 = groupedMat(:,3); H11 = groupedMat(:,1);
lnT2 = splitMat(:,3); H22 = splitMat(:,2);
