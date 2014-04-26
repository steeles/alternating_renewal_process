%
% make_exp_buildup
% Sara Steele, March 2012- for John Rinzel buildup experiments

% just as in dom_dur_2_distrs, I'm going to make a matrix of durations and
% then convert them to time courses

load 08.18.10.2011_DF37_3trl.mat

tmp = [result.params]; foo = reshape(tmp,6,5)';
DF_pars = foo(:,6);
window = 20; % how long do we want to look at buildup for?
%endcut = 1; % how much do we want to cut off the end of the trial? might fix errors
dt = .1;
cutoff = window/dt;

h1=figure;h3=figure;
nConditions = 2;

for cond = 1:nConditions
    rawdata = result(cond).rawdata;
    figure;
    [k2v,k2tv] = plotKHvst_ss(rawdata,num2str(DF_pars(cond)));
    k2tv = k2tv/(max(k2tv)); % make k2tv = 1 to wind up with p(percept=segr);
    
    Durs = diff(k2v); %convert timestamps to durations
    Durs = Durs(2:2:end); 
    percept_segr = k2tv(2:2:end);
    percept_segr = percept_segr(1:length(Durs));
    Durs1 = Durs(percept_segr==0);
    Durs2 = Durs(percept_segr==1);
    % first entry of k2v is typically the end time of the first percept; we
    % should throw this one away as the first duration is usually different
    % from the rest
    % we want to event lock to each zero in percept_segr after the first
    % zero
    events_to_lock = find(percept_segr==0); 
    %events_to_lock = events_to_lock(1:end-1);
   bad_data = 0;
   
    % outer for loop aligns to the next 0, coherent percept
    for switches = 1:length(events_to_lock)

        lock_to_coh = events_to_lock(switches); % pick out which coherent epoch we're locking to
        durVec = Durs(lock_to_coh); % make first entry the coh we're locking to
        next_entry = 1;
        
        
        % inner loop collects percept durations for time window
        while(sum(durVec)<window)
            if lock_to_coh+next_entry>length(Durs)
                bad_data = 1; break
            end
            durVec = [durVec Durs(lock_to_coh+next_entry)];
            next_entry = next_entry+1;
        end
        if bad_data==1
            break
        end
        
        durMat{switches,:} = durVec;
    end
    
    
    
    % durMat is like nTrials x nSwitches except neither is specified
    
    for ind=1:length(durMat);
        timecourse=[];
    perceptTimes = durMat{ind};
    
    if sum(perceptTimes)<window
        break, end
    
    for sw=1:length(perceptTimes)
        if mod(sw,2)==1 
            timecourse=[timecourse zeros(1,...
                ceil(perceptTimes(sw)/dt))];
        else    %using ceil to avoid roundoff errors affecting dimension of the mtx
            timecourse=[timecourse ones(1,...
                ceil(perceptTimes(sw)/dt))];
        end
    end
    
    timecourse=timecourse(1:cutoff);

    percepts(ind,:)=timecourse;

    end
    nTrials = length(durMat);
    p_segregated = sum(percepts)/nTrials;
    figure(h1);
    xax = dt:dt:window;
   subplot(nConditions,1,cond); plot(xax,p_segregated); 
    h_t = title(['DF = ' num2str(DF_pars(cond)) ', ' num2str(nTrials) ' samples']);
    mk_Nice_Plot(h_t);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    figure; subplot(2,1,1); [count,bin1]=mk_Nice_Hist(Durs1); hold on;
    g1 = find_gamma_fit(Durs1,1); h_t = title(num2str(DF_pars(cond)));
    mk_Nice_Plot(h_t);
    
    subplot(2,1,2); [count,bin2]=mk_Nice_Hist(Durs2); hold on;
    g2 = find_gamma_fit(Durs2,1); mk_Nice_Plot
    
    filename = ['exp_gam_hists_df_', num2str(DF_pars(cond))];
    print('-dpdf',filename)
    
    
    figure(h3);
    subplot(2,1,cond); dom_dur_2_distrs(g1,g2);
    h_t = title(num2str(DF_pars(cond)));
    mk_Nice_Plot(h_t);
    
    
end
    figure(h1);
    print -dpdf 'exp_gam_buildups'
    figure(h3);
    print -dpdf 'exp_simulated_gam_buildups'
    
