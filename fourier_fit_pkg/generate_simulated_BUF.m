% generate_simulated_BUF

nSwitches = 1000;
bufpars = [2,.5,5,.5];

a0 = bufpars(1); th0 = bufpars(2); a1 = bufpars(3); th1 = bufpars(4); % i think? unless it's theta

% Now I generate the dominance durations from each distribution for
% nSwitches/2 samples on each of nTrials
durs1=gamrnd(a0,th0,nSwitches/2,1);

% dominance durations for percept 2
durs2=gamrnd(a1,th1,nSwitches/2,1);

Durs=[];
Durs(1:2:length(durs1)+length(durs2)-1,:)=[durs1 ones(length(durs1),1)];
Durs(2:2:length(durs1)+length(durs2),:)=[durs2 ones(length(durs2),1)*2];

[BUF tax] = make_buildup_function3(Durs, .001, 10);