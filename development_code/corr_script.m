% corr script
clear;

load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/Corrected_8DF_15SJ_3REP')
%load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat')
%load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF1_NSJ8_NREPS5.mat');

pBootIS(NumCond) = 0; pBootSI(NumCond) = 0;
r_IS(NumCond) = 0; r_SI(NumCond) = 0;

bNormalized = 0;%1;

%cInd = 4;
pValIS(NumCond,NumSubj) = 0; % each subject gets their own p value too
pValSI(NumCond,NumSubj) = 0;

nPerm = 10;

mnIScorrNull(NumSubj,nPerm,NumCond) = 0; % for mean corr over trials, permuted
mnSIcorrNull(NumSubj,nPerm,NumCond) = 0;

IScorr(NumReps,NumSubj,NumCond) = 0;
SIcorr(NumReps,NumSubj,NumCond) = 0;

NumDursIS(NumReps,NumSubj,NumCond) = 0;
NumDursSI(NumReps,NumSubj,NumCond) = 0;
muInt(NumReps,NumSubj,NumCond) = 0;
muSeg(NumReps,NumSubj,NumCond) = 0;

firstDurRatio(NumReps,NumSubj,NumCond) = 0;

lastDurRatio(NumReps,NumSubj,NumCond) = 0; 

% construct a null distribution for average correlation coefficient
for cInd = 1:NumCond
    
    for pInd = 1:nPerm
        
        for sInd = 1:NumSubj
            
            for rInd = 1:NumReps
                
                Durs = DurationsCell{cInd,sInd,rInd};
                
                if length(Durs)<4
                    IScorr(rInd,sInd) = NaN;
                    SIcorr(rInd,sInd) = NaN;
                    continue
                end
                
                if bNormalized
                    [Durs] = normalizeDurs(Durs);
                end
                
                [Ipre, Spre, Ipost, Spost] = split_Durs(Durs);
                
                Ipre = Ipre(randperm(length(Ipre)));
                Ipost = Ipost(randperm(length(Ipost)));
                
                r1 = corr(Ipre,Spost);
                r2 = corr(Spre,Ipost);
                
                IScorrN(rInd,sInd) = r1;
                SIcorrN(rInd,sInd) = r2;
            end
        end
        
        % we just permuted all the trials, and are looking for the mean
        % correlation coefficient across trials
        mnIScorrNull(:,pInd,cInd) = mean(IScorrN',2,'omitnan');
        mnSIcorrNull(:,pInd,cInd) = mean(SIcorrN',2,'omitnan');
        
    end
    % Null distribution constructed! Moving on!
    
    for sInd = 1:NumSubj
        
        for rInd = 1:NumReps
            
            Durs = DurationsCell{cInd,sInd,rInd};
            
            sum(Durs(:,1)<0.3)
            disp([rInd sInd cInd])
            [Ipre, Spre, Ipost, Spost] = split_Durs(Durs);
            
            
            muInt(rInd,sInd,cInd) = mean(Ipre);
            muSeg(rInd,sInd,cInd) = mean(Spre);
            
            firstDurRatio(rInd,sInd,cInd) = Durs(1,1)/muInt(rInd,sInd,cInd);
            
            if Durs(end,2) == 1
                lastDurRatio(rInd,sInd,cInd) = Durs(end,1)/muInt(rInd,sInd,cInd);
            else
                lastDurRatio(rInd,sInd,cInd) = Durs(end,1)/muSeg(rInd,sInd,cInd);
            end
            if length(Durs)<4
                IScorr(rInd,sInd) = NaN;
                SIcorr(rInd,sInd) = NaN;
                
                continue
            end
            
            if bNormalized
                Durs = normalizeDurs(Durs);
            end
            
            NumDursIS(rInd,sInd,cInd) = length(Ipre);
            NumDursSI(rInd,sInd,cInd) = length(Spre);
            
            r1 = corr(Ipre,Spost);
            r2 = corr(Spre,Ipost);
            
            IScorr(rInd,sInd,cInd) = r1;
            SIcorr(rInd,sInd,cInd) = r2;
              
        end
        
    end
    
    meanIScorrTrials(:,cInd) = mean(IScorr(:,:,cInd)',2,'omitnan');
    meanSIcorrTrials(:,cInd) = mean(SIcorr(:,:,cInd)',2,'omitnan');
    
    for ind = 1:NumSubj
        pValIS(cInd,ind) = sum(mnIScorrNull(ind,:,cInd)>...
            meanIScorrTrials(ind,cInd))/nPerm;
        pValSI(cInd,ind) = sum(mnSIcorrNull(ind,:,cInd)>...
            meanSIcorrTrials(ind,cInd))/nPerm;
    end
    
    r_IS(cInd) = mean(meanIScorrTrials(:,cInd),'omitnan');
    r_SI(cInd) = mean(meanSIcorrTrials(:,cInd),'omitnan');
    
    pBootIS(cInd) = sum(mean(mnIScorrNull(:,:,cInd),'omitnan')>...
        r_IS(cInd))/nPerm;
    pBootSI(cInd) = sum(mean(mnIScorrNull(:,:,cInd),'omitnan')>...
        r_SI(cInd))/nPerm;
    
end

mnFirstDurRatio = mean(mean(mean(firstDurRatio),'omitnan'))
propFirstDurHigher = sum(sum(sum(firstDurRatio>1)))/numel(firstDurRatio)

mnLastDurRatio = mean(mean(mean(lastDurRatio),'omitnan'))
propLastDurLower = sum(sum(sum(lastDurRatio<1)))/numel(lastDurRatio)
%%
xloc = 1:NumCond;
[intColor, segColor] = set_int_seg_colors;
figure; plot(xloc,r_IS,'Color',intColor);
mk_Nice_Plot;
xlabel('DF condition'); ylabel('r'); 
bSigIS = pBootIS<.05; 
hold on; plot(xloc(bSigIS),0.3*ones(1,sum(bSigIS)),'*',...
    'Color',intColor);

plot(xloc,r_SI,'Color',segColor); mk_Nice_Plot;
bSigSI = pBootSI<.05; 
hold on; plot(xloc(bSigSI)+.1,0.32*ones(1,sum(bSigSI)),'*',...
    'Color',segColor);
text(.5,.35,'I->S','Color',intColor,'FontSize',15); 
text(.5,.37,'S->I','Color',segColor,'FontSize',15);
set(gca,'XTick',xloc,'XTickLabels',DFvals);
axis([-.1 NumCond+.5 0 .5])

figure; plot(reshape(muInt,1,numel(muInt)),reshape(IScorr,1,numel(IScorr)),'.')
xlabel('mean duration'); ylabel('correlation coefficient');
axis([0 40 -1 1])