

function [upperbound lowerbound] = find_bootstrap_BUF_CIs(durs,g1,g2,nRep,tax,window,step)

if ~exist('nRep','var'), nRep = 10000; end

alltheBUFs(nRep,length(tax))=0;

for ind = 1:nRep
    % take a random sample from the distrs
    simulated_durs = make_2gamma_distrs(g1,g2,length(durs));
    
    % make a switch triggered buf
    alltheBUFs(ind,:) = make_switchTriggeredBUF(simulated_durs,step,window);
    
    
end

tmp = sort(alltheBUFs);

ind = round(nRep * .025);
upperbound = tmp(ind,:);
lowerbound = tmp(end-ind,:);