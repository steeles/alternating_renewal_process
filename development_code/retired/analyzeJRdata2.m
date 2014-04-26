% analyzeJRdata2
clear; 

global DURS DURS1 DURS2 G1 G2 BUF NWINDOWS

wind = 10; bPlot = 1; figure;screenSize = get(0,'Screensize');
set(gcf, 'Position', screenSize); % Maximize figure
subplot(4,6,3)

cd ~/Dropbox/my' codes'/rinzel/experiment_code/data/Johns' Triplet Data'/steady_triplet_03/
% data file format SubjID.dd.mm.yyyy.trialnum
% let's start with subj 3, session from 8/6/2011. 2 trials, DF=4,5,6
 subjID = 3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load 03.08.06.2011.1.mat
% result is a 4D struct, but appears to have two sets of params for DF = 4,
% HI7 Lo3 and HI 6 LO2. result(1).data (7 3) only has 6 entries, so let's
% start from result(2) (params 9 4, df=5)

n = 2; KPushETs_ss; durs = durs(1:end-1,:); % i wanna make sure I don't include any interrupted durs

df = 5; trialnum = 1; analyzeData(durs,df,trialnum,subjID,wind)

durs1 = DURS1{trialnum,df,subjID}; durs2 = DURS2{trialnum,df,subjID};
if bPlot
    subplot(4,6,3); hist(durs1); title('DF=5,coh'); 
    legend(['N=' num2str(length(durs1))],'Location','SouthOutside'); 
    text(15,2,num2str(G1{trialnum,df,subjID},3));
    subplot(4,6,4);
    hist(durs2); title('DF=5,seg'); 
    legend(['N=' num2str(length(durs2))],'Location','SouthOutside');
    text(15,4,num2str(G2{trialnum,df,subjID},3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result(3).params = [120 500 12 6 120 3], DF = 6;

n = 3; KPushETs_ss; durs = durs(1:end-1,:); % i wanna make sure I don't include any interrupted durs

df = 6; trialnum = 1; analyzeData(durs,df,trialnum,subjID,wind)

durs1 = DURS1{trialnum,df,subjID}; durs2 = DURS2{trialnum,df,subjID};
if bPlot
    subplot(4,6,5); hist(durs1); title('DF=6,coh'); 
    legend(['N=' num2str(length(durs1))],'Location','SouthOutside');
    text(5,.4,num2str(G1{trialnum,df,subjID},3));
    subplot(4,6,6);
    hist(durs2); title('DF=6,seg'); 
    legend(['N=' num2str(length(durs2))],'Location','SouthOutside');
    text(50,.4,num2str(G2{trialnum,df,subjID},3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result(4).params = [120 500 6 2 120 4], DF = 4

n = 4; KPushETs_ss; durs = durs(1:end-1,:); % i wanna make sure I don't include any interrupted durs

df = 4; trialnum = 1; analyzeData(durs,df,trialnum,subjID,wind)

durs1 = DURS1{trialnum,df,subjID}; durs2 = DURS2{trialnum,df,subjID};
if bPlot
    subplot(4,6,1); hist(durs1); title('DF=4,coh'); 
    legend(['N=' num2str(length(durs1))],'Location','SouthOutside');
    text(7,5,num2str(G1{trialnum,df,subjID},3));
    subplot(4,6,2);
    hist(durs2); title('DF=4,seg'); 
    legend(['N=' num2str(length(durs2))],'Location','SouthOutside');
    text(10,4,num2str(G2{trialnum,df,subjID},3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trial 2 for same subj and conds (hopefully)

load 03.08.06.2011.2.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result(1).params = [120 500 12 6 120 1] DF =6

n = 1; KPushETs_ss; durs = durs(1:end-1,:);
df = 6; trialnum = 2; analyzeData(durs,df,trialnum,subjID,wind)

durs1 = DURS1{trialnum,df,subjID}; durs2 = DURS2{trialnum,df,subjID};
if bPlot
    subplot(4,6,11); hist(durs1); title('DF=6,coh'); 
    legend(['N=' num2str(length(durs1))],'Location','SouthOutside');
    text(5,2,num2str(G1{trialnum,df,subjID},3));
    subplot(4,6,12);
    hist(durs2); title('DF=6,seg'); 
    legend(['N=' num2str(length(durs2))],'Location','SouthOutside');
    text(20,4,num2str(G2{trialnum,df,subjID},3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result(2).params = [120 500 6 2 120 2], DF = 4

n = 2; KPushETs_ss; durs = durs(1:end-1,:); 
df = 4; analyzeData(durs,df,trialnum,subjID,wind)

durs1 = DURS1{trialnum,df,subjID}; durs2 = DURS2{trialnum,df,subjID};

if bPlot
    subplot(4,6,7); hist(durs1); title('DF=4,coh'); 
    legend(['N=' num2str(length(durs1))],'Location','SouthOutside');
    text(10,10,num2str(G1{trialnum,df,subjID},3));
    subplot(4,6,8);
    hist(durs2); title('DF=4,seg'); 
    legend(['N=' num2str(length(durs2))],'Location','SouthOutside');
    text(10,10,num2str(G2{trialnum,df,subjID},3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result(3).params = [120 500 9 4 120 3] DF = 5

n = 3; KPushETs_ss; durs = durs(1:end-1,:);
df = 5; analyzeData(durs,df,trialnum,subjID,wind)

durs1 = DURS1{trialnum,df,subjID}; durs2 = DURS2{trialnum,df,subjID};

if bPlot
    subplot(4,6,9); hist(durs1); title('DF=5,coh'); 
    legend(['N=' num2str(length(durs1))],'Location','SouthOutside'); 
    text(15,2,num2str(G1{trialnum,df,subjID},3));
    subplot(4,6,10);
    hist(durs2); title('DF=5,seg'); 
    legend(['N=' num2str(length(durs2))],'Location','SouthOutside');
    text(15,4,num2str(G2{trialnum,df,subjID},3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let's try to get that data out of 3.19.05.2011.1 & 2- going from data,
% not rawdata, so i'll have a different durs array

load 03.19.05.2011.1.mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result(1).params = [120 500 9 4 120 1] DF = 5

durs = result(1).data(2:end,:); df = 5; trialnum = 3; 
analyzeData(durs,df,trialnum,subjID,wind);

durs1 = DURS1{trialnum,df,subjID}; durs2 = DURS2{trialnum,df,subjID};

if bPlot
    subplot(4,6,15); hist(durs1); title('DF=5,coh'); 
    legend(['N=' num2str(length(durs1))],'Location','SouthOutside'); 
    text(15,2,num2str(G1{trialnum,df,subjID},3));
    subplot(4,6,16); hist(durs2); title('DF=5,seg'); 
    legend(['N=' num2str(length(durs2))],'Location','SouthOutside');
    text(15,4,num2str(G2{trialnum,df,subjID},3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result(2).params = [120 500 6 2 120 2] DF =4

durs = result(2).data(2:end,:); df=4; analyzeData(durs,df,trialnum,subjID,wind);
durs1 = DURS1{trialnum,df,subjID}; durs2 = DURS2{trialnum,df,subjID};

if bPlot
    subplot(4,6,13); hist(durs1); title('DF=4,coh'); 
    legend(['N=' num2str(length(durs1))],'Location','SouthOutside');
    text(10,10,num2str(G1{trialnum,df,subjID},3));
    subplot(4,6,14);
    hist(durs2); title('DF=4,seg'); 
    legend(['N=' num2str(length(durs2))],'Location','SouthOutside');
    text(10,6,num2str(G2{trialnum,df,subjID},3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% result(3).params = [120 500 12 6 120 3] DF = 6

durs = result(3).data(2:end,:); df=6; analyzeData(durs,df,trialnum,subjID,wind);

durs1 = DURS1{trialnum,df,subjID}; durs2 = DURS2{trialnum,df,subjID};

if bPlot
    subplot(4,6,17); hist(durs1); title('DF=6,coh'); 
    legend(['N=' num2str(length(durs1))],'Location','SouthOutside');
    text(1,1,num2str(G1{trialnum,df,subjID},3));
    subplot(4,6,18);
    hist(durs2); title('DF=6,seg'); 
    legend(['N=' num2str(length(durs2))],'Location','SouthOutside');
    text(80,0.5,num2str(G2{trialnum,df,subjID},3));
end


%% aggregate
bAdjust = 1; % eliminate highest dur for outliers

durs1_4 = [DURS1{1,4,3}; DURS1{2,4,3}; DURS1{3,4,3}]; 
if bAdjust, durs1_4 = durs1_4(durs1_4<40); end
g1_4 = find_gamma_pars(durs1_4);
durs1_5 = [DURS1{1,5,3}; DURS1{2,5,3}; DURS1{3,5,3}]; g1_5 = find_gamma_pars(durs1_5);
if bAdjust, durs1_5 = durs1_5(durs1_5<15); end
durs1_6 = [DURS1{1,6,3}; DURS1{2,6,3}; DURS1{3,6,3}]; g1_6 = find_gamma_pars(durs1_6);

durs2_4 = [DURS2{1,4,3}; DURS2{2,4,3}; DURS2{3,4,3}]; g2_4 = find_gamma_pars(durs2_4);
if bAdjust, durs2_4 = durs2_4(durs2_4<20); end
durs2_5 = [DURS2{1,5,3}; DURS2{2,5,3}; DURS2{3,5,3}]; g2_5 = find_gamma_pars(durs2_5);
if bAdjust, durs2_5 = durs2_5(durs2_5<30); end
durs2_6 = [DURS2{1,6,3}; DURS2{2,6,3}; DURS2{3,6,3}]; g2_6 = find_gamma_pars(durs2_6);

subplot(4,6,19); hist(durs1_4); title('DF=4,coh:Total');
legend(['N=' num2str(length(durs1_4))],'Location','SouthOutside');
text(15,20,num2str(g1_4,3)); hold on;
xax = linspace(0,20,100); y = gampdf(xax,g1_4(1),g1_4(2)); plot(xax,y*length(durs1_4),'r');
subplot(4,6,20); hist(durs2_4); title('DF=4,seg:Total');
legend(['N=' num2str(length(durs2_4))],'Location','SouthOutside');
text(20,20,num2str(g2_4,3)); hold on;
xax = linspace(0,40,100); y = gampdf(xax,g2_4(1),g2_4(2)); plot(xax,y*length(durs2_4),'r');

subplot(4,6,21); hist(durs1_5); title('DF=5,coh:Total');
legend(['N=' num2str(length(durs1_5))],'Location','SouthOutside');
text(15,10,num2str(g1_5,3))
hold on; xax = linspace(0,20,100); 
y = gampdf(xax,g1_5(1),g1_5(2)); plot(xax,y*length(durs1_5),'r');
subplot(4,6,22); hist(durs2_5); title('DF=5,seg:Total');
legend(['N=' num2str(length(durs2_5))],'Location','SouthOutside');
text(20,20,num2str(g2_5,3)); hold on;
xax = linspace(0,40,100); y = gampdf(xax,g2_5(1),g2_5(2)); plot(xax,y*length(durs2_5),'r');

subplot(4,6,23); hist(durs1_6); title('DF=6,coh:Total');
legend(['N=' num2str(length(durs1_6))],'Location','SouthOutside');
text(8,3,num2str(g1_6,3))
hold on; xax = linspace(0,10,100); 
y = gampdf(xax,g1_6(1),g1_6(2)); plot(xax,y*length(durs1_6),'r');
subplot(4,6,24); hist(durs2_6); title('DF=6,seg:Total');
legend(['N=' num2str(length(durs2_6))],'Location','SouthOutside');
text(100,10,num2str(g2_6,3)); hold on;
xax = linspace(0,200,100); y = gampdf(xax,g2_6(1),g2_6(2)); plot(xax,y*length(durs2_6),'r');

%% BUFS

tax = [.01:.01:wind]; 
BUF4 = mean(BUF(:,:,4,3)); BUF5 = mean(BUF(:,:,5,3)); BUF6 = mean(BUF(:,:,6,3));
[BUFfit4 tfit] = make_fourier_buildup_function([g1_4;g2_4]);
[BUFfit5 tfit] = make_fourier_buildup_function([g1_5;g2_5]);
[BUFfit6 tfit] = make_fourier_buildup_function([g1_6;g2_6]);

ax = [0 10 0 1]; figure; subplot(131); 
plot(tax,BUF4,'b',tfit,BUFfit4,'r:'); legend(num2str(sum(NWINDOWS(:,4,3))))
title('DF=4 (tot)'); axis(ax);mk_Nice_Plot; 

subplot(132);
plot(tax,BUF5,'b',tfit,BUFfit5,'r:'); legend(num2str(sum(NWINDOWS(:,5,3))))
title('DF=5 (tot)'); axis(ax);mk_Nice_Plot; 

subplot(133); 
plot(tax,BUF6,'b',tfit,BUFfit6,'r:'); legend(num2str(sum(NWINDOWS(:,6,3))))
title('DF=6 (tot)'); axis(ax);mk_Nice_Plot; 
