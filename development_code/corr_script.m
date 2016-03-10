% corr script
clear;
load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat')

pBootIS(NumCond) = 0; pBootSI(NumCond) = 0;

bNormalized = 1;

%cInd = 4;
pValIS(NumCond,NumSubj) = 0;
pValSI(NumCond,NumSubj) = 0;

nPerm = 10000;

for cInd = 1:NumCond
    % construct a null distribution for average correlation coefficient
    mnIScorrNull(NumSubj,nPerm) = 0;
    mnSIcorrNull(NumSubj,nPerm) = 0;
    
    IScorr(NumSubj,NumReps) = 0;
    SIcorr(NumSubj,NumReps) = 0;
    
    for pInd = 1:nPerm
        
        for sInd = 1:NumSubj
            
            for rInd = 1:NumReps
                
                Durs = DurationsCell{cInd,sInd,rInd};
                
                if length(Durs)<4
                    IScorr(sInd,rInd) = NaN;
                    SIcorr(sInd,rInd) = NaN;
                    continue
                end
                
                if bNormalized
                    Durs = normalizeDurs(Durs);
                end
                
                [Ipre, Spre, Ipost, Spost] = split_Durs(Durs);
                
                Ipre = Ipre(randperm(length(Ipre)));
                Ipost = Ipost(randperm(length(Ipost)));
                
                r1 = corr(Ipre,Spost);
                r2 = corr(Spre,Ipost);
                
                IScorr(sInd,rInd) = r1;
                SIcorr(sInd,rInd) = r2;
            end
        end
        
        mnIScorrNull(:,pInd,cInd) = mean(IScorr,2,'omitnan');
        mnSIcorrNull(:,pInd,cInd) = mean(SIcorr,2,'omitnan');
        
    end
    
    
    for sInd = 1:NumSubj
        
        for rInd = 1:NumReps
            
            Durs = DurationsCell{cInd,sInd,rInd};
            
            if length(Durs)<4
                IScorr(sInd,rInd) = NaN;
                SIcorr(sInd,rInd) = NaN;
                continue
            end
            
            if bNormalized
                Durs = normalizeDurs(Durs);
            end
            [Ipre Spre Ipost Spost] = split_Durs(Durs);
            
            r1 = corr(Ipre,Spost);
            r2 = corr(Spre,Ipost);
            
            IScorr(sInd,rInd) = r1;
            SIcorr(sInd,rInd) = r2;
              
        end
        
    end
    
    meanIScorrTrials = mean(IScorr,2,'omitnan');
    meanSIcorrTrials = mean(SIcorr,2,'omitnan');
    
    for ind = 1:NumSubj
        pValIS(cInd,ind) = sum(mnIScorrNull(ind,:,cInd)>...
            meanIScorrTrials(ind))/nPerm;
        pValSI(cInd,ind) = sum(mnSIcorrNull(ind,:,cInd)>...
            meanSIcorrTrials(ind))/nPerm;
    end
    
    meanIScorrSubjects = mean(meanIScorrTrials,'omitnan');
    meanSIcorrSubjects = mean(meanSIcorrTrials,'omitnan');
    
    pBootIS(cInd) = sum(mean(mnIScorrNull(:,:,cInd),'omitnan')>...
        meanIScorrSubjects)/nPerm;
    pBootSI(cInd) = sum(mean(mnIScorrNull(:,:,cInd),'omitnan')>...
        meanSIcorrSubjects)/nPerm;
    
end
figure; plot(1:NumCond,pBootIS,'Color',[250 188 81]/256);


