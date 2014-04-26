%function [outcomes aggrOutcomes] = run_JR_analysis(filenums);

clear;


whichSubjs = [3 6];
whichDfs = [4 5 6];

% at some point I'll want to code some stuff to keep track of which
% subjects and which conditions are included/unique to the files i'm
% pulling from; might use struct2cell

if ~exist('filenums','var')
    filenums = [1 2 3 4 5 6 7];
end

JR_filename_database; % generate the filename database struct datafiles

bPlot = 1;
BUF_window = 10;

% initialize this damn struct
outcomes = struct('BUF',[], 'BUFarp',[], 'tax', [], 'rSquared', [],...
    'g1_pars', [], 'g2_pars', [], ...
    'nWindows', [], 'durs1', [], 'durs2', [], 'durs',[],'df',[],'subjID',[]);

for ind = 1:length(filenums)
    datastruct = datafiles(filenums(ind)); % pulls out all the info I need to analyze this in the next lower level
    
    datastruct.whichSubjs = whichSubjs; datastruct.whichDfs = whichDfs; % add some fields here about which things you're combining
    
    outcomes = process_JR_data(datastruct,BUF_window,bPlot,outcomes);   % this outer code will help me update outcomes struct across files and trials
end
% outcomes is nDFs x nSubjs x nTrials struct with fields durs, durs1,
% durs2, g1_pars, g2_pars, buf, nwindows, df, subjID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now let's get our plot on
bSave = 1;
for ind = 1:length(whichSubjs);

    whoisthis = whichSubjs(ind);    
    
    tmp = outcomes(:,ind,:); %tmp is 3x1xnTrials
        for ind2 = 1:length(whichDfs)
            tmp2 = tmp(ind2,:,:);   % pick out df by df            
            herewego(ind2,1) = combine_arp_datasets(tmp2);
        end
    subj_arp_results(:,ind) = herewego;
    if bSave
        dir = ['~/Dropbox/my codes/rinzel/experiment_code/data/Johns Triplet Data/steady_triplet_0' num2str(whoisthis)];
        if whoisthis==10
            dir = ['~/Dropbox/my codes/rinzel/experiment_code/data/Johns Triplet Data/steady_triplet_10'];
        end
        cd(dir); mkdir('results_SS'); cd results_SS
         
        % tag with whichDfs
        filename = ['subj_' num2str(whoisthis) 'arp_results_DF=' num2str(whichDfs) '.mat'];
        save(filename,'herewego');
    end
end

% master aggregate

for dfInd = 1:length(whichDfs)
   between_subjs(dfInd) = combine_arp_datasets(outcomes(dfInd));
   
end
%between_subjs(:).whichSubjs = whichSubjs;
cd ~/Dropbox/my' codes'/rinzel/experiment_code/data/Johns' Triplet Data'/
mkdir('across_subjs_results')
cd across_subjs_results/

filename=[num2str(whichDfs) 'subj' num2str(whichSubjs) '.mat'];

save(filename,'between_subjs')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot it out
s = outcomes(:,1,1:3);
plot_arp_data(s);
