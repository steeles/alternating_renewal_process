function DursOut = normalizeDurs(DursIn)

DursOut = DursIn;

IntInds = find(DursIn(:,2)==1);
SegInds = find(DursIn(:,2)==2);


durs1 = DursIn(IntInds,1);
mu1 = mean(durs1);
normalD1 = DursIn(IntInds,1)/mu1;
DursOut(IntInds,1) = normalD1;

durs2 = DursIn(SegInds,1);
mu2 = mean(durs2);
normalD2 = DursIn(SegInds,1)/mu2;
DursOut(SegInds,1) = normalD2;
