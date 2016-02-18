function [BUF tax stdev] = make_trial_averaged_BUF(durs,timestep,window)

% I'ma assume we start with a durns_corrected array with 0's between trials


if ~exist('timestep','var')
timestep = .1; end
if ~exist('window','var')
window = 10; end

if durs(end,:)~=[0 0]
    durs(end+1,:) = [0 0];
end

between_trials = find(durs(:,2)==0);
nTrials = length(between_trials);

percepts(nTrials,window/timestep)=0;
tax = timestep:timestep:window;

for tInd = 2:nTrials
    durs_set = durs(between_trials(tInd-1)+1:between_trials(tInd),:);
    cutoff = find(cumsum(durs_set(:,1))>=window,1);
    
    timecourse=[];
    
    for sw = 1:cutoff
        if durs_set(sw,2)==1
            timecourse = [timecourse zeros(1,ceil(durs_set(sw,1)/timestep))];
        else
            timecourse = [timecourse ones(1,ceil(durs_set(sw,1)/timestep))];
        end
    end

    if length(timecourse)<window/timestep
        disp(['Trial # ' num2str(tInd) ' excluded']);
    else
        percepts(tInd-1,1:window/timestep) = timecourse(1:window/timestep);
    end
end
rowscounter = size(percepts,1);
BUF = mean(percepts);
stdev = std(percepts);