% trying to pack repeated operations into global variables
% with basic format {trialnum,df,subjID}
% BUF stored as (trialnum,:,df,subjID)

function analyzeData(durs,df,trialnum,subjID,wind)

global DURS DURS1 DURS2 G1 G2 BUF NWINDOWS
if ~exist('wind','var')
    wind = 10;
end
 % i wanna make sure I don't include any interrupted durs

DURS{trialnum,df,subjID} = durs;

    DURS1{trialnum,df,subjID} = durs(durs(:,2)==1,1);
    DURS2{trialnum,df,subjID} = durs(durs(:,2)==2,1);

    G1{trialnum,df,subjID} = find_gamma_pars(DURS1{trialnum,df,subjID});     %also wanna keep track of gamma
    G2{trialnum,df,subjID} = find_gamma_pars(DURS2{trialnum,df,subjID});     % pars and whether they change

    [BUF(trialnum,:,df,subjID) tax NWINDOWS(trialnum,df,subjID)]...
        = make_switchTriggeredBUF(durs,.01,wind);
end