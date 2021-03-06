

clear all

nSubjects = 10;
nTrials = 1;

% from, what parameter values, etc

bRandom = 1; % generate random parameters for the gamma densities
randBounds = [1 4]; % sets minimum value and range for shape parameter
bSmall_scale = 1; %

tol = .1;%1e-2;

% we are going to count the analytical hits as "matches" (on bufpars)
matches = zeros(1,nSubjects);

what_happened_here = []; % nMisses x 4 (stacks of bufpars)
badfits = [];

% we are going to count the empirical hits as "winning" for each distr

tot_win1 = zeros(1,nSubjects);
tot_win2 = zeros(1,nSubjects);


tot_winning1 = zeros(1,nSubjects);
pvals1 = zeros(1,nSubjects);
ksstat1 = zeros(1,nSubjects);
tot_winning2 = zeros(1,nSubjects);
pvals2 = zeros(1,nSubjects);
ksstat2 = zeros(1,nSubjects);

%% recover paramters from 100 analytic bufs with 4-par


for ind = 1:nSubjects
    
    
    g1 = rand(1,2).*[diff(randBounds), diff(randBounds)] + randBounds(1);
    g2 = rand(1,2).*[diff(randBounds), diff(randBounds)] + randBounds(1);
    %    g1 = [1.45 3.26]; g2 = [2.08 5.12]; % for paper
   
   g1 = rand(1,2).*[diff(randBounds), 4*diff(randBounds)] + randBounds(1);
   g2 = rand(1,2).*[diff(randBounds), 4*diff(randBounds)] + randBounds(1);
%g1 = [2 2]; g2 = [2 5];

    % g1=[1.06 3.64]; g2 = [2.68 2.65];
    
    %     xax = 0:.1:30;
    %     g1pdf = gampdf(xax,g1(1),g1(2));
    %     %figure; plot(xax,g1pdf);
    %
    %     g2pdf = gampdf(xax,g2(1),g2(2));
    %     %figure; plot(xax,g2pdf);
    %
    bufpars = [g1 g2];
    %% using BUF to predict the gamma pars
    opt.T = 40; opt.m = 12;
    [BUF,tax] = make_fourier_buildup_function(bufpars,opt);
    [bufpars_fit BUFfit t] = find_fourier_BUF_fit(BUF,tax,0,opt);
    
    if sum(abs(bufpars_fit-bufpars))<tol
        matches(ind) = 1;
    else
        what_happened_here = [what_happened_here; bufpars; bufpars_fit; 0 0 0 0];
    end
    
    [BUFta,taxta,Durs] = generate_MC_BUF(g1,g2,1000);
    durs1S = Durs(Durs(:,2)==1,1); durs2S = Durs(Durs(:,2)==2,1);
    mu0 = mean(durs1S); mu1 = mean(durs2S);
    [bufpars_fit1 BUFfit1 t1] = find_fourier_BUF_fit(BUFta,taxta,1);
    [bufpars_fit2 BUFfit2 t2] = find_fourier_BUF_fit_given_mns(BUFta,taxta,mu0,mu1);
    
    if any(bufpars_fit2<0) || any(bufpars_fit1<0)
        disp('wanky pars!'); 
        what_happened_here = [what_happened_here; bufpars; bufpars_fit1; ...
            bufpars_fit2; 1 1 1 1];
        %continue
    else
        tot_win1(ind) = goodness_of_gamma_fit(durs1S,bufpars_fit1(1:2),1);
        tot_win2(ind) = goodness_of_gamma_fit(durs2S,bufpars_fit2(3:4),1);
        
        [tot_winning1(ind) pvals1(ind) ksstat1(ind)] = ...
        goodness_of_gamma_fit(durs1S,bufpars_fit2(1:2));
    [tot_winning2(ind) pvals2(ind) ksstat2(ind)] = ...
        goodness_of_gamma_fit(durs2S,bufpars_fit2(3:4));
    end
    if ~tot_winning1(ind) || ~tot_winning2(ind)
        badfits = [badfits; bufpars; bufpars_fit2; 0 0 0 0];
        %BUFfit = BUFfit2; t = t2; plot_reverse_fits
    end
end

propGood4par = 1-mean([tot_win1 tot_win2])

proportionGoodFits = 1-mean([tot_winning1 tot_winning2]) % fail to reject null hypothesis that distr is same
mn_pval = mean([pvals1 pvals2])
mn_ksDistance = mean([ksstat1 ksstat2])

analytic_fit = sum(matches)/length(matches)

if 0
    plot(taxta,BUFta,'bo',t1,BUFfit1,'r'); title(num2str(bufpars - bufpars_fit2));
end

%% show analytic fits
xax = 0:.1:30;
    g1pdf = gampdf(xax,g1(1),g1(2));
    %figure; plot(xax,g1pdf);
    
    g2pdf = gampdf(xax,g2(1),g2(2));
    %figure; plot(xax,g2pdf);
    
    g1_fit = bufpars_fit(1:2); g2_fit = bufpars_fit(3:4);
    g1pdf_fit = gampdf(xax,g1_fit(1),g1_fit(2));
    g2pdf_fit = gampdf(xax,g2_fit(1),g2_fit(2));
    
bigFigure; 
subplot(1,2,1);
plot(tax,BUF,'b',tax,BUFfit,'r--');
axis([0 15 0 1]);  mk_Nice_Plot;
%title(['LSE fit for BUF '...
%   num2str(g1) '|' num2str(g2) ', found ' num2str(bufpars_fit)]);

h1 = text(.2,.975,sprintf('true: %1.2f, %1.2f; %1.2f, %1.2f',...
    g1(1),g1(2),g2(1),g2(2)));
set(h1,'Color',[0 0 1],'FontSize',28)

h2 = text(.3,.92,sprintf('   fit: %1.2f, %1.2f; %1.2f, %1.2f',...
    bufpars_fit(1),bufpars_fit(2),bufpars_fit(3),bufpars_fit(4)));
set(h2,'Color',[1 0 0],'FontSize',28)



subplot(2,2,2); 
plot(xax,g1pdf,'b',xax,g1pdf_fit,'r--'); mk_Nice_Plot
title('grouped')



subplot(2,2,4); 
plot(xax,g2pdf,'b',xax,g2pdf_fit,'r--'); mk_Nice_Plot
title('split')


