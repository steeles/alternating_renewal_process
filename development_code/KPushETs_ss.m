%KPushETs_ss.m Sara Steele 4/13/2012 modified from John Rinzel's original

%cd ~/Dropbox/my' codes'/rinzel/experiment_code/data/
bCat = 0;
 %load 08.18.10.2011_DF37_3trl.mat % S08
% load 03.29.11.2011_DF37_3trl.mat % S03
% load 2012.9.25.19.21.100trlDF=5.mat % SS 62 trials
% load 2012.9.27.9.34.100trlDF=5.mat % SS 100 trials
% load 2012.9.27.11.1.50trlDF=5.mat; bCat=1; % catherine
% load 2012.10.8.14.44.50trlDF=5.mat % brisa 1
 
% load 2012.10.8.17.14.50trlDF=5.mat % brisa 2
%load '~/Dropbox/my codes/rinzel/experiment_code/data/2012.7.15.18.25.10trlDF=45.mat'
% not sure what the correct labeling is here, but the listed params are as
% follows:   (Check John's notes to see if there's a way to unscramble
%               conditions)
% result(1), DF = 3; 
% result(2), DF = 4; % result(3:5) empty

% for condition 1, I have 27 + 25 events for the first trial, 12 + 11,
% 12+11 
% = 98 durations + 4 zero rows (between trials)
% highest durns in (1) are 51.719, 39.391
%%
if ~exist('n','var')
n = 1; end


KeyPresses = result(n).rawdata;


perceptdurns_in_order=[];

nTrials = length(result(1).rawdata)/2;
nDurs = [];
for tInd = 1:nTrials
    
    p1 = tInd*2-1; % keypresses corresponding to percept 1 are stored in this cell
    p2 = tInd*2; % keypresses corresponding to percept 2 stored in this cell
    
    
    if isempty(KeyPresses{p1}.Up)
        disp(['Trial # ' num2str(tInd) ' exluded, empty']); continue
    end
    if isempty(KeyPresses{p2}.Up)
        perceptdurns_in_order = [perceptdurns_in_order; zeros(1,2); 20 1]; continue
    end
    numdur1=length(KeyPresses{p1}.Up(:,1));
    numdur2=length(KeyPresses{p2}.Up(:,1));
    
    if numdur1==0
        break,return,end
    
    nDurs = nDurs + numdur1 + numdur2;
    
    kalign=1;
    perceptdurns = [];
    for k=1:numdur1;
        
        % measure elapsed time between when the key went up and when it was
        % first pressed down (ETIME(T1,T0);
        delt=etime(KeyPresses{p1}.Up(k,:),KeyPresses{p1}.Down(kalign,:));
        if delt>0
            durns=[delt 1.];
            perceptdurns= vertcat(perceptdurns,durns);kalign=kalign+1;
        else 'a negative duration, Percept #1'
        end
    end
    kalign=1;
    for k=1:numdur2;
        delt=etime(KeyPresses{p2}.Up(k,:),KeyPresses{p2}.Down(kalign,:));
        if delt>0
            durns=[delt 2.];
            perceptdurns= vertcat(perceptdurns,durns);kalign=kalign+1;
        else 'a negative duration, Percept #2'
        end
    end
    
    coherentCameFirst = etime(KeyPresses{p2}.Down(1,:),KeyPresses{p1}.Down(1,:))>0;
    % now I want to get the percept durations to be in experimental order

    if coherentCameFirst
    tmp = [KeyPresses{p1}.Up; KeyPresses{p2}.Up];
    else
        tmp = [KeyPresses{p1}.Up; KeyPresses{p2}.Up(2:end,:)];
    end

    firstPress = tmp(1,:);
    time_from_first_p1 = [];
    
    for ind = 1:size(tmp) % number of rows this trial
        time_from_first_p1 = [time_from_first_p1 etime(tmp(ind,:),firstPress)];
    end
    
    [a,b] = sort(time_from_first_p1);
    
    % puts the zeros between the trials
    perceptdurns_in_order = [perceptdurns_in_order; zeros(1,2); perceptdurns(b,:)];
    
   
end

perceptdurns_in_order = [perceptdurns_in_order; zeros(1,2)];

 double_presses = find(diff(perceptdurns_in_order(:,2))==0);
    double_presses = [-1 ; double_presses ; length(perceptdurns_in_order)-1];
    durns_corrected = [];
    
    for ind = 2:length(double_presses)
        
    durns_corrected = [durns_corrected;...
        perceptdurns_in_order(double_presses(ind-1)+2:double_presses(ind)-1,:); ...
        perceptdurns_in_order(double_presses(ind),1) ...
        + perceptdurns_in_order(double_presses(ind)+1,1) ...
        perceptdurns_in_order(double_presses(ind),2)]; ...
        
        %         
%         perceptdurns_in_order(double_presses(ind)+2:double_presses(ind+1),:)];
    end
    if bCat
        durns_corrected(15:20,:)=[];
    end
    
if any(diff(durns_corrected(:,2))==0), 
    find(diff(durns_corrected(:,2))==0)
    error('Non-alternating percept found');
end

% I should cut out the mysterious "first duration" from my durations
% array
% ****IF I WANT TO INCLUDE FIRST DURATION****
%           use durns_corrected

betweenTrials=find(durns_corrected(:,2)==0);
p2_inds =  find(durns_corrected(:,2)==2);

%p1_inds = find(durns_corrected(:,2)==1);

durs = [];
if ~isempty(betweenTrials)

    
    for ind = 1:length(betweenTrials)-1 % make sure this works if p1 is not first
        % or previous trial didn't end on a 2
        
        last_p2_of_trial = max(p2_inds((p2_inds<betweenTrials(ind+1))));
        
        durs = [durs; durns_corrected((betweenTrials(ind)+3):last_p2_of_trial,:)];
        length(durs)
    end


durs=[durs; durns_corrected(betweenTrials(end)+3:end,:)];
else
    durs = durns_corrected;
end
length(durs)


