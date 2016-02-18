% [BUF timeline rowsCounter] = make_switchTriggeredBUF(durs,timestep,window)
%
% this function takes experimental data in the durns_corrected array
% created by KPushETs_ss which has the form nPercepts x 2, with percept
% durations in the first column and percept IDs in the second. Separate
% trials are separated by a 0 0 row
%
% converted from make_buildup_function3 8/7/2012 SS

function [BUF timeline rowsCounter] = make_switchTriggeredBUF(durs,timestep,window)



% clear
% KPushETs_ss

if ~exist('timestep','var')
timestep = .1; end
if ~exist('window','var')
window = 10; end

timeline = timestep:timestep:window;

percepts(1,window/timestep)=0;


rowsCounter = 1;

if any(diff(durs(:,2))==0), 
    disp('Non-alternating percept found');
    BUF = NaN;
    return
end

if durs(1,2) ~=1
    disp('Coherent percept not first');
    BUF = NaN;
    return
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

        
       if rowsCounter<=length(p1_inds)
           dursRemaining = durs(p1_inds(rowsCounter):end,:); 
       else
           dursRemaining = [0]; continue
       end
    end
BUF = (sum(percepts)./rowsCounter);
%rowsCounter
%plot(timeline,BUF);
