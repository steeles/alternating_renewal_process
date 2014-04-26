function [BUF rowsCounter] = make_buildup_function2(durs,timestep,window)

% [BUF rowsCounter] = make_buildup_function2(durs,timestep,window)
% 
% this function takes experimental data in the durns_corrected array
% created by KPushETs_ss which has the form nPercepts x 2, with percpet
% durations in the first column and percept IDs in the second. Separate
% trials are separated by a 0 0 row

% clear
% KPushETs_ss

if ~exist('timestep','var')
timestep = .1; end
if ~exist('window','var')
window = 40; end

timeline = timestep:timestep:window;

percepts(1,window/timestep)=0;


rowsCounter = 1;

if any(diff(durs(:,2))==0), 
    error('Non-alternating percept found');
end

if durs(1,2) ~=1
    error('Coherent percept not first')
end
    
    p1_inds = find(durs(:,2)==1);
    dursRemaining = durs;
    while(sum(dursRemaining(:,1))>window)
        
        
        
        setCounter = 1;
        %dursSet = dursRemaining(setCounter,1);
        dursSet = [];
        while sum(dursSet)<window
            
            dursSet = [dursSet dursRemaining(setCounter,1)];
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
       
        
       if rowsCounter>size(p1_inds)
           break
       else
           dursRemaining = durs(p1_inds(rowsCounter):end,:); 
       end
    end
BUF = (sum(percepts,1)./rowsCounter);

%plot(timeline,BUF);
