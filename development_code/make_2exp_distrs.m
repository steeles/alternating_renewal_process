% mk_2_exp_distrs

% uses rate parameters lambda, reparameterizes to mean mu
% Durs = make_2exp_distrs(L1,L2,nSwitches)
function Durs = make_2exp_distrs(L1,L2,nSwitches)
%clear all
if ~exist('nSwitches','var')
nSwitches = 400;
end

if ~exist('L1','var')
    L1 = .5; L2 = .3;
end

% Now I generate the dominance durations from each distribution for
% nSwitches/2 samples on each of nTrials
Durs1=exprnd(1/L1,nSwitches/2,1);

% dominance durations for percept 2
Durs2=exprnd(1/L2,nSwitches/2,1);

Durs=[];
Durs(1:2:length(Durs1)+length(Durs2)-1,:)=[Durs1 ones(length(Durs1),1)];
Durs(2:2:length(Durs1)+length(Durs2),:)=[Durs2 ones(length(Durs2),1)*2];


