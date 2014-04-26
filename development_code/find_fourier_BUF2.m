% find_fourier_BUF2
% takes in a BUF and time axis as well as an initial guess at the 4 fourier
% BUF parameters (shape and scale pars of 2 gamma distributions) and
% returns a least-squares fit
% takes input of an "empirical" BUF as well as its time axis for
% interpolation with the BUFproposed in compare_buildup_functions
% 
% new code generates random monte carlo parameters and random search
% parameters

%clear;
%nSwitches = 1000;

randBounds = [1 3];

g1 = rand(1,2).*[diff(randBounds), 5*diff(randBounds)] + randBounds(1);
g2 = rand(1,2).*[diff(randBounds), 5*diff(randBounds)] + randBounds(1);

bufpars_true = [g1 g2];

a0 = bufpars_true(1); th0 = bufpars_true(2); 
a1 = bufpars_true(3); th1 = bufpars_true(4); % 

% Now I generate the dominance durations from each distribution for
% nSwitches/2 samples on each of nTrials
durs1=gamrnd(a0,th0,nSwitches/2,1);

% dominance durations for percept 2
durs2=gamrnd(a1,th1,nSwitches/2,1);

Durs=[];
Durs(1:2:length(durs1)+length(durs2)-1,:)=[durs1 ones(length(durs1),1)];
Durs(2:2:length(durs1)+length(durs2),:)=[durs2 ones(length(durs2),1)*2];

[BUFsim tax] = make_buildup_function3(Durs, .01, 20);

%%

bufpars0 = rand(1,4)*diff(randBounds).*[1 5 1 5] + randBounds(1);
opt.T = 20; opt.m = 8;
f = @(bufpars_fit)compare_buildup_functions2(bufpars_fit,BUFsim,tax,opt);
options = optimset('MaxFunEvals', 10000, 'MaxIter', 10000);
[bufpars_fit fval exitFlag] = fminsearch(f,bufpars0,options);

[BUFfit t] = make_fourier_buildup_function(bufpars_fit,opt);
[BUFtrue t2] = make_fourier_buildup_function(bufpars_true,opt);

%BUF_up = interp1(t,BUFfit,tax);
figure;
plot(t,BUFfit,tax,BUFsim,t2,BUFtrue); title(num2str([bufpars_fit; bufpars_true]))
legend('fit','simulated','true')


