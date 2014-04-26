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

h1=figure;
nConditions = 2;

for cond = 1:nConditions
    rawdata = result(cond).rawdata;
    figure;
    [k2v,k2tv] = plotKHvst_ss(rawdata,num2str(DF_pars(cond)));
    k2tv = k2tv/(max(k2tv)); % make k2tv = 1 to wind up with p(percept=segr);
    
    Durs = diff(k2v); %convert timestamps to durations
    Durs = Durs(2:2:end); percept_segr = k2tv(2:2:end);
    % first entry of k2v is typically the end time of the first percept; we
    % should throw this one away as the first duration is usually different
    % from the rest
    % we want to event lock to each zero in percept_segr after the first
    % zero
    events_to_lock = find(percept_segr==0); 
    events_to_lock = events_to_lock(1:end-1);
   bad_data = 0;
    % outer for loop aligns to the next 0, coherent percept
    for switches = 1:length(events_to_lock)

        lock_to_coh = events_to_lock(switches); % pick out which coherent epoch we're locking to
        durVec = Durs(lock_to_coh); % make first entry the coh we're locking to
        next_entry = 1;
        
        
        % for each percept_segr==0 value, collect info for time window
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
   subplot(2,1,cond); plot(xax,p_segregated); 
   title(['DF = ' num2str(DF_pars(cond)) ', ' num2str(nTrials) ' samples']);

    
    conditionDurs = result(cond).data;
    
    nonzeroInds = conditionDurs(:,2)~=0;
    conditionDurs = conditionDurs(nonzeroInds,:);
    
    dataInds1 = conditionDurs(:,2)==1;
    dataInds2 = conditionDurs(:,2)==2;
    
    Durs1 = conditionDurs(dataInds1,1)';
    Durs2 = conditionDurs(dataInds2,1)';
    
    h2 = figure; subplot(2,1,1); [count,bin1]=mk_Nice_Hist(Durs1); 
    
    subplot(2,1,2); [count,bin2]=mk_Nice_Hist(Durs2);
    
    nBoot = 100;
    
    g1s(2,nBoot) = 0;
    g2s(2,nBoot) = 0;
    
       for bootInd = 1:nBoot

        % KEY STEP IN BOOTSTRAPPING- just generate a random list of the indices
        % of the data values that you want to throw into this estimate- this
        % constitutes sampling with replacement, as you choose a truly random set
        % of the values going into this analysis
        samplingInds1 = round(rand(1,length(Durs1))*(length(Durs1)-1))+1;
        samplingInds2 = round(rand(1,length(Durs2))*(length(Durs2)-1))+1;

        % your new x and y vectors are now available
        newDurs1 = Durs1(samplingInds1);
        newDurs2 = Durs2(samplingInds2);

        % and you run the regression on your "new" ;) data
        g1 = find_gamma_fit(newDurs1);
        g2 = find_gamma_fit(newDurs2);

        g1s(:,bootInd)=g1;
        g2s(:,bootInd)=g2;
        
       end
    g1_pars_mean(:,cond) = mean(g1s,2);
    g1_pars_std(:,cond) = std(g1s,0,2);
    
    g2_pars_mean(:,cond) = mean(g2s,2);
    g2_pars_std(:,cond) = std(g2s,0,2);
    
    g1.shape = g1_pars_mean(1,cond);
    g1.scale = 1/g1_pars_mean(2,cond);
    
    g2.shape = g2_pars_mean(1,cond);
    g2.scale = 1/g2_pars_mean(2,cond);
    
    figure(h2); subplot(211); hold on;
    plot(bin1,gampdf(bin1,g1.shape,g1.scale),'r--');
    subplot(212); hold on;
    plot(bin2,gampdf(bin2,g2.shape,g2.scale),'r--');
    
    dom_dur_2_distrs(g1_pars_mean(:,cond),g2_pars_mean(:,cond)); title(num2str(DF_pars(cond)));
    
    
    
 end   