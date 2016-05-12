%cumhist_p2p_compare

% i'm going to do everything by subject condition
% i'm going to use p values from the corr script
% i want to know how rIS compares with RSI
% i want to know how r11 compares with r22
% i want to know how r/zcombined cumhist compares with r/zcombined
% i also want to know which conditions are equidominant - dark seg, white
% int, saturated = equidominant
% for cumhist i'm interested in tau/mu
% mle fits
clear;
load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/Corrected_All_DFsExtraTrials.mat')

IpreTot{NumCond,NumSubj} = []; SpostTot{NumCond,NumSubj} = [];
SpreTot{NumCond,NumSubj} = []; IpostTot{NumCond,NumSubj} = [];


SegProp(NumCond,NumSubj) = 0; IntMeans(NumCond,NumSubj) = 0;
SegMeans(NumCond,NumSubj) = 0; cumhist_pars(7,NumCond,NumSubj) = 0;
cumhistOptInfo = struct('iterations',[],...
    'funcCount',[],'stepsize', [], 'lssteplength', [],...
    'firstorderopt',[],'algorithm', [], 'message',[]);

rIS(NumCond,NumSubj) = 0; pIS(NumCond,NumSubj) = 0;
rSI(NumCond,NumSubj) = 0; pSI(NumCond,NumSubj) = 0;
zIS(NumCond,NumSubj) = 0; zSI(NumCond,NumSubj) = 0;

percept_to_percept_avg_r(NumCond,NumSubj) = 0;
zP2P_avg(NumCond,NumSubj) = 0;

%keyboard;
rH1T(NumCond,NumSubj) = 0; pH1T(NumCond,NumSubj) = 0;
rH2T(NumCond,NumSubj) = 0; pH2T(NumCond,NumSubj) = 0;
zH1T(NumCond,NumSubj) = 0; zH2T(NumCond,NumSubj) = 0;

history_to_lnT_avg_r(NumCond,NumSubj) = 0;
zCumhist_Avg(NumCond,NumSubj) = 0;
tauOpt(NumCond,NumSubj) = 0;
tauMaxR(NumCond,NumSubj) = 0;
            
SegStarts = []; maxR(NumCond,NumSubj) = 0;
firstDurRatio(NumReps,NumSubj,NumCond) = 0;
firstSegRatio(NumReps,NumSubj,NumCond) = 0; 

for cInd = 1:NumCond
    
    for sInd = 1:NumSubj
        
        % first i'm going to split each trial into pre and post,
        % cut off the first Int (if it starts Int)
        % and then we'll combine them all together
        for rInd = 1:NumReps
            
            Durs = DurationsCell{cInd,sInd,rInd};
            
            if length(Durs)<5 % at 4 rows we get at least one S->I
                firstDurRatio(rInd,sInd,cInd) = NaN; 
                firstSegRatio(rInd,sInd,cInd) = NaN;
                continue
            end
            
            [Ipre, Spre, Ipost, Spost] = split_Durs(Durs);
            mu1 = mean(Ipost); mu2 = mean(Spost);
            SegProp(cInd,sInd) = mu2/(mu1+mu2);
            IntMeans(cInd,sInd) = mu1; SegMeans(cInd,sInd) = mu2;
            firstSegRatio(rInd,sInd,cInd) = Spre(1)/mu2;
            
            if Durs(2,2) == 1 % first percept is probably grouped, and longer
                Ipre = Ipre(2:end); Spost = Spost(2:end);
                firstDurRatio(rInd,sInd,cInd) = Ipre(1)/mu1;
            else
                SegStarts = [SegStarts; cInd sInd rInd];
                firstDurRatio(rInd,sInd,cInd) = NaN;
            end
            
            IpreTot{cInd,sInd} = [IpreTot{cInd,sInd}; Ipre];
            SpostTot{cInd,sInd} = [SpostTot{cInd,sInd}; Spost];
            
            SpreTot{cInd,sInd} = [SpreTot{cInd,sInd}; Spre];
            IpostTot{cInd,sInd} = [IpostTot{cInd,sInd}; Ipost];
        end
        
        Ipre = IpreTot{cInd,sInd}; Spost = SpostTot{cInd,sInd};
        Spre = SpreTot{cInd,sInd}; Ipost = IpostTot{cInd,sInd};
        
        % find frac Dom
        
        
        if length(Spost) < 3
            pIS(cInd,sInd) = NaN; rIS(cInd,sInd) = NaN;
            pSI(cInd,sInd) = NaN; rSI(cInd,sInd) = NaN;
            zIS(cInd,sInd) = NaN; zSI(cInd,sInd) = NaN;
            percept_to_percept_avg_r(cInd,sInd) = NaN;
            zP2P_avg(cInd,sInd) = NaN; pP2P(cInd,sInd) = NaN;
            pH1T(cInd,sInd) = NaN; 
            pH2T(cInd,sInd) = NaN;
            continue;
        end
        
        % now let's look at SI, IS corrs
        [ZrP2P, r11, r22, z1, z2, p11, p22, pTot] = ...
            compute_pWeightedR_cumhist(Spost,Ipost, Ipre, Spre);
        
        rIS(cInd,sInd) = r11; pIS(cInd,sInd) = p11;
        rSI(cInd,sInd) = r22; pSI(cInd,sInd) = p22;
        zIS(cInd,sInd) = z1; zSI(cInd,sInd) = z2;
        
        nIpre = length(Spost); nSpre = length(Ipost);
        percept_to_percept_avg_r(cInd,sInd) = fisher_combine_corrs(...
            [r11; r22], [nIpre; nSpre]);
        zP2P_avg(cInd,sInd) = ZrP2P;
 
        % now let's find the tau, z, r for cumhist
        DursCell = DurationsCell(cInd,sInd,:);
        DursCell = squeeze(squeeze(DursCell));
        DursCell = DursCell(~cellfun('isempty',DursCell));
%         
%         f = @(tau)compute_cumhist_corr(DursCell,tau);
%         g = @(tau)-f(tau);
%         
%         LB = .5; UB = 60;
%         
        
        if any(cellfun('length',DursCell)<3) 
            %keyboard;
            rH1T(cInd,sInd) = NaN; pH1T(cInd,sInd) = NaN;
            rH2T(cInd,sInd) = NaN; pH2T(cInd,sInd) = NaN;
            zH1T(cInd,sInd) = NaN; zH2T(cInd,sInd) = NaN;
            
            history_to_lnT_avg_r(cInd,sInd) = NaN;
            zCumhist_Avg(cInd,sInd) = NaN;
            tauOpt(cInd,sInd) = NaN;
            tauMaxR(cInd,sInd) = NaN; maxR(cInd,sInd) = NaN;
            continue
        else
            % consider trying random inits (third argument after bNull=0)
            [parmhat fval parsMaxR output rval] = estimate_cumhist_pars(DursCell);
            tauH = abs(parmhat(end)); maxR(cInd,sInd) = rval;
            parmhat([1 2 7]) = abs(parmhat([1 2 7]));
            
            [ZrCombined, r11, r22, z1, z2, p11, p22, n1, n2] = ...
                compute_cumhist_corr(DursCell,tauH);
            cumhist_pars(:,cInd,sInd) = parmhat;
            cumhistOptInfo(cInd,sInd) = output;
            
            rH1T(cInd,sInd) = r11; pH1T(cInd,sInd) = p11;
            rH2T(cInd,sInd) = r22; pH2T(cInd,sInd) = p22;
            zH1T(cInd,sInd) = z1; zH2T(cInd,sInd) = z2;
            
            
            history_to_lnT_avg_r(cInd,sInd) = fisher_combine_corrs(...
                [r11; r22], [n1;n2]);
            zCumhist_Avg(cInd,sInd) = ZrCombined;
            tauOpt(cInd,sInd) = tauH; tauMaxR(cInd,sInd) = parsMaxR(end);
        end
    end
end


%%
df_posA = 1:3:NumCond*3;
barWidth = .3;
pSigThresh = .05;

pSigIS = pIS<pSigThresh;
pSigISVec = reshape(pSigIS,1,numel(pSigIS));
pSigSI = pSI<pSigThresh;
pSigSIVec = reshape(pSigSI,1,numel(pSigSI));

bigFigure;

h1 = bar3(df_posA-.5,rIS,barWidth); 
S1 = resurface_bar3(h1);
set(S1, 'facecolor',[0 0.5 0])
set(S1(pSigISVec),'facecolor','g');

hold on;
h2 = bar3(df_posA+.5,rSI,barWidth);
S2 = resurface_bar3(h2);
set(S2,'facecolor',[0 0 .5])
set(S2(pSigSIVec),'facecolor','b')
%set(gca,'Color',[.2 .2 .2])
xlabel('Subject'); ylabel('DF')
title(sprintf('IS (green) vs SI (blue) corrs, %d/%d sig', ...
    sum(pSigSIVec)+sum(pSigISVec), length(pSigSIVec)*2))

set(gca,'YTick',df_posA)
set(gca,'YTickLabel',DFvals);

%%
zISvec = reshape(zIS,1,numel(zIS));
zSIvec = reshape(zSI,1,numel(zSI));

figure; scatter(zISvec,zSIvec); mk_Nice_Plot;
xlabel('Z corr IS'); ylabel('Z corr SI'); 
title('IS vs SI correlation Z scores')

%%
df_posA = 1:3:NumCond*3;
barWidth = .3;
pSigThresh = .05;

pSigH1T = pH1T<pSigThresh;
pSigH1Tvec = reshape(pSigH1T,1,numel(pSigH1T));
pSigH2T = pH2T<pSigThresh;
pSigH2Tvec = reshape(pSigH2T,1,numel(pSigH2T));

bigFigure;

h1 = bar3(df_posA-.5,rH1T,barWidth); 
S1 = resurface_bar3(h1);
set(S1, 'facecolor',[0 0.25 0.25])
set(S1(pSigH1Tvec),'facecolor',[0 1 1]);

hold on;
h2 = bar3(df_posA+.5,rH2T,barWidth);
S2 = resurface_bar3(h2);
set(S2,'facecolor',[0.25 0 .25])
set(S2(pSigH2Tvec),'facecolor',[1 0 1])
%set(gca,'Color',[.2 .2 .2])
xlabel('Subject'); ylabel('DF')
title(sprintf('H1 (cyan) vs H2 (purple) corrs, %d/%d sig', ...
    sum(pSigH1Tvec)+sum(pSigH2Tvec), length(pSigH1Tvec)*2))

set(gca,'YTick',df_posA)
set(gca,'YTickLabel',DFvals);      

%%
zH1Tvec = reshape(zH1T,1,numel(zH1T)); zH2Tvec = reshape(zH2T,1,numel(zH2T));
figure; scatter(zH1Tvec, zH2Tvec); mk_Nice_Plot;
xlabel('Z corr H1-lnT1'); ylabel('Z corr H2-lnT2'); 
title('Cumulative history Z scores by percept type')
%% Zcombined for both
bigFigure;
df_posA = 1:3:NumCond*3;
barWidth = .3;

sigP2P = exp(-zP2P_avg.^2/2)<pSigThresh;%abs(zP2P_avg)>2; 
sigP2Pvec = reshape(sigP2P,1,numel(sigP2P));
sigCumhist = exp(-zCumhist_Avg.^2/2)<pSigThresh;%abs(zCumhist_Avg)>2; 
sigCumhistVec = reshape(sigCumhist,1,numel(sigCumhist));


h1 = bar3(df_posA-.5,zP2P_avg,barWidth); 
S1 = resurface_bar3(h1);
set(S1,'facecolor',[0 0 .5])
set(S1(sigP2Pvec),'facecolor','b')
hold on;
h2 = bar3(df_posA+.5,zCumhist_Avg,barWidth);
S2 = resurface_bar3(h2);
set(S2,'facecolor',[.25 0 .25]);
set(S2(sigCumhistVec),'facecolor','m')

xlabel('Subject'); ylabel('DF')
title(sprintf('P2P (blue) vs cumhist (magenta) corrs, %d/%d match sig', ...
    sum(sigP2Pvec & sigCumhistVec),sum(sigP2Pvec)+sum(sigCumhistVec)))

set(gca,'YTick',df_posA)
set(gca,'YTickLabel',DFvals);      




%% tau/mu axis for significant correlations with cumhist

[sigCond sigSubj] = find(sigP2P);
h = figure;
nTaus = 20;
tau_axMu = logspace(-1,1,nTaus);

zVals(length(sigCond),nTaus) = 0;
rVals(length(sigCond),nTaus) = 0;
for ind = 1:length(sigCond)
    
    
    cond = sigCond(ind); subj = sigSubj(ind);
    
    mu = (IntMeans(cond,subj) + SegMeans(cond,subj))/2;
    tau_ax = mu*tau_axMu;
    DursCell = squeeze(squeeze(DurationsCell(sigCond(ind),sigSubj(ind),:)));
    DursCell = DursCell(~cellfun('isempty',DursCell));
    
       for tInd = 1:nTaus
        
            tau = tau_ax(tInd);
        
            [ZrCombined, r11, r22, z11, z22, p11, p22] = ...
                compute_cumhist_corr(DursCell,tau);
            
            rVals(ind,tInd) = tanh(.5*(atanh(abs(r11)) + atanh(abs(r22))));
            zVals(ind,tInd) = ZrCombined;
        
       end
       figure(h); hold on;
       semilogx(tau_axMu, zVals(ind,:)*.1); %,rVals(ind,:),':',tau_axMu,
       mk_Nice_Plot;
       
%        title(sprintf('DF%d s%d mu1=%.2f mu2= %.2f',DFvals(cond),subj,...
%            IntMeans(cond,subj), SegMeans(cond,subj)));
%        
        title('cumhist for strong p2p corrs');
       %legend('r_{absCombined}','Fisher Distance * .1')
       legend('Fisher Distance * .1')
       
       xlabel('tau/mu'); ylabel('Correlation value (r and Z)');
       
       
end
set(gca,'xscale','log')