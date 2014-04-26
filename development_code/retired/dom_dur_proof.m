%Dominance_durations proof- Steeles January 2012

clear all
% experimental parameters
nTrials = 100;
nSwitches = 50; % closest way to control duration; sets number of random durations to draw
time_Step = .1;

%gamma distribution parameters
gam_Shape = 2;
gam_Scale = 2;

% generate a bunch of dominance durations for n switches
Durs = gamrnd(gam_Shape,gam_Scale,nTrials,nSwitches);

% now we're going to turn those into their percepts over a fixed time
% interval- the duration of the shortest trial will be the cutoff to trim
% each trial's perceptual timecourse vector to a standard size


trialTime=min(sum(Durs,2));
cutoff=floor(trialTime/time_Step); % want to make sure we don't have
percepts(nTrials,cutoff)=0;         % shorter timecourse vecs than percept mtx


%SOME OTHER STRATEGIES RECOMMENDED BY A. LIND: 
% try, rather than initializing huge mtx of percept (binary? 1
% bit?) time series just concatenate time series of zeroes(1,tsDur)
% and ones(1,tsDur) which might work in vectorized
% also could use boolean to set things according to... some logic


% here; fencepost errors are bad
for ind=1:nTrials
    
    timecourse=[];
    for sw=1:nSwitches
        if mod(sw,2)==1 %trying to avoid roundoff errors affecting dimension of the mtx
            timecourse=[timecourse zeros(1,ceil(Durs(ind,sw)/time_Step))];
        else
            timecourse=[timecourse ones(1,ceil(Durs(ind,sw)/time_Step))];
        end
    end
    

    timecourse=timecourse(1:cutoff);

    percepts(ind,:)=timecourse;

end



plot((1:round(cutoff/9))*time_Step,sum(percepts(:,1:round((cutoff/9)))/nTrials))
xlabel('time (s)')
ylabel('Probability of segregation')
title('Sample buildup function for identical distributions of percept 1 and percept 2')

