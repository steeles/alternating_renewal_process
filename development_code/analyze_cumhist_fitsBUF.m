% analyze_cumhist_fits

clear
cd ~/Dropbox/my' codes'/rinzel/results/
load('cumhist_data')
load('cumhist_fits_random_inits')
load('cumhist_stubborn_pars.mat')
%%

bMaxR = 0;
thresh = .05;
%cumhist_pVals = exp(-zCumhist_Avg.^2/2);
if bMaxR
    cumhist_pVals = exp(-MaxR.^2/2);
else
    cumhist_pVals = exp(-zCumhist.^2/2);
end
minTau = .2;

sigControl = cumhist_pVals<thresh & tauOpt>minTau;
[sigCond sigSubj] = find(sigControl);
sigSingleInds = find(sigControl);

numSig = length(sigCond);

binWidth = .1;
Hbins = 0:binWidth:1;
nBins = 1/binWidth;

Tsame_over_muSame = zeros(numSig,nBins);
Tother_over_muOther = zeros(numSig,nBins);

T1_by_H1 = zeros(numSig,nBins);
%T2_by_H1 = zeros(numSig,nBins);
T2_by_H2 = zeros(numSig,nBins);

segProp = zeros(numSig,1);
tauSig = zeros(numSig,1);

suboptimalFits = []; goodFits = []; noBUF = []; numSamples = [];

T1Durs = cell(1,nBins);
T2Durs = cell(1,nBins);
H11s = cell(1,nBins);
H22s = cell(1,nBins);



bPlot = 1;
if bPlot
    hCloud = bigFigure; hCloudStabilized = bigFigure;
end

trialCount = 0;
DataTot = cell(1);
pars.window = 15; pars.step = .1;

for ind = 1:numSig
    
    cond = sigCond(ind); subj = sigSubj(ind);
    
    foo = cumhistOptInfo(cond,subj).message;
    if 1%all(foo(1:19) == 'Local minimum found') || bMaxR
        
        DursCell = squeeze(squeeze(DurationsCell(cond,subj,:)));
        DursCell = DursCell(~cellfun('isempty',DursCell));
        allDurs = vertcat(DursCell{:});
        mu = mean(allDurs(allDurs(:,1)~=0,1));
        muInt = IntMeans(cond,subj); muSeg = SegMeans(cond,subj);
        
        mle_pars = cumhist_pars(:,cond,subj);
        if ~bMaxR
            tau = abs(tauOpt(cond,subj));
            diffTaus(ind) = tau - tauMaxR(cond,subj);
        else
            tau = tauMaxR(cond,subj);
        end
        
        H_Durs = [];
        
        % construct an array of H values and Durs, from beginning
        
        for rInd = 1:length(DursCell)
            
            Durs = DursCell{rInd};
            [h1 h2] = compute_H_2(Durs,tau,0);
            
            % non-clipped; from the beginning of the trial!
            % try finding steady state, like in the original paper
            H_Durs = [H_Durs; h1(1:end-1,1) h2(1:end-1,1) Durs(2:end,:)];
            
            Durs = Durs(2:end,:);
            
            if length(Durs)<4 || Durs(1,2) == 2
                noBUF = [noBUF; cond subj rInd]; continue; 
            end
            
            ARP_data(ind,rInd) = ARP_durs_BUF(Durs,pars);
            trialCount = trialCount + 1;
        end
        
        ARP_data_tot(ind) = combine_ARP_data(ARP_data(ind,:));
        
        goodFits = [goodFits; cond subj]; numSamples = [numSamples; size(H_Durs,1)];
        
        segProp(ind) = muSeg/(muInt+muSeg);
        
        tauSig(ind) = tau;
        
        intInds = H_Durs(:,4)==1; segInds = H_Durs(:,4) == 2;
        
%         if bPlot
%             figure(hCloud); plot(H_Durs(intInds,1),H_Durs(intInds,3),'r.'); hold on;
%             plot(H_Durs(intInds,2),H_Durs(intInds,3),'b.');
%             plot(H_Durs(segInds,2),H_Durs(segInds,3),'r.');
%             plot(H_Durs(segInds,1),H_Durs(segInds,3),'b.');
%         end
        if 0
            figure(hCloud); plot(H_Durs(intInds,1),H_Durs(intInds,3),'r.'); hold on;
            %plot(H_Durs(intInds,2),H_Durs(intInds,3),'b.');
            plot(H_Durs(segInds,2),H_Durs(segInds,3),'b.');
            %plot(H_Durs(segInds,1),H_Durs(segInds,3),'b.');
        end
        tolerance = 1e-5;
        stabilized = (abs(H_Durs(:,1) + H_Durs(:,2) - 1) < tolerance);
        %stabilized = ones(size(H_Durs,1),1) > 0;
        time_to_steady_state(ind) = sum(H_Durs(~stabilized,3))/length(DursCell);
        %keyboard
        H1 = H_Durs(stabilized,1); H2 = H_Durs(stabilized,2); durstmp = H_Durs(stabilized,3:4);
        
        intInds = durstmp(:,2)==1; segInds = durstmp(:,2)==2;
        
        if bPlot
            figure(hCloudStabilized); plot(H1(intInds),durstmp(intInds,1),'r.');
            hold on;
            %plot(H1(segInds),durstmp(segInds,1),'b.');
            plot(H2(segInds),durstmp(segInds,1),'b.');
            %plot(H2(intInds),durstmp(intInds,1),'b.');
        end
        
        for hInd = 1:length(Hbins)-1
            
            % finds H vals preceding either percept in the specified bin
            h1vals = find(H1>=Hbins(hInd) & H1<=Hbins(hInd+1));
            h2vals = find(H2>=Hbins(hInd) & H2<=Hbins(hInd+1));
            
            inds = unique(vertcat(h1vals, h2vals));
            
            H1Durs = durstmp(h1vals,:);
            h11Durs = H1Durs(H1Durs(:,2)==1,1);
            h12Durs = H1Durs(H1Durs(:,2)==2,1);
            
            T1Durs{ind,hInd} = h11Durs; H11s{ind,hInd} = H1(h1vals(H1Durs(:,2)==1));
            
            
            H2Durs = durstmp(h2vals,:);
            h22Durs = H2Durs(H2Durs(:,2)==2,1);
            h21Durs = H2Durs(H2Durs(:,2)==1,1);
            
            T2Durs{ind,hInd} = h22Durs; H22s{ind,hInd} = H2(h2vals(H2Durs(:,2)==2));
            
            % this is probably the right way
            normSame = vertcat(h11Durs/muInt,h22Durs/muSeg);
            normOther = vertcat(h12Durs/muSeg,h21Durs/muInt);
            %
            %         normSame = vertcat(h11Durs/mu,h22Durs/mu);
            %         normOther = vertcat(h12Durs/mu,h21Durs/mu);
            
            Tsame_over_muSame(ind,hInd) = mean(normSame);
            Tother_over_muOther(ind,hInd) = mean(normOther);
            
            foo = mean(h11Durs)/muInt;
            % if foo>5, keyboard; end
            
            T1_by_H1(ind,hInd) = mean(h11Durs)/muInt;
            %T2_by_H1(ind,hInd) = mean(h12Durs)/muSeg;
            T2_by_H2(ind,hInd) = mean(h22Durs)/muSeg;
        end
        
    else
        suboptimalFits = [suboptimalFits; sigCond(ind) sigSubj(ind)];
        continue;
    end
end

Tsame_over_muSame(all(Tsame_over_muSame==0,2),:) = [];
Tother_over_muOther(all(Tother_over_muOther==0,2),:) = [];
T1_by_H1(all(T1_by_H1==0,2),:) = [];
%T2_by_H1(all(T2_by_H1==0,2),:) = [];
T2_by_H2(all(T2_by_H2==0,2),:) = [];

binCenters = binWidth/2:binWidth:1;


mnSameOverSame = mean(Tsame_over_muSame,'omitnan');
stdSameSame = std(Tsame_over_muSame,'omitnan');
nSameSame = sum(~isnan(Tsame_over_muSame));
seSameSame = stdSameSame./sqrt(nSameSame);
sameInds = ~isnan(mnSameOverSame);
%[ps] = polyfit(binCenters(sameInds),mnSameOverSame(sameInds),1);
fs = fit(binCenters(sameInds)',mnSameOverSame(sameInds)','exp2');

mnOtherOverOther = mean(Tother_over_muOther,'omitnan');
stdOtherOther = std(Tother_over_muOther,'omitnan');
nOtherOther = sum(~isnan(Tother_over_muOther));
seOtherOther = stdOtherOther./sqrt(nOtherOther);
othInds = ~isnan(mnOtherOverOther);
%[po] = polyfit(binCenters(othInds),mnOtherOverOther(othInds),1);
fo = fit(binCenters(othInds)',mnOtherOverOther(othInds)','exp2');

mnT1byH1 = mean(T1_by_H1, 'omitnan');
stdT1 = std(T1_by_H1, 'omitnan');
nT1 = sum(~isnan(T1_by_H1));
seT1 = stdT1./sqrt(nT1);
t1inds = ~isnan(mnT1byH1);
f1 = fit(binCenters(t1inds)',mnT1byH1(t1inds)','exp1');

mnT2byH2 = mean(T2_by_H2,'omitnan');
stdT2 = std(T2_by_H2,'omitnan');
nT2 = sum(~isnan(T2_by_H2));
seT2 = stdT2./sqrt(nT2);
t2inds = ~isnan(mnT2byH2);
f2 = fit(binCenters(t2inds)',mnT2byH2(t2inds)','exp1');

%     tmp = binCenters(sameInds);
%     xs = tmp(1):.01:tmp(end);
%     ys = polyval(ps,xs); 
%     
%     tmp = binCenters(othInds); xo = tmp(1):.01:tmp(end);
%     yo = polyval(po,xo);

    figure; 
    errorbar(binCenters,mnSameOverSame,seSameSame,'ro'); hold on;
    errorbar(binCenters,mnOtherOverOther,seOtherOther,'bo');
    plot(fs,binCenters,mnSameOverSame,'ro'); 
    h=plot(fo,binCenters,mnOtherOverOther,'bo');set(h,'color','b')
    mk_Nice_Plot;
    xlabel('H'); ylabel('T_{h=x} / T_{avg}'); legend('same','other');
    
    figure; errorbar(binCenters,mnT1byH1,seT1,'ro'); hold on;
    errorbar(binCenters,mnT2byH2,seT2,'bo'); 
    plot(f1,binCenters,mnT1byH1,'ro');
    h=plot(f2,binCenters,mnT2byH2,'bo'); set(h,'color','b');
    mk_Nice_Plot;
    xlabel('H_x'); hy=ylabel('$T_x / \bar{T}_x$'); legend('x=1','x=2')
    set(hy,'interpreter','Latex','FontSize',18); %set(h,'FontName','Arial')
    %title('Duration as a function of history')
    
if bPlot
    figure(hCloudStabilized); axis([0 1 0 60]); mk_Nice_Plot; xlabel('H_x');
    hy=ylabel('$T_x / \bar{T}_x$'); legend('x=1','x=2')
    set(hy,'interpreter','Latex','FontSize',18);
    title('T vs cumulative history');
    
%     figure(hCloudStabilized); axis([0 1 0 60]); mk_Nice_Plot; xlabel('H');
%     ylabel('T_{h=x} / T_{avg}'); legend('same','other');title('T vs cumulative history (steady state)');
end

%%
for ind = 1:length(goodFits)
    
    cond = goodFits(ind,1); subj = goodFits(ind,2);
    
    chParams = cumhist_pars(:,cond,subj);
    DursCell = squeeze(squeeze(DurationsCell(cond,subj,:)));
    DursCell = DursCell(~cellfun('isempty',DursCell));
    hists_by_H_cumhist(DursCell, chParams); title(...
        sprintf('c%d s%d | tau=%.2f',DFvals(cond),subj,chParams(end)))
    
end

%%
allT1 = vertcat(T1Durs{:}); g1 = gamfit(allT1);
allH1 = vertcat(H11s{:}); 

lnT1 = log(allT1); 

figure; plot(allH1,lnT1,'.')

%%
pSplitVecSC = reshape(SegProp,1,numel(SegProp));
zP2Pvec = reshape(zP2P_avg,1,numel(zP2P_avg)); ...
    %zSIvecSC = reshape(SC_zSI, 1, numel(SC_zSI));

figure; plot(pSplitVecSC,zP2Pvec,'b.','MarkerSize',9); mk_Nice_Plot;
%hold on; plot(pSplitVecSC,zSIvecSC,'m.','MarkerSize',9);
xlabel('Proportion segregated (Subj/Condn)'); ylabel('Fisher Distance')
hold on; plot([0 1], [2.447 2.447], 'r--')
title('correlation strength vs proportion seg')

%% sensitivity
sum(sum(MaxR<-2.447))
sum(sum(zP2P_avg>2.447))

%%



%%
mnP2P_cond = mean(zP2P_avg,2,'omitnan');
figure; plot(1:8, mnP2P_cond);
%set(gca,'FontName','Arial','FontSize',20,'LineWidth',2)
mk_Nice_Plot;
set(gca,'XTickLabel',DFvals,'XTick',[1:8]); xlim([1 8])
 xlabel('DF'); ylabel('serial correlation'); hold on 
plot([1 8],[2.447 2.447],'r--')
%%
mnP2P_subj= mean(zP2P_avg,1,'omitnan');
figure; plot(1:15, mnP2P_subj);
%set(gca,'FontName','Arial','FontSize',20,'LineWidth',2)
mk_Nice_Plot;
set(gca,'XTickLabel',1:15,'XTick',[1:15]); xlim([1 15])
 xlabel('subject'); ylabel('serial correlation'); hold on 
plot([1 15],[2.447 2.447],'r--')

%%
mnR_cond = mean(percept_to_percept_avg_r,2,'omitnan');
figure; plot(1:8, mnR_cond);
%set(gca,'FontName','Arial','FontSize',20,'LineWidth',2)
mk_Nice_Plot;
set(gca,'XTickLabel',DFvals,'XTick',[1:8]); xlim([1 8])
 xlabel('DF'); ylabel('serial correlation'); hold on 
%plot([1 8],[2.447 2.447],'r--')

%%
%%
mnR_subj = mean(percept_to_percept_avg_r,1,'omitnan');
figure; plot(1:15, mnR_subj);
%set(gca,'FontName','Arial','FontSize',20,'LineWidth',2)
mk_Nice_Plot;
set(gca,'XTickLabel',[1:15],'XTick',[1:15]); xlim([1 15])
 xlabel('Subject'); ylabel('serial correlation'); hold on 
%plot([1 8],[2.447 2.447],'r--')

%% make some BUFs! use only the good fits

nBoot = 1000;
bufLength = size(ARP_data_tot(1).BUF,2);

if length(goodFits) ~= length(ARP_data_tot), 
    disp('data sets don''t match up'); 
end

for ind = 1:length(goodFits)
    
    BUFcloudARP = zeros(nBoot,bufLength);
    BUFcloudCumhist = zeros(nBoot,bufLength);
    
    cond = goodFits(ind,1); subj = goodFits(ind,2);
    mlePars = cumhist_pars(:,cond,subj);
    ARPpars = ARP_data_tot(ind);
    v2struct(ARPpars);
    
    nSwitches = numSamples(ind); 
    if mod(nSwitches,2)==1, nSwitches = nSwitches-1; end
    
    for it = 1:nBoot
        ARPdurs = make_2gamma_distrs(g1,g2,nSwitches);
        BUFcloudARP(it,:) = ...
            make_switchTriggeredBUF(ARPdurs,pars.step,pars.window);
        
        cumhistDurs = generate_cumhist_func(mlePars,nSwitches);
        BUFcloudCumhist(it,:) = ...
            make_switchTriggeredBUF(cumhistDurs(2:end,:),pars.step,...
            pars.window);
    end
    
    tail = round(nBoot * thresh * .5);
    
    arpSort = sort(BUFcloudARP);
    chSort = sort(BUFcloudCumhist);
    
    arpUB = arpSort(tail,:);
    arpLB = arpSort(end-tail,:);
    arpPred = mean(arpSort,1,'omitnan');
    
    chUB = chSort(tail,:);
    chLB = chSort(end-tail,:);
    cumhistPred = mean(chSort,1,'omitnan');
    
    figure; hold on; plot(tax,BUF,'r')
    plot(tax,arpPred,'b'); plot(tax,cumhistPred,'g')
    plot(tax,arpUB,'b--'); plot(tax,chUB,'g--');
    plot(tax,arpLB,'b--'); plot(tax,chLB,'g--');
    mk_Nice_Plot; title(sprintf('u_1=%.2f,u_2=%.2f|c%d,s%d',...
    IntMeans(cond,subj),SegMeans(cond,subj),cond,subj));
    
    text(10,0.1,sprintf('(r1,r2)=(r1,r2)=%.2f,%.2f',...
         ...
        rH1T(cond,subj),rH2T(cond,subj)))
    
end


%%
for ind = 1:length(suboptimalFits)
    cond = suboptimalFits(ind,1); subj = suboptimalFits(ind,2);
    DursCell = squeeze(squeeze(DurationsCell(cond,subj)));
    DursCell = DursCell(~cellfun('isempty',DursCell));
        
    init = cumhist_pars(:,cond,subj);
    [parmhat fval parsMaxR output maxR] = estimate_cumhist_pars(Durs,0,init);

    if all(output.message(1:19) == 'Local minimum found')
        disp('The prodigal son returns!')
        cumhist_pars(:,cond,subj) = parmhat;
        cumhistOptInfo(cond,subj) = output;
        tauOpt(cond,subj) = parmhat(end);
        zCumhist(cInd,sInd) = compute_cumhist_corr(DursCell,parmhat(end));
    else
        [parmhat fval parsMaxR output maxR] = estimate_cumhist_pars(Durs,0,parmhat);
        if all(output.message(1:19) == 'Local minimum found')
            disp('The prodigal son returns!')
            cumhist_pars(:,cond,subj) = parmhat;
            cumhistOptInfo(cond,subj) = output;
            tauOpt(cond,subj) = parmhat(end);
            zCumhist(cInd,sInd) = compute_cumhist_corr(DursCell,parmhat(end));
        else
            [parmhat fval parsMaxR output maxR] = estimate_cumhist_pars(Durs,0,parmhat);
            if all(output.message(1:19) == 'Local minimum found')
                disp('The prodigal son returns!')
                cumhist_pars(:,cond,subj) = parmhat;
                cumhistOptInfo(cond,subj) = output;
                tauOpt(cond,subj) = parmhat(end);
                zCumhist(cInd,sInd) = compute_cumhist_corr(DursCell,parmhat(end));
            else
                disp('i give up')
            end
        end
    end
end
save('cumhist_stubborn_pars')