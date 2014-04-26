% this function takes experimental data in the percept_durns_in_order array
% created by KPushETs_ss which has the form nPercepts x 2, with percpet
% durations in the first column and percept IDs in the second. Separate
% trials are separated by a 0 0 row

%function make_buildup_function(durns_corrected)
KPushETs_ss

timestep = .1;
window = 20;
timeline = timestep:timestep:window;

percepts(1,window/timestep)=0;


% first I should cut out the mysterious "first duration" from my durations
% array

betweenTrials=find(durns_corrected(:,2)==0);

Durs{length(betweenTrials)}=0;

for ind = 1:length(betweenTrials)-1
Durs{ind} = durns_corrected((betweenTrials(ind)+1):(betweenTrials(ind+1)-1),:);
end
Durs{length(betweenTrials)}=durns_corrected(betweenTrials(end)+1:end,:);

rowsCounter = 1;

for tInd = 1:length(Durs)
    durs = Durs{ind};
    
    p1_inds = find(durs(:,2)==1);
    p1_inds = p1_inds(2:end); % start with the second p1
    
    dursRemaining = durs; 
    
    
    while(sum(dursRemaining)>window)
        dursRemaining = durs(p1_inds(rowsCounter):end,:);
        
        
        setCounter = 1;
        dursSet = dursRemaining(setCounter,1);
        
        while sum(dursSet)<window
            
            dursSet = [dursSet dursRemaining(setCounter)];
            setCounter = setCounter+1;
        end
        
        
        timecourse=[];
        
    for sw=1:length(dursSet)
        if mod(sw,2)==1 %trying to avoid roundoff errors affecting dimension of the mtx
            timecourse=[timecourse zeros(1,ceil(dursSet(sw)/timestep))];
        else
            timecourse=[timecourse ones(1,ceil(dursSet(sw)/timestep))];
        end
    end
        timecourse = timecourse(1:window/timestep);
        
        percepts(rowsCounter,:) = timecourse;
        rowsCounter = rowsCounter+1;
        
        
    end
end
