% analyze_cumhist_fits

clear
load('cumhist_data2')
%%
thresh = .05;
cumhist_pVals = exp(-zCumhist_Avg.^2/2);

[sigCond sigSubj] = find(cumhist_pVals<thresh);
sigSingleInds = findf(cumhist_pVals<thresh);

numSig = length(sigCond);

binWidth = .1;
Hbins = 0:binWidth:1;
nBins = 1/binWidth;

Tsame_over_muSame = zeros(numSig,nBins);
Tother_over_muOther = zeros(numSig,nBins);

T1_by_H1 = zeros(numSig,nBins);
T2_by_H1 = zeros(numSig,nBins);

segProp = zeros(numSig,1);
tauSig = zeros(numSig,1);


for ind = 1:numSig
   
    cond = sigCond(ind); subj = sigSubj(ind);
    DursCell = squeeze(squeeze(DurationsCell(sigCond(ind),sigSubj(ind),:)));
    DursCell = DursCell(~cellfun('isempty',DursCell));
    allDurs = vertcat(DursCell{:});
    mu = mean(allDurs(allDurs(:,1)~=0,1));
    muInt = IntMeans(cond,subj); muSeg = SegMeans(cond,subj);
    
    segProp(ind) = muSeg/(muInt+muSeg);
    
    mle_pars = cumhist_pars(:,cond,subj);
    tau = mle_pars(7);
    %tau = tauMaxR(cond,subj);
    tauSig(ind) = tau;
    
    H_Durs = [];
    
    % construct an array of H values and Durs, from beginning
    for rInd = 1:length(DursCell)
        
        Durs = DursCell{rInd};
        [h1 h2] = compute_H_2(Durs,tau,0);
        
        % non-clipped; from the beginning of the trial!
        % try finding steady state, like in the original paper
        H_Durs = [H_Durs; h1(1:end-1,1) h2(1:end-1,1) Durs(2:end,:)]; 
        
    end
    
    
    for hInd = 1:length(Hbins)-1
        
        stabilized = find(H_Durs(:,1) + H_Durs(:,2) == 1,1);
        H1 = H_Durs(stabilized:end,1); H2 = H_Durs(stabilized:end,2); durstmp = H_Durs(:,3:4);
        
        % finds H vals preceding either percept in the specified bin
        h1vals = find(H1>=Hbins(hInd) & H1<Hbins(hInd+1));
        h2vals = find(H2>=Hbins(hInd) & H2<Hbins(hInd+1));
        
        inds = unique(vertcat(h1vals, h2vals));
        
        H1Durs = durstmp(h1vals,:);
        h11Durs = H1Durs(H1Durs(:,2)==1,1);
        h12Durs = H1Durs(H1Durs(:,2)==2,1);
        
        H2Durs = durstmp(h2vals,:);
        h22Durs = H2Durs(H2Durs(:,2)==2,1);
        h21Durs = H2Durs(H2Durs(:,2)==1,1);
        
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
        T2_by_H1(ind,hInd) = mean(h12Durs)/muSeg;
    end
    
end


binCenters = binWidth/2:binWidth:1;
figure; plot(binCenters,mean(Tsame_over_muSame,'omitnan'),'r'); hold on;
plot(binCenters,mean(Tother_over_muOther,'omitnan'),'b'); mk_Nice_Plot;
xlabel('H'); ylabel('T_{h=x} / T_{avg}'); legend('same','other');

figure; plot(binCenters,mean(T1_by_H1, 'omitnan'),'r'); hold on;
plot(binCenters,mean(T2_by_H1,'omitnan'),'b'); mk_Nice_Plot;
xlabel('H1'); ylabel('T_{h=x} / T_{avg}'); legend('T1','T2')
title('Duration as a function of history')