% find_fourier_BUF
% takes in a BUF and time axis as well as an initial guess at the 4 fourier
% BUF parameters (shape and scale pars of 2 gamma distributions) and
% returns a least-squares fit
% takes input of an "empirical" BUF as well as its time axis for
% interpolation with the BUFproposed in compare_buildup_functions

%find_fourier_BUF(BUF,tax,bufpars0)

clear;
generate_simulated_BUF;

bufpars0 = [a0,th0,a1,th1];

f = @(bufpars)compare_buildup_functions(bufpars,BUF,tax);

[bufpars fval] = fminsearch(f,bufpars0);


[BUFfit t] = make_fourier_buildup_function(bufpars);

%BUF_up = interp1(t,BUFfit,tax);

plot(t,BUFfit,tax,BUF); title(num2str(bufpars))
