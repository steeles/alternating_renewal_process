%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now I will try to recover the pars for the 2 gam distrs- output in
% command window should be a 2 vector with g(1)=alpha or the "shape"
% parameter and g(2)=1/theta, or the inverse of the "scale" parameter

% modified 2/17 by SS to take samples from m distributions in a m x n
% sample matrix
% returns parameters g in a 2 x n matrix, ie 1 column vector for pars for
% each distr

function [g fval] = plot_gamma_fit(durns_corrected)



    
    this_distr = samples(ind,:);
    g_mean=mean(this_distr);
    g_var=sum((this_distr-g_mean).^2)/(length(this_distr)-1);

    beta = g_mean/g_var;
    alpha = g_mean*beta;
    
    [g(:,ind) fval exitFlags] = fminsearch(@gam_Likelihood,[alpha; beta],...
    [],this_distr)
    
    if bPlot
       h1 = figure;
       mk_Nice_Hist(this_distr); hold on;
       
       x = linspace(0,max(this_distr)+2,200);
       y = gampdf(x,g(1,ind),1/(g(2,ind)));
       plot(x,y,'b'); 
       
    end
    
    [min_Alpha,betaAtMinAlpha,max_Alpha,betaAtMaxAlpha] = ...
        find_gamma_confidence_intervals(alpha,beta,this_distr,fval,g(:,ind),bPlot);
    if bPlot
        
        figure(h1);
        
        y1 = gampdf(x,min_Alpha,1/betaAtMinAlpha);
        y2 = gampdf(x,max_Alpha,1/betaAtMaxAlpha);
        plot(x,y1,'r--',x,y2,'g--')
        legend('sample hist','optimal fit','lower bound par fit',...
            'upper bound par fit')
    end
    
end



