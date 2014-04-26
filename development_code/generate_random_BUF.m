function [BUF tax] = generate_random_BUF

% from, what parameter values, etc

bRandom = 1; % generate random parameters for the gamma densities
randBounds = [1 4]; % sets minimum value and range for shape parameter
bSmall_scale = 1; %


    
    if bRandom
        if bSmall_scale
            g1 = rand(1,2).*[diff(randBounds), diff(randBounds)] + randBounds(1);
            g2 = rand(1,2).*[diff(randBounds), diff(randBounds)] + randBounds(1);
        else
            g1 = rand(1,2).*[diff(randBounds), 4*diff(randBounds)] + randBounds(1);
            g2 = rand(1,2).*[diff(randBounds), 4*diff(randBounds)] + randBounds(1);
        end
    else
        
        g1 = [1.45 3.26]; g2 = [2.08 5.12]; % for paper
        %g1 = [2 2]; g2 = [2 5];
        
    end
    %opt.T = 20; opt.m = 12;
    %BUF(ind,:) = make_fourier_buildup_function([g1(ind,:) g2(ind,:)],opt,1);
    
    xax = 0:.1:30;
    g1pdf = gampdf(xax,g1(1),g1(2));
    %figure; plot(xax,g1pdf);
    
    g2pdf = gampdf(xax,g2(1),g2(2));
    %figure; plot(xax,g2pdf);
    
    nSwitches = 15; Durs = [];%Durs(nSwitches*nTrials,2)=0;
    wind = 15;
    for tInd = 1:nTrials
        
        tmp = make_2gamma_distrs(g1,g2,nSwitches-1);
        cutoff = find(cumsum(tmp(:,1))>wind,1);
        
%        [Durs(((tInd-1) * nSwitches+1):(tInd*nSwitches) ,:)]=...
        Durs = [Durs;
        0 0 ; tmp(1:cutoff,:)]; %nSwitches has to be odd

    
    
    betweenSubjsDurs{ind} = Durs;
    
    %% using BUF to predict the gamma pars
    
    [BUFta,taxta] = make_trial_averaged_BUF(Durs,.01,wind);
    [bufpars_fit BUFfit t] = find_fourier_BUF_fit(BUFta,taxta);
    durs1S = Durs(Durs(:,2)==1,1); durs2S = Durs(Durs(:,2)==2,1);
    [foo CI_gam1] = gamfit(durs1S); [foo CI_gam2] = gamfit(durs2S);