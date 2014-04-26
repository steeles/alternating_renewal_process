% make exp. hists
% 4/21/12 Sara Steele, trying to modularize gamma fitting code and bring
% all my scripts into accepting a data array produced by
% KPushETs_ss which has the form nPercepts x 2, with percpet
% durations in the first column and percept IDs in the second. Separate
% trials are separated by a 0 0 row
KPushETs_ss

%for condition_ind = 1:nConditions
    bBoot = 0;
    
    nonzeroInds = conditionDurs(:,2)~=0;
    conditionDurs = conditionDurs(nonzeroInds,:);
    
    
    Durs1 = durns_corrected(durns_corrected(:,2)==1,1);
    Durs2 = durns_corrected(durns_corrected(:,2)==2,1);
    
        g1 = find_gamma_fit(Durs1,1);
        g2 = find_gamma_fit(Durs2,1);

%%  Bootstrap

if bBoot
    bootstrap_2gammaDistrs
end
%end



