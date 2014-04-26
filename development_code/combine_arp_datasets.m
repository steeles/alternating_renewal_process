% aggregate data from struct array fields: durs1, durs2, BUF, tax, nWindows; 
% and fill in, durs1_tot, durs2_tot, g1_pars, g2_pars, a new aggregated 
% BUF, BUFarp, rSquared, nWindows_tot, df

% consolidated_struct = combine_arp_datasets(s)

function consolidated_struct = combine_arp_datasets(s)

    durs1_tot = vertcat(s.durs1); 
    durs2_tot = vertcat(s.durs2);
    g1_pars = find_gamma_pars(durs1_tot); g2_pars = find_gamma_pars(durs2_tot);
    
    weights = vertcat(s.nWindows); nWindows_tot = sum(weights);
    BUFs = vertcat(s.BUF); tax = s(1,1,1).tax;
    
    BUF_tot = [BUFs' * weights/nWindows_tot]'; bufpars = [g1_pars;g2_pars];
    
    [error rSquared BUFarp] = compare_buildup_functions2(bufpars,BUF_tot,tax);
    
    df = s.df; subjID = s.subjID;
	consolidated_struct = v2struct(durs1_tot,durs2_tot, g1_pars,...
        g2_pars, BUF_tot,BUFarp,rSquared,nWindows_tot,tax,df,subjID);