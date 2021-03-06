% I like to use 0 to initialize and NaN to show processed
clear;
load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/Corrected_All_DFsExtraTrials.mat')

tauMaxR(NumCond,NumSubj) = 0;
tauOpt(NumCond,NumSubj) = 0;
cumhist_pars(7,NumCond,NumSubj) = 0;
cumhistOptInfo = struct('iterations',[],...
    'funcCount',[],'stepsize', [], 'lssteplength', [],...
    'firstorderopt',[],'algorithm', [], 'message',[]);
excludedFromAnalysis(NumCond,NumSubj) = 0;
MaxR(NumCond,NumSubj) = 0;
zCumhist(NumCond,NumSubj) = 0;
minimumNumDurs = 20;
for cInd = 1:NumCond
    
    for sInd = 1:NumSubj
        disp(sprintf('c %d s %d',cInd,sInd))
        DursCell = DurationsCell(cInd,sInd,:);
        DursCell = squeeze(squeeze(DursCell));
        DursCell = DursCell(~cellfun('isempty',DursCell));
        
        nDursTmp = cellfun('length',DursCell);
        if sum(nDursTmp<3) > 1 || sum(nDursTmp) < minimumNumDurs
            tauOpt(cInd,sInd) = NaN;
            tauMaxR(cInd,sInd) = NaN;
            zCumhist(cInd,sInd) = NaN;
            excludedFromAnalysis(cInd,sInd) = 1;
            continue
        else
            
            init = randn(7,1) * 5;
            init([1 2 7]) = abs(init([1 2 7]));
            % consider trying random inits (third argument after bNull=0)
            [parmhat fval parsMaxR output rMax] = ...
                estimate_cumhist_pars(DursCell,0,init);
            
            tauOpt(cInd,sInd) = parmhat(end);
            tauMaxR(cInd,sInd) = parsMaxR(end); MaxR(cInd,sInd) = rMax;
            cumhist_pars(:,cInd,sInd) = parmhat;
            cumhistOptInfo(cInd,sInd) = output;
            zCumhist(cInd,sInd) = compute_cumhist_corr(DursCell,parmhat(end));
        end
    end
end

% 
% pCumhist = exp(-zCumhist.^2/2); thresh = .05;
% sum(sum(pCumhist<thresh))/(NumCond*NumSubj-sum(sum(excludedFromAnalysis)))