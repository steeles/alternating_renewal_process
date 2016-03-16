

% 

%datadir='/home/jr3830/proj/auditory/codes/jran-as-expt/pilotdata/';
if ismac
   datadir='/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/CorrData';
else
datadir='/home/jr3830/Insync/RankinExpt/CorrData/';
end
%minDur=0.;
fnames=dir([datadir]);fnames={fnames.name}

minDur=0.25;
fnames'
fnidx=17;%length(fnames)

fnames={fnames{fnidx}};
%%
for j=1:length(fnames)
fname=fnames{j};
figure(2+j);clf;hold on

DurOneAll=[];
DurTwoAll=[];
FstDurAll=[];

onsetFlag=0;

keydata=load([datadir,fname]);

OneStrTimes=keydata.OneStrTimes;
TwoStrTimes=keydata.TwoStrTimes;
AmbStrTimes=keydata.AmbStrTimes;
Tdur=keydata.Tdur;
NumTrips=keydata.NumTrips;
OnsetTimes=keydata.OnsetTimes;
StartTime=keydata.StartTime;
EndTime=keydata.EndTime;
% TripRegister=keydata.TripRegister
triplenInSecs=Tdur*4/1000;

PresentationTime=triplenInSecs*NumTrips;

TripTimes=linspace(0,PresentationTime,NumTrips+1);

[SwTimes,Durations]=ExtractTimesThree(OneStrTimes,TwoStrTimes,AmbStrTimes,minDur);

%% Do some plotting
make_colors
clrs={red,blue,green};
xend=240;
OnsetTimesPlot=OnsetTimes;%-StartTime;

%% One Stream

subplot(2,1,1);hold on
title(fname)
ylabel('Integrated')
if ~isempty(OneStrTimes)
histnorm(OneStrTimes,2000);
end
set(gca,'xlim',[0,EndTime-StartTime]);
SwTimesOneIdx=find(SwTimes(:,2)==1);
for i=1:length(SwTimesOneIdx)
    XY=[SwTimes(SwTimesOneIdx(i)-1,1),1;
       SwTimes(SwTimesOneIdx(i)-1,1),.15;
       SwTimes(SwTimesOneIdx(i),1),.15;
      SwTimes(SwTimesOneIdx(i),1),1;];
   patch(XY(:,1),XY(:,2),clrs{2});
%    plot([SwTimes(SwTimesOneIdx(i)-1,1);SwTimes(SwTimesOneIdx(i)-1,1);],[0,1],'r-','linewidth',2);
end
if onsetFlag
for i=1:length(OnsetTimesPlot)
   plot([OnsetTimesPlot(i),OnsetTimesPlot(i)],[0,1],'g-','linewidth',1.5);
end
end
% plot(TripTimes,TripRegister,'k-');
set(gca,'xlim',[0 xend],'ylim',[0,1.5])


%% Two Streams
subplot(2,1,2);hold on
ylabel('Segregated')
if ~isempty(TwoStrTimes)
histnorm(TwoStrTimes,2000);
end
set(gca,'xlim',[0,EndTime-StartTime]);
SwTimesTwoIdx=find(SwTimes(:,2)==2);
for i=1:length(SwTimesTwoIdx)
    XY=[SwTimes(SwTimesTwoIdx(i)-1,1),0.15;
       SwTimes(SwTimesTwoIdx(i)-1,1),1;
       SwTimes(SwTimesTwoIdx(i),1),1;
      SwTimes(SwTimesTwoIdx(i),1),0.15;];
   patch(XY(:,1),XY(:,2),clrs{1});
%    plot([SwTimes(SwTimesTwoIdx(i)-1,1);SwTimes(SwTimesTwoIdx(i)-1,1);],[0,1],'r-','linewidth',2);
end
if onsetFlag
for i=1:length(OnsetTimesPlot)
   plot([OnsetTimesPlot(i),OnsetTimesPlot(i)],[0,1],'g-','linewidth',1.5);
end
end
% plot(TripTimes,TripRegister,'k-');

set(gca,'xlim',[0 xend],'ylim',[0,1.5])
if 0
%% Ambiguous 
subplot(3,1,3);hold on
ylabel('Ambiguous')
if ~isempty(AmbStrTimes)
histnorm(AmbStrTimes,2000);
end
set(gca,'xlim',[0,EndTime-StartTime]);

SwTimesAmbIdx=find(SwTimes(:,2)==3);
SwTimesAmbIdx(1)=[];
for i=1:length(SwTimesAmbIdx)
    XY=[SwTimes(SwTimesAmbIdx(i)-1,1),0;
       SwTimes(SwTimesAmbIdx(i)-1,1),1;
       SwTimes(SwTimesAmbIdx(i),1),1;
      SwTimes(SwTimesAmbIdx(i),1),0;];
   patch(XY(:,1),XY(:,2),clrs{2});
   plot([SwTimes(SwTimesAmbIdx(i)-1,1);SwTimes(SwTimesAmbIdx(i)-1,1);],[0,1],'r-','linewidth',2);
end
if onsetFlag
for i=1:length(OnsetTimesPlot)
   plot([OnsetTimesPlot(i),OnsetTimesPlot(i)],[0,1],'g-','linewidth',1.5);
end
end

DurationsOne=Durations(Durations(:,2)==1,1);
DurationsTwo=Durations(Durations(:,2)==2,1);
mean(DurationsOne)
mean(DurationsTwo)
%    plot(TripTimes,TripRegister,'k-');
set(gca,'xlim',[0 xend],'ylim',[0,1])
end
end   