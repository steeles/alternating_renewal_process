% corr script
clear;

% corrected 3 Rep over original
load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/Corrected_All_DFsExtraTrials.mat')
%load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat')

% corrected 5 Rep over original
% load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/Corrected_8SJ_5REP.mat')
%load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF1_NSJ8_NREPS5.mat');

pBootIS(NumCond) = 0; pBootSI(NumCond) = 0;
r_IS_AllSubj(NumCond) = 0; r_SI_AllSubj(NumCond) = 0;

bNormalized = 0;%1;

%cInd = 4;
pValIS(NumCond,NumSubj) = 0; % each subject gets their own p value too
pValSI(NumCond,NumSubj) = 0;

nPerm = 1;

mnIScorrNull(NumSubj,nPerm,NumCond) = 0; % for mean corr over trials, permuted
mnSIcorrNull(NumSubj,nPerm,NumCond) = 0;

meanIScorrTrials(NumSubj,NumCond) = 0;
meanSIcorrTrials(NumSubj,NumCond) = 0;

IScorr(NumReps,NumSubj,NumCond) = 0;
SIcorr(NumReps,NumSubj,NumCond) = 0;
pIScorrEachTrial(NumReps,NumSubj,NumCond) = 0;
pSIcorrEachTrial(NumReps,NumSubj,NumCond) = 0;

NumDursIS(NumReps,NumSubj,NumCond) = 0;
NumDursSI(NumReps,NumSubj,NumCond) = 0;
muInt(NumReps,NumSubj,NumCond) = 0;
muSeg(NumReps,NumSubj,NumCond) = 0;

zIS(NumReps,NumSubj,NumCond) = 0;
zSI(NumReps,NumSubj,NumCond) = 0;

firstDurRatio(NumReps,NumSubj,NumCond) = 0;
lastDurRatio(NumReps,NumSubj,NumCond) = 0; 

remainingTwitches(NumReps,NumSubj,NumCond) = 0;

% SegStarts = [cInd sInd rInd Durs(2,1) muSeg(rInd,sInd,cInd)];
SegStarts = [];

IpreTot{NumCond,NumSubj,NumReps} = [];
SpostTot{NumCond,NumSubj,NumReps} = [];
SpreTot{NumCond,NumSubj,NumReps} = [];
SpostTot{NumCond,NumSubj,NumReps} = [];

% get the p2p base stats from the data as well as optimal taus

nTaus = 20;
tau_ax = logspace(-.5,1.75,nTaus);

f = @(tau)compute_cumhist_corr(Durs,tau);
g = @(tau)-f(tau);

for cInd = 1:NumCond
    
    for sInd = 1:NumSubj
        
        for rInd = 1:NumReps
            
            Durs = DurationsCell{cInd,sInd,rInd};
            
            if length(Durs)<4
                continue
            end
            
            if any(Durs(:,1)<0)
                error('negative dur detected')
            elseif Durs(1,1) ~=0
                error('non-post-processed data got through')
            end
            
            if bNormalized
                Durs = normalizeDurs(Durs);
            end
            
            if sum(Durs(3:end,1)<0.3)
                remainingTwitches(rInd,sInd,cInd) = sum(Durs(:,1)<0.3)
                keyboard
            end
            %disp([rInd sInd cInd])
            [Ipre, Spre, Ipost, Spost] = split_Durs(Durs);
            
            muInt(rInd,sInd,cInd) = mean(Ipost);
            muSeg(rInd,sInd,cInd) = mean(Spost);
            
            if length(Spre)<2
                IScorr(rInd,sInd,cInd) = NaN;
                SIcorr(rInd,sInd,cInd) = NaN;
                pIScorrEachTrial(rInd,sInd,cInd) = NaN;
                pSIcorrEachTrial(rInd,sInd,cInd) = NaN;
                firstDurRatio(rInd,sInd,cInd) = 1;
                lastDurRatio(rInd,sInd,cInd) = 1;
                NumDursIS(rInd,sInd,cInd) = 0;
                NumDursSI(rInd,sInd,cInd) = 0;
                continue
            end
            
            % cut off the first, longer duration
            if Durs(2,2) == 1 % first percept is probably grouped, and longer
                firstDurRatio(rInd,sInd,cInd) = Ipre(1)/muInt(rInd,sInd,cInd);
                Ipre = Ipre(2:end); Spost = Spost(2:end);
                
                
                
            else
                SegStarts = [SegStarts; cInd sInd rInd Durs(2,1) muSeg(rInd,sInd,cInd)];
                firstDurRatio(rInd,sInd,cInd) = 1;
            end
            
            IpreTot{cInd,sInd,rInd}=Ipre; SpostTot{cInd,sInd,rInd}=Spost;
            SpreTot{cInd,sInd,rInd}=Spre; IpostTot{cInd,sInd,rInd}=Ipost;
            
            if Durs(end,2) == 1
                lastDurRatio(rInd,sInd,cInd) = Ipost(end)/muInt(rInd,sInd,cInd);
            else
                lastDurRatio(rInd,sInd,cInd) = Spost(end)/muSeg(rInd,sInd,cInd);
            end
            
            NumDursIS(rInd,sInd,cInd) = length(Ipre);
            NumDursSI(rInd,sInd,cInd) = length(Spre);
            
            [r1 p1] = corr(Ipre,Spost);
            [r2 p2] = corr(Spre,Ipost);
            
            IScorr(rInd,sInd,cInd) = r1;
            SIcorr(rInd,sInd,cInd) = r2;
            
            [ZrCombined, r11, r22, z1, z2] = ...
    compute_pWeightedR_cumhist(Spost, Ipost, Ipre, Spre);

            zIS(rInd,sInd,cInd) = z1; zSI(rInd,sInd,cInd) = z2;
            
            pIScorrEachTrial(rInd,sInd,cInd) = p1;
            pSIcorrEachTrial(rInd,sInd,cInd) = p2;
              
        end
        
    end
    
    meanIScorrTrials(:,cInd) = fisher_combine_corrs(IScorr(:,:,cInd),...
        NumDursIS(:,:,cInd));
    
    meanSIcorrTrials(:,cInd) = fisher_combine_corrs(SIcorr(:,:,cInd),...
        NumDursSI(:,:,cInd));
    
end

%% trial z by prop split

%[intCol segCol] = set_int_seg_colors;
prop_split = muSeg./(muInt + muSeg); pSplitVec = reshape(prop_split,1,numel(prop_split));
zISvec = reshape(zIS,1,numel(zIS)); zSIvec = reshape(zSI, 1, numel(zSI));

figure; plot(pSplitVec,zISvec,'b.'); mk_Nice_Plot;
hold on; plot(pSplitVec,zSIvec,'m.');
xlabel('Proportion segregated (trials)'); ylabel('Trial Correlation Z score')
legend('I->S','S->I'); title('r vs proportion seg, each trial')
%% Subj/Condn z by prop split

% preallocate
SC_muInt(NumSubj,NumCond) = 0;
SC_muSeg(NumSubj,NumCond) = 0;
SC_zIS(NumSubj,NumCond) = 0;
SC_zSI(NumSubj,NumCond) = 0;

ZrCombined(NumSubj,NumCond) = 0;

%
for cInd = 1:NumCond
    for sInd = 1:NumSubj
        
        Ipre = vertcat(IpreTot{cInd,sInd,:});
        Spost = vertcat(SpostTot{cInd,sInd,:});
        Spre = vertcat(SpreTot{cInd,sInd,:});
        Ipost = vertcat(IpostTot{cInd,sInd,:});
        
        SC_muInt(sInd,cInd) = mean(Ipost); 
        SC_muSeg(sInd,cInd) = mean(Spost);
        
        [ZrCombined(sInd,cInd), r11, r22, z1, z2] = ...
    compute_pWeightedR_cumhist(Spost, Ipost, Ipre, Spre);

        SC_zIS(sInd,cInd) = z1; SC_zSI(sInd,cInd) = z2;
        
    end
end
prop_splitSC = SC_muSeg./(SC_muInt + SC_muSeg); 
pSplitVecSC = reshape(prop_splitSC,1,numel(prop_splitSC));
zISvecSC = reshape(SC_zIS,1,numel(SC_zIS)); ...
    zSIvecSC = reshape(SC_zSI, 1, numel(SC_zSI));

figure; plot(pSplitVecSC,zISvecSC,'b.','MarkerSize',9); mk_Nice_Plot;
hold on; plot(pSplitVecSC,zSIvecSC,'m.','MarkerSize',9);
xlabel('Proportion segregated (Subj/Condn)'); ylabel('Correlation Z score')
legend('I->S','S->I'); title('r vs proportion seg, each subj/condn')


%%
for cInd = 1:NumCond
    for pInd = 1:nPerm
        
        for sInd = 1:NumSubj
            
            for rInd = 1:NumReps
                
                Durs = DurationsCell{cInd,sInd,rInd};
                %Durs = Durs(2:end,:);
                
                [Ipre, Spre, Ipost, Spost] = split_Durs(Durs);
                Ipre = Ipre(2:end); Spost = Spost(2:end);
                
                if length(Spre)<2
%                   IScorr(rInd,sInd) = NaN;
%                   SIcorr(rInd,sInd) = NaN;
                    continue
                end
                
                if bNormalized
                    [Durs] = normalizeDurs(Durs);
                end
                
                
                Ipre = Ipre(randperm(length(Ipre)));
                Ipost = Ipost(randperm(length(Ipost)));
                
                try
                    r1 = corr(Ipre,Spost);
                catch me
                    r1 = NaN;
                end
                r2 = corr(Spre,Ipost);
                
                IScorrN(rInd,sInd) = r1;
                SIcorrN(rInd,sInd) = r2;
            end
        end
        
        % we just permuted all the trials, and are looking for the mean
        % correlation coefficient across trials
        
        mnIScorrNull(:,pInd,cInd) = fisher_combine_corrs(IScorrN,...
            NumDursIS(:,:,cInd));
        mnSIcorrNull(:,pInd,cInd) = fisher_combine_corrs(SIcorrN,...
            NumDursSI(:,:,cInd));
        
    end
    % Null distribution constructed! Moving on!
    
    %for cInd = 1:NumCond
    for ind = 1:NumSubj
        pIS = sum(abs(mnIScorrNull(ind,:,cInd))>...
            abs(meanIScorrTrials(ind,cInd)))/nPerm;
        
        if isnan(meanIScorrTrials(ind,cInd)), pIS = NaN;
        elseif  pIS == 0, pIS = 1/nPerm; end
        pValIS(cInd,ind) = pIS;
        %keyboard;
        pSI = sum(abs(mnSIcorrNull(ind,:,cInd))>...
            abs(meanSIcorrTrials(ind,cInd)))/nPerm;
        if isnan(meanSIcorrTrials(ind,cInd)), pSI = NaN;
        elseif pSI == 0, pSI = 1/nPerm;  end
        pValSI(cInd,ind) = pSI;
    end
    %end
    
    % now we want to see how the corr's for all subjects look
    NumISSubj = sum(NumDursIS(:,:,cInd),1);
    NumSISubj = sum(NumDursSI(:,:,cInd),1);
    
    %keyboard;
    
    r_IS_AllSubj(cInd) = fisher_combine_corrs(meanIScorrTrials(:,cInd),NumISSubj');
    r_SI_AllSubj(cInd) = fisher_combine_corrs(meanSIcorrTrials(:,cInd),NumSISubj');
    
    pBootIS(cInd) = sum(mean(mnIScorrNull(:,:,cInd),'omitnan')>...
        r_IS_AllSubj(cInd))/nPerm;
    pBootSI(cInd) = sum(mean(mnIScorrNull(:,:,cInd),'omitnan')>...
        r_SI_AllSubj(cInd))/nPerm;
    
end

NumIS_perSubjectCond = squeeze(sum(NumDursIS(:,:,:)))';
r_IS_perSubject = fisher_combine_corrs(meanIScorrTrials',...
    NumIS_perSubjectCond); % find grand corrs for each subject

NumSI_perSubjectCond = squeeze(sum(NumDursSI(:,:,:)))';
r_SI_perSubject = fisher_combine_corrs(meanSIcorrTrials',...
    NumSI_perSubjectCond);

% shows by condition what the average ratio for first dur is
mnFirstDurRatio = squeeze(mean(mean(firstDurRatio,'omitnan'),2));
propFirstDurHigher = sum(sum(firstDurRatio>1),2)/numel(firstDurRatio);

mnLastDurRatio = squeeze(mean(mean(lastDurRatio,'omitnan'),2));
propLastDurLower = sum(sum(sum(lastDurRatio<1)))/numel(lastDurRatio);
%%
xloc = 1:NumCond;
[intColor, segColor] = set_int_seg_colors;

figure; plot(xloc,r_IS_AllSubj,'Color',intColor);
mk_Nice_Plot;
xlabel('DF condition'); ylabel('r'); 

pLevel = .05;
bSigIS = pBootIS<pLevel;

hold on; plot(xloc(bSigIS),0.3*ones(1,sum(bSigIS)),'*',...
    'Color',intColor);

plot(xloc,r_SI_AllSubj,'Color',segColor); mk_Nice_Plot;
bSigSI = pBootSI<.05; 
hold on; plot(xloc(bSigSI)+.1,0.32*ones(1,sum(bSigSI)),'*',...
    'Color',segColor);
text(.5,.35,'I->S','Color',intColor,'FontSize',18); 
text(.5,.38,'S->I','Color',segColor,'FontSize',18);
set(gca,'XTick',xloc,'XTickLabels',DFvals);
axis([-.1 NumCond+.5 0 .5])
title('Correlations over all conditions')
%%
figure; set(gcf,'Position',[1 1 540 720])
subplot(211); 
IScorrVec = reshape(IScorr,1,numel(IScorr));
mu1Vec = reshape(muInt,1,numel(muInt));

NaNLoc = any(isnan([mu1Vec;IScorrVec]));
mu1Vec = mu1Vec(~NaNLoc); IScorrVec = IScorrVec(~NaNLoc);
plot(mu1Vec,IScorrVec,'.')
mk_Nice_Plot;

[r_corrVsMn1 pMn1] = corr(IScorrVec',mu1Vec');%,'rows','pairwise');

hold on; 

p = polyfit(mu1Vec,IScorrVec,1);
Y = polyval(p,mu1Vec);
plot(mu1Vec,Y,'b--')

% 
trialSigIS = pIScorrEachTrial<pLevel;
sigIScorrTrials = reshape(trialSigIS,1,numel(trialSigIS));
sigIScorrTrials = sigIScorrTrials(~NaNLoc);
plot(mu1Vec(sigIScorrTrials),IScorrVec(sigIScorrTrials),'r.');
xlabel('mean duration'); ylabel('r');
title(sprintf('Correlations vs Mean %d DFs %d Subjs %d Reps',...
    NumCond,NumSubj,NumReps))
axis([0 40 -1 1]);
foo = xlim;
text(foo(2) * .3,.5,sprintf('r=%.2f, p=%.4f',r_corrVsMn1,pMn1),...
    'FontSize',18,'Color','b')
text(0.5,.9,'Significant Trials','FontSize',18,'Color','r')

subplot(2,1,2);
SIcorrVec = reshape(SIcorr,1,numel(SIcorr));
mu2Vec = reshape(muSeg,1,numel(muSeg));
NaNLoc = any(isnan([mu2Vec;SIcorrVec]));
mu2Vec = mu2Vec(~NaNLoc); SIcorrVec = SIcorrVec(~NaNLoc);

plot(mu2Vec,SIcorrVec,'.')
mk_Nice_Plot;

[r_corrVsMn2 pMn2] = corr(SIcorrVec',mu2Vec');
hold on; 

p = polyfit(mu2Vec,SIcorrVec,1);
Y = polyval(p,mu2Vec);
plot(mu2Vec,Y,'b--')
% 


trialSigSI = pSIcorrEachTrial<pLevel;
sigSIcorrTrials = reshape(trialSigSI,1,numel(trialSigSI));
sigSIcorrTrials = sigSIcorrTrials(~NaNLoc);
hold on; plot(mu2Vec(sigSIcorrTrials),SIcorrVec(sigSIcorrTrials),'r.');

ylabel('r');
axis([0 40 -1 1])
foo = xlim;
text(foo(2) * .3,.5,sprintf('r=%.2f, p=%.4f',r_corrVsMn2,pMn2),...
    'FontSize',18,'Color','b')
%%
clf;
pSigIS = pValIS<.05;
h = bar3(meanIScorrTrials);
cm = get(gcf,'colormap');  % Use the current colormap.
cnt = 0;
for jj = 1:length(h)
    xd = get(h(jj),'xdata');
    yd = get(h(jj),'ydata');
    zd = get(h(jj),'zdata');
    delete(h(jj))    
    idx = [0;find(all(isnan(xd),2))];
    if jj == 1
        S = zeros(length(h)*(length(idx)-1),1);
        dv = floor(size(cm,1)/length(S));
    end
    for ii = 1:length(idx)-1
        cnt = cnt + 1;
        S(cnt) = surface(xd(idx(ii)+1:idx(ii+1)-1,:),...
                         yd(idx(ii)+1:idx(ii+1)-1,:),...
                         zd(idx(ii)+1:idx(ii+1)-1,:),...
                         'facecolor',cm((cnt-1)*dv+1,:));
    end
end
pSigISVec = reshape(pSigIS',1,numel(pSigIS));
set(S(pSigISVec),'facecolor','red')
%mk_Nice_Plot
set(gca,'XTickLabel',DFvals);%,'FontSize',16)
xlabel('DF Condition','FontSize',18)
ylabel('Subject','FontSize',18)
zlabel('r value (red=p<.05)','FontSize',18)
title('I-->S','FontSize',24)
%%
%figure;

pSigSI = pValSI<.05;
h = bar3(meanSIcorrTrials);
cm = get(gcf,'colormap');  % Use the current colormap.
cnt = 0;
for jj = 1:length(h)
    xd = get(h(jj),'xdata');
    yd = get(h(jj),'ydata');
    zd = get(h(jj),'zdata');
    delete(h(jj))    
    idx = [0;find(all(isnan(xd),2))];
    if jj == 1
        S = zeros(length(h)*(length(idx)-1),1);
        dv = floor(size(cm,1)/length(S));
    end
    for ii = 1:length(idx)-1
        cnt = cnt + 1;
        S(cnt) = surface(xd(idx(ii)+1:idx(ii+1)-1,:),...
                         yd(idx(ii)+1:idx(ii+1)-1,:),...
                         zd(idx(ii)+1:idx(ii+1)-1,:),...
                         'facecolor',cm((cnt-1)*dv+1,:));
    end
end
pSigSIVec = reshape(pSigSI',1,numel(pSigSI));
set(S(pSigSIVec),'facecolor','red')
%mk_Nice_Plot
set(gca,'XTickLabel',DFvals);%,'FontSize',16)
xlabel('DF Condition','FontSize',18)
ylabel('Subject','FontSize',18)
zlabel('r value (red=p<.05)','FontSize',18)
title('S-->I','FontSize',24)
