clear all
trigger_code_context=[1:15];
trigger_code_test=[101:115];
trigger_code_endtime=[129600 134400 225600 129600 134400 225600 129600 134400 225600 129600 134400 225600 129600 134400 225600];
%cond1=silent context, 0 ISI
%cond2=silent context, 480 ISI
%cond3=silent context, 9600 ISI
%cond4=quiet context, 1 ABA-context, 0 ISI
%cond5=quiet context, 1 ABA-context, 480 ISI
%cond6=quiet context, 1 ABA-context, 9600 ISI
%cond7=quiet context, 14 ABA-context, 0 ISI
%cond8=quiet context, 14 ABA-context, 480 ISI
%cond9=quiet context, 14 ABA-context, 9600 ISI
%cond10=loud context, 1 ABA-context, 0 ISI
%cond11=loud context, 1 ABA-context, 480 ISI
%cond12=loud context, 1 ABA-context, 9600 ISI
%cond13=loud context, 14 ABA-context, 0 ISI
%cond14=loud context, 14 ABA-context, 480 ISI
%cond15=loud context, 14 ABA-context, 9600 ISI
t=0:4800:225600;
t1=0:4800:129600;
t2=0:4800:134400;
t3=0:4800:225600;
subjs=['001';'002';'003';'004';'005';'006';'007';'008';'009';'010'];

for nsubj=1:size(subjs,1),
    file=sprintf('%s-Streaming_Experiment_1_noheader.txt',subjs(nsubj,:));
    data=load(file);
    [n_rows n_cols]=size(data);
    n_trials=0;
    for n=1:n_rows, %go through all rows one by one
        if data(n,5)<10,    %if current time point within trial is close to '0'
            n_trials=n_trials+1; %this is beginning of new trial
            if n_trials>=7, %if trial is not a practice trial (1-6)
                trial_start(n_trials-6)=n; %encode beginning of trial as current row number
                trial_type(n_trials-6)=data(n,3); %encode trial type for current trial based on trigger
            end ,
        end
        curr_code_ind=find(trigger_code_test==data(n,3)); %determine if current row's trigger is a particular trial type during test
        if data(n,5)==trigger_code_endtime(curr_code_ind), %if current time point is at end of trial
            if n_trials>=7, trial_end(n_trials-6)=n; end %if trial is not a practice trial (1-6), encode end of trial as current row number
        end
    end
    time_series=zeros(8,length(t),15);
    n_trial_cond=zeros(15,1);
    for n_trial=1:n_trials-6, %go through all 120 trials
        n_trial_cond(trial_type(n_trial))=n_trial_cond(trial_type(n_trial))+1; %increment trial type number
        percept=0; %assume starting percept is "1 stream"
        for n=trial_start(n_trial):trial_end(n_trial), %go through all rows of raw data for each trial
            if data(n,3)==251, %if current row has a change to perceiving 1 stream,
                ind_percept=find(abs(data(n,5)-t)==min(abs(data(n,5)-t))); %find index of time series for when percept change occurs
                ind_percept_off=ind_percept;
                off=0;n2=n;
                while off==0 && n2<size(data,1), %find when current percept is over
                    n2=n2+1; if data(n2,3)==253, ind_percept_off=find(abs(data(n2,5)-t)==min(abs(data(n2,5)-t))); off=1; end
                end
                percept=0; %current percept is "1 stream"
                time_series(n_trial_cond(trial_type(n_trial)),ind_percept:ind_percept_off,trial_type(n_trial))=percept; %encode perception in time series from point of perception change to end of trial
            end
            if data(n,3)==252, %if current row has a change to perceiving 2 streams,
                ind_percept=find(abs(data(n,5)-t)==min(abs(data(n,5)-t))); %find index of time series for when percept change occurs;
                ind_percept_off=ind_percept;
                off=0;n2=n;
                while off==0 && n2<size(data,1),  %find when current percept is over
                    n2=n2+1; if data(n2,3)==254, ind_percept_off=find(abs(data(n2,5)-t)==min(abs(data(n2,5)-t))); off=1; end
                end
                percept=1; %current percept is "2 streams"
                time_series(n_trial_cond(trial_type(n_trial)),ind_percept:ind_percept_off,trial_type(n_trial))=percept; %encode perception in time series from point of perception change to end of trial
            end
        end %after trial is over, set all numbers to 0 for ISIs of 0 and 480 ms
        if any(trial_type(n_trial)==[1 4 7 10 13]), time_series(n_trial_cond(trial_type(n_trial)),29:length(t),trial_type(n_trial))=0; end
        if any(trial_type(n_trial)==[2 5 8 11 14]), time_series(n_trial_cond(trial_type(n_trial)),30:length(t),trial_type(n_trial))=0; end
    end
    for n_trialtype=1:15, %average across all 8 trials for each trial type
        mean_time_series(nsubj,:,n_trialtype)=mean(time_series(:,:,n_trialtype)); %for plotting grand average
        %mean_time_series(1,:,n_trialtype)=mean(time_series(:,:,n_trialtype)); %for plotting single subjects
    end
end
for n_trialtype=1:15,  %average across all 10 subjects for each trial type
    meanmean_time_series(n_trialtype,:)=mean(mean_time_series(:,:,n_trialtype));  %for plotting grand average
    %meanmean_time_series(n_trialtype,:)=(mean_time_series(:,:,n_trialtype)); %for plotting single subjects
end
figure
subplot(3,1,1),plot(t1/10/1000,meanmean_time_series([1 4 7 10 13],1:length(t1))),line(6.72,0:.01:1),axis([0 22.5600 0 1]),legend('silent  context, 0 ISI','quiet 12-st context, 1 ABA-12-st context, 0 ISI','quiet 12-st context, 14 ABA-12-st context, 0 ISI','loud 12-st context, 1 ABA-12-st context, 0 ISI','loud 12-st context, 14 ABA-12-st context, 0 ISI')
subplot(3,1,2),plot(t2/10/1000,meanmean_time_series([2 5 8 11 14],1:length(t2))),line(6.72,0:.01:1),line(7.2,0:.01:1),axis([0 22.5600 0 1]),legend('silent  context, 480 ISI','quiet 12-st context, 1 ABA-12-st context, 480 ISI','quiet 12-st context, 14 ABA-12-st context, 480 ISI','loud 12-st context, 1 ABA-12-st context, 480 ISI','loud 12-st context, 14 ABA-12-st context, 480 ISI')
subplot(3,1,3),plot(t3/10/1000,meanmean_time_series([3 6 9 12 15],1:length(t3))),line(6.72,0:.01:1),line(16.32,0:.01:1),axis([0 22.5600 0 1]),legend('silent  context, 9600 ISI','quiet 12-st context, 1 ABA-12-st context, 9600 ISI','quiet 12-st context, 14 ABA-12-st context, 9600 ISI','loud 12-st context, 1 ABA-12-st context, 9600 ISI','loud 12-st context, 14 ABA-12-st context, 9600 ISI')
