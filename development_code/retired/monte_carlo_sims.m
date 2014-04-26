% script to generate monte carlo simulations


%% bufs
g1 = [2 2]; g2 = [2 5];
durs_tot = make_2gamma_distrs(g1,g2,55000);

durs_longtrial = durs_tot(1:11000,:);

durs_shorttrial = durs_tot;

durs_shorttrial(2:10:end,:) = zeros(size(durs_shorttrial(2:10:end,:)));

length_long = sum(durs_longtrial)
length_short = sum(durs_shorttrial)


[BUFlt taxlt] = make_switchTriggeredBUF(durs_longtrial);
[BUFst taxst] = make_trial_averaged_BUF(durs_shorttrial);

opt.T = 40; opt.m = 12;
[BUFmod taxmod] = make_fourier_buildup_function([g1 g2],opt);

bufmod_cmpr = interp1(taxmod,BUFmod,taxst,'spline');

rSquared_mod = calc_rSquared(BUFst,bufmod_cmpr)
rSquared_lt = calc_rSquared(BUFst,BUFlt)
axis([0 10 0 .8]);
green = [.6 1 .6];
figure; plot(taxst,BUFst,'b-')
hold on; plot(taxlt,BUFlt,'Color',[0 .75 .75]);
plot(taxmod,BUFmod,'r--')
mk_Nice_Plot
xlabel('time (s)'); ylabel('p(2 str)');
legend('trial average','switch-triggered','ARP model fit');

[bufpars_fit BUFfitls taxls] = find_fourier_BUF_fit(BUFst,taxst,0,opt);

%% hists
durs1 = durs_longtrial(durs_longtrial(:,2)==1,1);
durs2 = durs_longtrial(durs_longtrial(:,2)==2,1);

t = 0:.1:15; g1pdf = gampdf(t,g1(1),g1(2)); g2pdf = gampdf(t,g2(1),g2(2));
g1fit = gampdf(t,bufpars_fit(1),bufpars_fit(2)); 
g2fit = gampdf(t,bufpars_fit(3),bufpars_fit(4));

figure; subplot(211); mk_Nice_Hist(durs1); hold on;
plot(t,g1pdf,'b-')%,t,g1fit,'r--'); 
mk_Nice_Plot;
legend('histogram','gamma pdf'); 

subplot(212); mk_Nice_Hist(durs2); hold on;
plot(t,g2pdf,'b-')%t,g2fit,'r--'); 
mk_Nice_Plot;
legend('histogram','gamma pdf');

%% and empirical data

[BUFs08 taxs08] = make_switchTriggeredBUF(durs,.01,15);
opt.T = 15; opt.m = 12;

durs1 = durs(durs(:,2)==1,1);
durs2 = durs(durs(:,2)==2,1);
dursLength = min(length(durs1),length(durs2));
        durs1 = durs1(1:dursLength); durs2 = durs2(1:dursLength);
        


durs1 = durs(durs(:,2)==1,1);
[g1 alpha beta fVal] = find_gamma_pars(durs1);

% % [min_Alpha, betaAtMinAlpha, max_Alpha, betaAtMaxAlpha]=...
% %     find_gamma_confidence_intervals(alpha,beta,durs1,fVal,g1,bPlot);
% 
% g1_LowerUpperBounds = [min_Alpha max_Alpha; betaAtMinAlpha betaAtMaxAlpha];


durs2 = durs(durs(:,2)==2,1);
[g2 alpha beta fVal] = find_gamma_pars(durs2);

figure; subplot(211)
mk_Nice_Hist(durs1); hold on;

x = linspace(0,max(durs1)+2,200);
y = gampdf(x,g1(1),(g1(2)));
plot(x,y,'b'); mk_Nice_Plot
legend('histogram','MLE fit to gamma')

subplot(212); mk_Nice_Hist(durs2); hold on;
x = linspace(0,max(durs2)+2,200);
y = gampdf(x,g2(1),(g2(2)));
plot(x,y,'b'); mk_Nice_Plot
legend('histogram','MLE fit to gamma')

[BUFfit8 taxfit8] = make_fourier_buildup_function([g1;g2],opt);

bufmod_cmpr = interp1(taxfit8,BUFfit8,taxs08,'spline');

rSquared_mod = calc_rSquared(BUFs08,bufmod_cmpr)
