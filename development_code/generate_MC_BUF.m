function [BUF,tax,Durs] = generate_MC_BUF(g1,g2,nTrials,wind,tstep)

if ~exist('nTrials','var')
    nTrials = 1000;
end
if ~exist('tstep','var')
    tstep = .01;
end

if ~exist('wind','var')
    wind = 41;
end

nSwitches = wind; Durs = [];

for tInd = 1:nTrials
    
    tmp = make_2gamma_distrs(g1,g2,nSwitches-1);
    cutoff = find(cumsum(tmp(:,1))>wind,1);
    Durs = [Durs;
        0 0 ; tmp(1:cutoff,:)]; %nSwitches has to be odd
    
end

[BUF,tax] = make_trial_averaged_BUF(Durs,tstep,wind);

