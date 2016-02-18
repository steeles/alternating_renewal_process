% MC_nSubjects_sim
clear all

nSubjects = 1;
nTrials = 1000;

% from, what parameter values, etc

bRandom = 1; % generate random parameters for the gamma densities
randBounds = [1 4]; % sets minimum value and range for shape parameter
bSmall_scale = 1; %

for ind = 1:nSubjects
    
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
    
    nSwitches = 15; Durs(nSwitches*nTrials,2)=0;
    
    for tInd = 1:nTrials
        
        [Durs(((tInd-1) * nSwitches+1):(tInd*nSwitches) ,:)]=...
            [0 0 ; make_2gamma_distrs(g1,g2,nSwitches-1)]; %nSwitches has to be odd
        
        
        
    end
    
    
    betweenSubjsDurs{ind} = Durs;
    
    %% using BUF to predict the gamma pars
    
    [BUFta,taxta] = make_trial_averaged_BUF(Durs,.01,15);
    [bufpars_fit BUFfit t] = find_fourier_BUF_fit(BUFta,taxta);
    durs1S = Durs(Durs(:,2)==1,1); durs2S = Durs(Durs(:,2)==2,1);
    [foo CI_gam1] = gamfit(durs1S); [foo CI_gam2] = gamfit(durs2S);
    
    
    
    if 0
        bigFigure; subplot(1,2,1);
        plot(taxta,BUFta,'b',t,BUFfit,'r--');
        axis([0 15 0 1]);  mk_Nice_Plot; title(['LSE fit for BUF '...
            num2str(g1) '|' num2str(g2) ', found ' num2str(bufpars_fit)]);
        
        subplot(2,2,2);
        
        [h_bar1 sc] = plot_gamma_hist_fit(durs1S,bufpars_fit(1:2),g1); %title(['Subject ' num2str(ind)]);
        title([num2str(length(durs1S)) ' samples'])
        %disp(CI_gam1);
        %text(20,1000,num2str(CI_gam1));
        set(h_bar1, 'facecolor',[250,188,81]/255)
        
        text(30,1000,num2str(CI_gam1))
        hold on; plot(xax,g1pdf,'Color',[.2 .2 .2]);
        %legend(sprintf('%d samples',length(durs1S)),sprintf('found k = %3f \theta = %3f', ...
         %   bufpars_fit(1:2)), sprintf('true k = %3f \theta = %3f',g1));
        subplot(2,2,4);
        
        [h_bar2 sc] = plot_gamma_hist_fit(durs1S,bufpars_fit(1:2),g1); %title(['Subject ' num2str(ind)]);
        title([num2str(length(durs1S)) ' samples'])
        %disp(CI_gam1);
        %text(20,1000,num2str(CI_gam1));
        set(h_bar2, 'facecolor', [87,195,226]/255)
        text(30,1000,num2str(CI_gam2));
        hold on; plot(xax,g2pdf,'Color',[.2 .2 .2]);
        disp(bufpars_fit)
        betweenSubjsBUFs(ind,:) = BUFta;
    end
    
    k1 = []; k2 = []; th1 = []; th2 = [];
    %% check if gamfits are within MLE CIs
    g1_fit = bufpars_fit(1:2);
    g2_fit = bufpars_fit(3:4);
    
    if g1_fit(1) > CI_gam1(1,1) && g1_fit(1) < CI_gam1(2,1)
        k1 = 1;
    else
        k1 = 0;
    end
    
    if g1_fit(2) > CI_gam1(1,2) && g1_fit(2) < CI_gam1(2,2)
        th1 = 1;
    else
        th1 = 0;
    end
    
    if g2_fit(1) > CI_gam2(1,1) && g2_fit(1) < CI_gam2(2,1)
        k2 = 1;
    else
        k2 = 0;
    end
    
    if g2_fit(2) > CI_gam2(1,2) && g2_fit(2) < CI_gam2(2,2)
        th2 = 1;
    else
        th2 = 0;
    end
    
    tot_checks = [k1 th1 k2 th2];
    winning = sum(tot_checks)/length(tot_checks);
    
    
    tot_winning(ind) = winning;
    lik_true1 = gam_Likelihood(g1,durs1S);
    lik_true2 = gam_Likelihood(g2,durs2S);
    
    lik_fit1 = gam_Likelihood(g1_fit,durs1S);
    lik_fit2 = gam_Likelihood(g2_fit,durs2S);
    
    LR1 = lik_fit1/lik_true1;
    LR2 = lik_fit2/lik_true2;
    
    tot_LR1(ind) = LR1;
    tot_LR2(ind) = LR2;
end
%sum(tot_winning)
withinCI = mean(tot_winning)
LR1 = mean(tot_LR1)
LR2 = mean(tot_LR2)

%% now let's smash that all onto one graph:
if 0
    Durs_tot = vertcat(betweenSubjsDurs{:});
    durs1_tot = Durs_tot(Durs_tot(:,2)==1,1);
    durs2_tot = Durs_tot(Durs_tot(:,2)==2,2);
    
    BUFtot = make_trial_averaged_BUF(Durs_tot,.01,15);
    [bufpars_tot BUFfit_tot t] = find_fourier_BUF_fit(BUFta,taxta);
    bigFigure; subplot(1,2,1);
    plot(taxta,BUFta,'b',t,BUFfit,'r--');
    axis([0 10 0 1]);  mk_Nice_Plot;
    
    subplot(2,2,2);
    plot_gamma_hist_fit(durs1_tot,bufpars_tot(1:2)); title(['All Subjects ']);
    [g1 CI_gam1] = gamfit(durs1S); disp(CI_gam1)
    subplot(2,2,4);
    plot_gamma_hist_fit(durs2S,bufpars_fit(3:4))
    [g2 CI_gam2] = gamfit(durs2S); disp(CI_gam2)
    
    %% convergence of MC sims and BUF solution
    [BUFta,taxta] = make_trial_averaged_BUF(Durs,.01,15);
    bufpars = [g1 g2]; [BUFarp taxarp] = make_fourier_buildup_function(bufpars);
    
    gray = [.3 .3 .3];
    
    bigFigure; subplot(1,2,2);
    plot(taxta,BUFta,'b.'); hold on;
    plot(taxarp,BUFarp,'r');
    axis([0 15 0 1]);  mk_Nice_Plot; title('Monte Carlo and Analytical Buildup Functions');
    xlabel('time (s)'); ylabel('probability "split"')
    
    between_trials = find(Durs(:,2)==0);
    last_durns = between_trials(2:end)-1;
    
    durs_complete = Durs; durs_complete (last_durns,:) = [];
    
    durs1 = Durs(Durs(:,2) == 1,1);
    durs2 = Durs(Durs(:,2) == 2,1);
    
    xax = 0:.1:50;
    g1pdf = gampdf(xax,g1(1),g1(2));
    
    g2pdf = gampdf(xax,g2(1),g2(2));
    
    
    
    subplot(2,2,1); hold off
    [count bin] = hist(durs1); bar(bin,count/sum(count)/max(diff(bin)),1);hold on;
    plot(xax,g1pdf,'Color',gray); mk_Nice_Plot
    xlim([0 50]); xlabel('grouped percept durations (s)')
    
    subplot(2,2,3); hold off
    [count bin] = hist(durs2); bar(bin,count/sum(count)/max(diff(bin)),1);hold on;
    plot(xax,g2pdf,'Color',gray); mk_Nice_Plot
    xlim([0 50]); xlabel('split percept durations (s)')
end

