%MC_4par_reverse

clear all

nSubjects = 10;
nTrials = 1000;

% from, what parameter values, etc

bRandom = 1; % generate random parameters for the gamma densities
randBounds = [1 4]; % sets minimum value and range for shape parameter
bSmall_scale = 1; %

tot_winning1 = zeros(1,nSubjects);
pvals1 = zeros(1,nSubjects);
ksstat1 = zeros(1,nSubjects);
tot_winning2 = zeros(1,nSubjects);
pvals2 = zeros(1,nSubjects);
ksstat2 = zeros(1,nSubjects);


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
    
%     nSwitches = 15; Durs = [];%Durs(nSwitches*nTrials,2)=0;
%     wind = 15;
%     for tInd = 1:nTrials
%         
%         tmp = make_2gamma_distrs(g1,g2,nSwitches-1);
%         cutoff = find(cumsum(tmp(:,1))>wind,1);
%         
% %        [Durs(((tInd-1) * nSwitches+1):(tInd*nSwitches) ,:)]=...
%         Durs = [Durs;
%         0 0 ; tmp(1:cutoff,:)]; %nSwitches has to be odd
%         
%         
%         
%     end
%     
%     
%     betweenSubjsDurs{ind} = Durs;
    
    %% using BUF to predict the gamma pars
    [BUFta,taxta,Durs] = generate_MC_BUF(g1,g2);
    
    %[BUFta,taxta] = make_trial_averaged_BUF(Durs,.01,wind);
    [bufpars_fit BUFfit t] = find_fourier_BUF_fit(BUFta,taxta);
    durs1S = Durs(Durs(:,2)==1,1); durs2S = Durs(Durs(:,2)==2,1);
    [foo CI_gam1] = gamfit(durs1S); [foo CI_gam2] = gamfit(durs2S);
    
    %%
    
    if 1
        bigFigure; subplot(1,2,1);
        plot(taxta,BUFta,'b',t,BUFfit,'r--');
        axis([0 15 0 1]);  mk_Nice_Plot; 
        %title(['LSE fit for BUF '...
         %   num2str(g1) '|' num2str(g2) ', found ' num2str(bufpars_fit)]);
        
        h1 = text(.2,.98,sprintf('underlying parameters %1.2f %1.2f, %1.2f %1.2f',...
            g1(1),g1(2),g2(1),g2(2)));
        set(h1,'Color',[0 0 1],'FontSize',18)
        
        h2 = text(.2,.93,sprintf('   least squares fit with %1.2f %1.2f, %1.2f %1.2f',...
            bufpars_fit(1),bufpars_fit(2),bufpars_fit(3),bufpars_fit(4)));
        set(h2,'Color',[1 0 0],'FontSize',18)
        
        
        
        subplot(2,2,2);
        
        [h_bar1 sc] = plot_gamma_hist_fit(durs1S,bufpars_fit(1:2),g1); %title(['Subject ' num2str(ind)]);
        hg1 = text(12,2400,sprintf('true parameters: %1.2f, %1.2f',g1(1),g1(2)));
        set(hg1,'Color',[.3 .3 .3],'FontSize',18)
        hg2 = text(12,1750,sprintf('found parameters: %1.2f, %1.2f',...
            bufpars_fit(1),bufpars_fit(2)));
        set(hg2,'Color',[1 0 0],'FontSize',18)
        title('grouped')
        set(h_bar1, 'facecolor',[250,188,81]/255)
        
        %text(30,1000,num2str(CI_gam1))
        %hold on; plot(xax,g1pdf,'Color',[.3 .3 .3]);
        %legend(sprintf('%d samples',length(durs1S)),sprintf('found k = %3f \theta = %3f', ...
         %   bufpars_fit(1:2)), sprintf('true k = %3f \theta = %3f',g1));
        
        subplot(2,2,4);
        [h_bar2 sc] = plot_gamma_hist_fit(durs2S,bufpars_fit(3:4),g2); %title(['Subject ' num2str(ind)]);
        hs1 = text(14,2400,sprintf('true parameters: %1.2f, %1.2f',g2(1),g2(2)));
        set(hs1,'Color',[.3 .3 .3],'FontSize',18)
        hs2 = text(14,2050,sprintf('found parameters: %1.2f, %1.2f',...
            bufpars_fit(3),bufpars_fit(4)));
        set(hs2,'Color',[1 0 0],'FontSize',18)
        title('split')
        set(h_bar2, 'facecolor', [87,195,226]/255)
        
        betweenSubjsBUFs(ind,:) = BUFta;
    end
   
    [tot_winning1(ind) pvals1(ind) ksstat1(ind)] = ...
        goodness_of_gamma_fit(durs1S,bufpars_fit(1:2));
    [tot_winning2(ind) pvals2(ind) ksstat2(ind)] = ...
        goodness_of_gamma_fit(durs2S,bufpars_fit(3:4));
end

proportionGoodFits = 1-mean([tot_winning1 tot_winning2])
mn_pval = mean([pvals1 pvals2])
mn_ksDistance = mean([ksstat1 ksstat2])