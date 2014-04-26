% make_2gamma_distrs
% modified 4/21/2012 to change Durs array to canonical form, modularize
% edited 8/4/2012 to use k,theta parameterization
% Durs = make_2gamma_distrs(g1,g2,nSwitches)
function Durs = make_2gamma_distrs(g1,g2,nSwitches)
%clear all
if ~exist('nSwitches','var')
nSwitches = 400;
end
if ~exist('g1','var')
    g1 = [2;2]; g2 = [5;2];
end

% Now I generate the dominance durations from each distribution for
% nSwitches/2 samples on each of nTrials
Durs1=gamrnd(g1(1),g1(2),nSwitches/2,1);

% dominance durations for percept 2
Durs2=gamrnd(g2(1),g2(2),nSwitches/2,1);

Durs=[];
Durs(1:2:length(Durs1)+length(Durs2)-1,:)=[Durs1 ones(length(Durs1),1)];
Durs(2:2:length(Durs1)+length(Durs2),:)=[Durs2 ones(length(Durs2),1)*2];


