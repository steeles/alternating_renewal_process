% I want to test the robustness of my fourier buildup code by testing
% simulated buildup functions. I want to demonstrate that increasing number
% of random samples generating each distribution of percept durations
% reduces the least squares error of the fit.
% minimum experimental k, th pars are 1.18, 1.7 
% maximum experimental k, th pars are 2.08, 7.6

% Also I'm going to want to look at periodicity-- where does the kink come
% from, what parameter values, etc

bRandom = 1; % generate random parameters for the gamma densities
randBounds = [0.5 3]; % sets minimum value and range for shape parameter
bSmall_scale = 1; %

for ind = 1:10
    
    if bSmall_scale
        g1(ind,:) = rand(1,2).*[diff(randBounds), diff(randBounds)] + randBounds(1);
        g2(ind,:) = rand(1,2).*[diff(randBounds), diff(randBounds)] + randBounds(1);
    else 
        g1(ind,:) = rand(1,2).*[diff(randBounds), 5*diff(randBounds)] + randBounds(1);
        g2(ind,:) = rand(1,2).*[diff(randBounds), 5*diff(randBounds)] + randBounds(1);
    end
    
    opt.T = 20; opt.m = 12;
    BUF = make_fourier_buildup_function([g1(ind,:) g2(ind,:)],opt,1);
    
    xax = 0:.1:30;
    g1pdf = gampdf(xax,g1(1),g1(2));
    %figure; plot(xax,g1pdf);
    
    g2pdf = gampdf(xax,g2(1),g2(2));
    %figure; plot(xax,g2pdf);
    
    isMonotonic(ind) = all(diff(BUF)>0);
    
    
end
    
sum(isMonotonic)

monoInds = find(isMonotonic);

monoBufpars = [g1(monoInds,:) g2(monoInds,:)];

% opt.T = 20; opt.m = 12;
%
% 
% for ind = 1:length(monoInds)
%     make_fourier_buildup_function(monoBufpars(ind,:),opt,1);
% end

%%
fvalues(10)=0;

Rsq_fit(10)=0;
Rsq_aPriori(10)=0;

trouble = [];
true_vs_start = [];
tcount = 0;
dist_fr_start_pars(10)=0;
for n = 1:5
    nSwitches = 200 * n;
    find_fourier_BUF2; ylabel(['n = ' num2str(nSwitches)]);
    fvalues(n) = fval;
    [tmp Rsq_fit(n)] = compare_buildup_functions2(bufpars_fit,BUFsim,tax);
    [tmp Rsq_aPriori(n)] = compare_buildup_functions2(bufpars_true,BUFsim,tax);
    if exitFlag == 0
        tcount = tcount+1;
        trouble = [trouble n];
        true_vs_start(:,:,tcount) = [bufpars_true; bufpars0];
    end
    dist_fr_start_pars(n) = pdist([bufpars_true; bufpars0]);
        
end


plot(200*[1:10],fvalues); title('error vs sample size')