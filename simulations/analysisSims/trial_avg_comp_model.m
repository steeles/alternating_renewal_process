% trial averaged competition model simulations
clear;

% SERIOUSLY CHANGE THAT FILENAME EACH TIME

% DID YOU CHANGE THE FILENAME
pars = struct('Gamma',.3,'Delta',0,'sig',.09, 'iboth',0.6,'SFA',1,'SD',...
    0,'t_in_seconds',40, 'i1',0, 'i2',+.0, 'filename','low noise equal');
    % OK BUT STOP. DID YOU CHANGE THAT FILENAME
   
    % case pars.filename == normal
        %pars.i1 =...
  
        


%pars.filename = filename;
%% now let's look at how it compares to same pars with switch-triggered

% pars.t_in_seconds = 5000;
% [u1 u2 s1 s2 tax] = noise_adaptation(pars);
% [durs1L durs2L dursL] = timecourse2durs(u1,u2,tax);
% [BUFst taxst nWindows] = make_switchTriggeredBUF(dursL,.01,10);
% 
% g1L = find_gamma_pars(durs1L); g2L = find_gamma_pars(durs2L);
% [error rSquaredL BUFarpL] = compare_buildup_functions2([g1L;g2L],BUFst,taxst);
% 
% figure; plot(taxst,BUFst,taxst,BUFarpL,'r:'); legend(num2str(nWindows));
% title('Long trials, switch triggered average')
% 
% long_trial = v2struct(u1,u2,s1,s2,tax);
% long_trial_outcomes = v2struct(durs1L,durs2L,dursL,taxst,BUFst,nWindows,g1L,g2L,BUFarpL,rSquaredL);
% 
% 

%% 
%pars.t_in_seconds = 20;
    
% let's do nWindows 20 s trials to roughly match smoothness
nTrials = 500;
%nTrials = nWindows;
Durs = [0 0];
%figure;

for ind = 1:nTrials
    [u1 u2 s1 s2 tax] = noise_adaptation(pars);
    [durs1S durs2S durstmp foo] = timecourse2durs(u1,u2,tax);
    Durs = [Durs; durstmp; 0 0];
    %subplot(nTrials,1,ind); plot(tax,u1,tax,u2,'r',tax,s1,':',tax,s2,'r:');
    %axis([0 10 0 1]);
    short_trial(ind) = v2struct(u1,u2,s1,s2,tax,durs1S,durs2S,durstmp);
end

[BUFta taxta] = make_trial_averaged_BUF(Durs);
durs1S = [short_trial.durs1S]; durs2S = [short_trial.durs2S]; 
%durs1S_trunc = [short_trial.d1_trunc]; durs2S_trunc = [short_trial.d2_trunc];
g1S = find_gamma_pars(durs1S); g2S = find_gamma_pars(durs2S);
% [BUFarpS taxarp] = make_fourier_buildup_function([g1;g2]);
% figure;
% plot(taxtasim,BUFtasim, taxarp,BUFarp,'r:');
% axis([0 10 0 1]);
[error rSquaredS BUFarpS] = compare_buildup_functions2([g1S;g2S], BUFta, taxta);

figure; plot(taxta,BUFta,taxta,BUFarpS,'r:');
title('Trial Averaged')


short_trial_outcomes = v2struct(durs1S,durs2S,Durs,g1S,g2S,BUFta,taxta,BUFarpS,rSquaredS);

%% save the right things
if pars.Gamma == 0.1
    filename = ['~//Dropbox/my codes/rinzel/simulations/simulation_results&figs/low-adapt_G=.1/' pars.filename '.mat'];
    fnameSumm = ['~//Dropbox/my codes/rinzel/simulations/simulation_results&figs/low-adapt_G=.1/' pars.filename '_summary.mat'];
elseif pars.Gamma == 0.3
    filename = ['~//Dropbox/my codes/rinzel/simulations/simulation_results&figs/high-adapt_G=.3/' pars.filename '.mat'];
end

save(filename,'pars','short_trial');
save(fnameSumm,'short_trial_outcomes','pars')