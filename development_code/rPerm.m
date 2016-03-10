function [pBoot] = rPerm(x,y,nBoot)

if ~exist('nBoot','var')
	nBoot = 5000;
end


rtmp = corrcoef(x,y);
rHat = rtmp(1,2);

rNullVec(nBoot) = 0;

for ind = 1:nBoot
    
    yInds = randperm(length(y));
    yScrambled = y(yInds);
    rScram = corrcoef(x,yScrambled);
    rNullVec(ind) = rScram(1,2);
    
end

rNullSort = sort(rNullVec);

pInd = find(rNullSort>rHat,1);
if isempty(pInd)
    pBoot = 0;
else    
    pBoot = 1-pInd/nBoot;
end

