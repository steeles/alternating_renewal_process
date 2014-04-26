function test_suite = testFind_gamma_pars_dev
%initTestSuite;


% method of monte carlo simulation

durs = gamrnd(4,1,1000,1);

durs_trunc = durs(1:100) - rand(100,1);
durs(1:100) = [];

durs_trunc = durs_trunc(durs_trunc>0);

g_recovered = find_gamma_pars_dev(durs,durs_trunc);
plot_gamma_hist_fit(durs,g_recovered);


[parmhat] = gamfit([durs;durs_trunc], 5, [zeros(size(durs)); ones(size(durs_trunc))]);
plot_gamma_hist_fit(durs,parmhat);