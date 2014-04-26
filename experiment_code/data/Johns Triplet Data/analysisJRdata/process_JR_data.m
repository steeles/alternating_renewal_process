% lower level code to analyze data files with the metadata provided
% in datastruct, and return outcomes by each trial, condition and subject. SS 1/8/2012 
% note dependencies on v2struct, KPushETs_ss
% rename to process_JR_data

function outcomes = process_JR_data(datastruct,BUFwindow,bPlot,outcomes)

if ~exist('BUF_window','var')
    BUFwindow = 10;
end 
if ~exist('bPlot','var')
    bPlot = 0;
end

v2struct(datastruct); % now i have filename, subj_folder,
                      % trial_num, condn_order, b_raw, info, and date, and
                      % whichSubjs and whichDfs
                      
                      
                      
dir = ['~/Dropbox/my codes/rinzel/experiment_code/data/Johns Triplet Data/steady_triplet_' subj_folder];
cd(dir); % i'll be saving the data i get for each subject in their data folder labelled by DF and nTrials

load(filename)      % should give me result
sID = str2num(subj_folder);

valid_condns = find(condn_order>0);
result = result(valid_condns);

nCondns = length(result);


for ind = 1:nCondns
  df = condn_order(valid_condns(ind));
  
  dfInd = find(whichDfs == df);
  subjInd = find(whichSubjs == sID);
  
  n = ind;
  if b_raw
      KPushETs_ss;
  else
      durs = result(ind).data(2:end,:);
  end
  
  results = analyze_durs(durs,BUFwindow,1);
  results.df = df;
  results.subjID = sID;
  outcomes(dfInd,subjInd,trial_num) = results;
end
  
  
