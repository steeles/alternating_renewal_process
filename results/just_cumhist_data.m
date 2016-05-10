% I like to use 0 to initialize and NaN to show processed
load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/Corrected_All_DFsExtraTrials.mat')

tauMaxR(NumCond,NumSubj) = 0;
tauOpt(NumCond,NumSubj) = 0;
cumhist_pars(7,NumCond,NumSubj) = 0;
cumhistOptInfo = struct('iterations',[],...
    'funcCount',[],'stepsize', [], 'lssteplength', [],...
    'firstorderopt',[],'algorithm', [], 'message',[]);

for cInd = 1:NumCond
    
    for sInd = 1:NumSubj
        disp(sprintf('c %d s %d',cInd,sInd))
        DursCell = DurationsCell(cInd,sInd,:);
        DursCell = squeeze(squeeze(DursCell));
        DursCell = DursCell(~cellfun('isempty',DursCell));
        
        nDursTmp = cellfun('length',DursCell);
        if sum(nDursTmp<3) > 1 
            tauOpt(cInd,sInd) = NaN;
            tauMaxR(cInd,sInd) = NaN;
            continue
        else
            
            % consider trying random inits (third argument after bNull=0)
            [parmhat fval parsMaxR output exitflag] = estimate_cumhist_pars(DursCell);
            tauOpt(cInd,sInd) = parmhat(end);
            tauMaxR(cInd,sInd) = parsMaxR(end);
            cumhist_pars(:,cInd,sInd) = parmhat;
            cumhistOptInfo(cInd,sInd) = output;
        end
    end
end
        