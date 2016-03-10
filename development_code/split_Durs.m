% find the pre's and posts for the different transitions IS and SI
% [Ipre, Spre, Ipost, Spost] = split_Durs(Durs)
function [Ipre, Spre, Ipost, Spost] = split_Durs(Durs)

IntInds = find(Durs(:,2)==1);
SegInds = find(Durs(:,2)==2);

sampLen = length(Durs(:,2));
% since I don't know whether a trial ends on a Int or a Seg, I have
% to make it work for either one, ie whichever one is end-1 is pre

IntPreInds = IntInds(IntInds<sampLen);
SegPreInds = SegInds(SegInds<sampLen);

Ipre = Durs(IntPreInds,1);
Spost = Durs(IntPreInds+1,1);

Spre = Durs(SegPreInds,1);
Ipost = Durs(SegPreInds+1,1);
