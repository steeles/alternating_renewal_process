% outer code for subject 3 data


ind = 1;


% starts with subject 3 files for conds df = 4, 5, 6 
datafiles(ind) = struct('filename','03.08.06.2011.1.mat', ...       1
    'subj_folder','03', 'trial_num',1, 'condn_order',[0 5 6 4], ...
    'b_raw',1,'info','KeyHolds','date',20110806); ind = ind+1;

datafiles(ind) = struct('filename','03.08.06.2011.2.mat', ...       2
    'subj_folder','03', 'trial_num',2, 'condn_order',[6 4 5], ...
    'b_raw',1,'info','KeyHolds','date',20110806); ind = ind+1;

% now I was told to include data in
% 'JR_NotesforSara_SteadyTriplet_RawDataOnly.pdf to only include data with
% descriptor in last column of doc, "Condns DF..." because those would
% contain keyholds; but I found one of these files must have had presses,
% not holds, as running KPushETs_ss on this file yields average durations
% as ~.1 sec, as does the "data" field of the struct.
%
% datafiles(ind) = struct('filename','03.29.11.2011_3DF_1trl'... -ignored-

datafiles(ind) = struct('filename','03.19.05.2011.1.mat', ...       3
    'subj_folder','03', 'trial_num',3, 'condn_order',[5 4 6], ...
    'b_raw',0,'info','ButtonHolds','date',20110519); ind = ind+1;

% ok now let's try adding subject 6 files

datafiles(ind) = struct('filename','06.25.05.2011.1.mat', ...       4
    'subj_folder','06', 'trial_num',1, 'condn_order',[6 4 5], ...
    'b_raw',0,'info','ButtonClicks','date',20110525); ind = ind+1;
datafiles(ind) = struct('filename','06.25.05.2011.2.mat', ...       5
    'subj_folder','06', 'trial_num',2, 'condn_order',[4 5 6], ...
    'b_raw',1,'info','KeyHolds','date',20110525); ind = ind+1;
datafiles(ind) = struct('filename','06.08.06.2011.1.mat', ...       6
    'subj_folder','06', 'trial_num',3, 'condn_order',[6 4 5], ...
    'b_raw',1,'info','KeyHolds','date',20110608); ind = ind+1;
datafiles(ind) = struct('filename','06.08.06.2011.2.mat', ...       7
    'subj_folder','06', 'trial_num',4, 'condn_order',[4 6 5], ...
    'b_raw',1,'info','KeyHolds','date',20110608); ind = ind+1;


