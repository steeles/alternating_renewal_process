% mk_2_exp_distrs

% uses rate parameters lambda, reparameterizes to mean mu
% Durs = make_2exp_distrs(L1,L2,nSwitches)
function Durs = make_2norm_distrs(n1,n2,nSwitches)
%clear all
if ~exist('nSwitches','var')
nSwitches = 400;
end

if ~exist('L1','var')
    n1 = [0 1]; n2 = [0 1];
end

% Now I generate the dominance durations from each distribution for
% nSwitches/2 samples on each of nTrials
Durs1=randn(nSwitches/2,1)*n1(2) + n1(1); 

% dominance durations for percept 2
Durs2=randn(nSwitches/2,1)*n2(2) + n2(1);

Durs=[];
Durs(1:2:length(Durs1)+length(Durs2)-1,:)=[Durs1 ones(length(Durs1),1)];
Durs(2:2:length(Durs1)+length(Durs2),:)=[Durs2 ones(length(Durs2),1)*2];


