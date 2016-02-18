

function [upperbound lowerbound] = find_bootstrap_BUF_CIs(durs,g1,g2,nRep,tax,window,step)

alltheBUFs(nRep,length(tax))=0;
    
for ind = 1:nRep
    % take a random sample from the distrs
    simulated_durs = make_2gamma_distrs(g1,g2,length(durs));
    
    % make a switch triggered buf
    alltheBUFs(ind,:) = make_switchTriggeredBUF(simulated_durs,step,window);
    
    
end

tmp = sort(alltheBUFs);

upperbound = tmp(250,:);
lowerbound = tmp(end-250,:);