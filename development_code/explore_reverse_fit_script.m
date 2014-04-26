

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

%% recover paramters from 100 analytic bufs with 4-par


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
    
    bufpars = [g1 g2];
    %% using BUF to predict the gamma pars
        opt.T = 40; opt.m = 12;
    [BUF,tax] = make_fourier_buildup_function(bufpars,opt);
    [bufpars_fit BUFfit t] = find_fourier_BUF_fit(BUF,tax,0,opt);
    BUFfit = make_fourier_buildup_function(bufpars_fit,opt);
    
end
if 1
    plot(tax,BUF,'b',tax,BUFfit,'r')
    title([num2str(bufpars) num2str(bufpars_fit)])
end

%% recover params from 100 1000 trial bufs with mns
