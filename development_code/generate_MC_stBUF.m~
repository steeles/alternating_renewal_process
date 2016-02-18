function [BUF,tax,Durs] = generate_MC_stBUF(g1,g2,nDurs,wind,tstep)

if ~exist('nDurs','var')
    nDurs = 1000;
end
if ~exist('tstep','var')
    tstep = .01;
end

if ~exist('wind','var')
    wind = 41;
end

nSwitches = nDurs; Durs = [];

for tInd = 1:nDurs
    
    tmp = make_2gamma_distrs(g1,g2,nSwitches-1);
    cutoff = find(cumsum(tmp(:,1))>wind,1);
    Durs = [Durs;
        0 0 ; tmp(1:cutoff,:)]; %nSwitches has to be odd
    
end

[BUF,tax] = make_trial_averaged_BUF(Durs,tstep,wind);

