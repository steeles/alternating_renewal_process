
[u1 u2 s1 s2 tax n1 n2 iboth pars] = noise_adaptation;

% try messing with this to change nSamples:

pars.t_in_seconds = 1000;

pars.Gamma = 0.7;
pars.sig = .09;



tau_ax = [100 200 300 400 500 600 700 800 900 1000];
nTaus = length(tau_ax);
tau_hat(nTaus) = 0;

for ind = 1:nTaus

pars.t_in_seconds = 1000;

pars.Gamma = 0.7;
pars.sig = .09;
pars.tau_slow = tau_ax(ind);

bPlot = 1;

[u1 u2 s1 s2 tax n1 n2 iboth pars] = noise_adaptation(pars,bPlot);
xlim = ([0 20]);
[T1 T2 Durs] = timecourse2durs(u1, u2, tax);

Durs = [0 0; Durs];

[parmhat fval maxr output] = estimate_cumhist_pars(Durs,[],1);

tau_hat(ind) = parmhat(end);
end

figure; plot(tau_ax,tau_hat); mk_Nice_Plot; title('tauH vs tauA')

xlabel('tauA'); ylabel('tau cumhist'); title('tauH vs tauA');
legend(sprintf('G=%.1f, sig = %.2f',pars.Gamma,pars.sig));