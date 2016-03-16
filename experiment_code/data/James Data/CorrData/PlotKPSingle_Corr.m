
global ifplot
ifplot=0;
ifexport=1;
% fnames={
% 'Sub013_REP1_ATCondP_prtDef_dB65_480x4x125ms_A10_B7_DF3_07Nov2014_150554';
% };

datadir='/home/jr3830/proj/auditory/codes/jran-as-expt/pilotdata/';
datadir='/home/jr3830/Insync/RankinExpt/CorrData/';

fnames=dir([datadir,'*DF5*']);fnames={fnames.name}
% exportdir='/home/jr3830/proj/auditory/talks/aro-bmore/mfigs/';
exportdir='/home/jr3830/proj/auditory/docs/2014-streaming-model/mfigs/';
exportdir='/home/jr3830/proj/auditory/abstracts/2016-CNS/mfigs/';

minDur=0.;
fnidx=length(fnames)
% 48

LabStrs={'\textbf{F}','\textbf{C}'};

fnames={fnames{fnidx}};
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

[SwTimes,Durations]=ExtractTimesHold(OneStrTimes,TwoStrTimes,AmbStrTimes,minDur);


return
%% Do some plotting
make_colors
clrs={blue,red,green};
xend=240.5;
OnsetTimesPlot=OnsetTimes;%-StartTime;
set(gca,'ytick',[0.25,0.75],'yticklabel',{'Seg','Int'});
set(gca,'fontname','arial','fontsize',14)
PresentationLengthInSeconds=240;
%% One Stream

[~,lastIdx]=max(SwTimes(:,1))
% if ~isempty(OneStrTimes)
% histnorm(OneStrTimes,2000);
% end
set(gca,'xlim',[0,xend]);
SwTimesOneIdx=find(SwTimes(:,3)==1);
for i=1:length(SwTimesOneIdx)
     if SwTimesOneIdx(i)==lastIdx
        break
    end
    XY=[SwTimes(SwTimesOneIdx(i),1),.5;
       SwTimes(SwTimesOneIdx(i),1),1;
       SwTimes(SwTimesOneIdx(i),2),1;
      SwTimes(SwTimesOneIdx(i),2),.5;];
   patch(XY(:,1),XY(:,2),clrs{1});
%    plot([SwTimes(SwTimesOneIdx(i)-1,1);SwTimes(SwTimesOneIdx(i)-1,1);],[0,1],'r-','linewidth',2);
end
if onsetFlag
for i=1:length(OnsetTimesPlot)
   plot([OnsetTimesPlot(i),OnsetTimesPlot(i)],[0,1],'g-','linewidth',1.5);
end
end


%% Two Streams
% if ~isempty(TwoStrTimes)
% histnorm(TwoStrTimes,2000);
% end
% set(gca,'xlim',[0,EndTime-StartTime]);

SwTimesTwoIdx=find(SwTimes(:,3)==2);
for i=1:length(SwTimesTwoIdx)
    if SwTimesTwoIdx(i)==lastIdx
        break
    end
    XY=[SwTimes(SwTimesTwoIdx(i),1),0;
       SwTimes(SwTimesTwoIdx(i),1),.5;
       SwTimes(SwTimesTwoIdx(i),2),.5;
      SwTimes(SwTimesTwoIdx(i),2),0;];
   patch(XY(:,1),XY(:,2),clrs{2});
%    plot([SwTimes(SwTimesTwoIdx(i)-1,1);SwTimes(SwTimesTwoIdx(i)-1,1);],[0,1],'r-','linewidth',2);
end
if onsetFlag
for i=1:length(OnsetTimesPlot)
   plot([OnsetTimesPlot(i),OnsetTimesPlot(i)],[0,1],'g-','linewidth',1.5);
end
end
% plot(TripTimes,TripRegister,'k-');

% text(-16,1.,LabStrs{j},'interpreter','latex','fontsize',16)
than=text(85,-0.26,'time (s)');
set(than,'fontname','arial','fontsize',14);
set(gca,'xlim',[0 xend],'ylim',[0,1])
set(gcf,'units','centimeters','position',[3,6,12,4]);
box on
set(gca,'xlim',[0 PresentationLengthInSeconds],'ylim',[-.05 1.05]);
set(gca,'fontname','helvetica','fontsize',15);
set(gca,'activepositionproperty','position');
set(gca,'position',[0.12,0.23,0.84,0.7]);
set(gca,'linewidth',2);set(gcf,'color','w');box on
set(gca,'xtick',0:40:240)
set(gcf,'renderer','painters')
exportname=['SingleTrial_Subj',keydata.SubjName,'.pdf'];
if ifexport
export_fig([exportdir,exportname],'-painters')
disp([exportdir,exportname])
end
end   