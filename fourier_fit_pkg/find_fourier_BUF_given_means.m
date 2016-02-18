% find_fourier_BUF
% takes in a BUF and time axis as well as an initial guess at the 4 fourier
% BUF parameters (shape and scale pars of 2 gamma distributions) and
% returns a least-squares fit
% takes input of an "empirical" BUF as well as its time axis for
% interpolation with the BUFproposed in compare_buildup_functions

%find_fourier_BUF(BUF,tax,bufpars0)

% reparameterized to allow us to constrain by the two means and the two
% shape parameters

clear;
%generate_simulated_BUF; % monte carlo

%truepars = [2 .5 5 .5];


if ~exist('bufpars0','var') || isempty(bufpars0)
    randBounds = [1 3];
    bufpars0 = rand(1,4)*diff(randBounds).*[1 5 1 5] + randBounds(1);
end
truepars = bufpars0;
a0 = truepars(1); a1 = truepars(3); th0 = truepars(2); th1 = truepars(4);
opt.T = 40; opt.m = 12;
[BUF tax] = make_fourier_buildup_function(truepars,opt);
mu0=a0*th0; mu1 = a1*th1;

%bufpars0 = [a0,th0,a1,th1]; % these are the true parameters for the mc buf
shapepars0 = [a0 a1] + rand(1,2);
% mu0=a0*th0; mu1 = a1*th1;


%f = @(bufpars)compare_buildup_functions(bufpars,BUF,tax); %function to calculate sum of squared errors between 
                                                        % given and
                                                        % proposed bufs in
                                                        % the search

f_mns = @(shapepars)compare_buildup_functions_with_mns(shapepars,BUF,tax,mu0,mu1,opt);


%[bufpars fval] = fminsearch(f_mns,shapepars0); 
[shapepars fval] = fminsearch(f_mns,shapepars0); 

bufpars = [shapepars(1) mu0/shapepars(1) shapepars(2) mu1/shapepars(2)];
[BUFfit t] = make_fourier_buildup_function(bufpars);

%BUF_up = interp1(t,BUFfit,tax);

plot(t,BUFfit,'bo',tax,BUF,'r'); title(num2str(bufpars))
