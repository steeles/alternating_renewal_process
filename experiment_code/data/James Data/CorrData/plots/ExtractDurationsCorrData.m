

global ifplot
ifplot=0;
ifexport=0;

savedir='/home/jr3830/Insync/RankinExpt/CorrData/plots/';
datadir='/home/jr3830/Insync/RankinExpt/CorrData/';
subjStrs={
%     '009',...
    '001',...
    '002',...
    '003',...
    '004',...
    '005',...
    '006',...
    '007',...
    '008'
};


%% 001 DF
% subjStr='004';
DFvals=[5];
% DFvals=[1,2,3,5,7,9,11,15];

SwTimesCell={};
DurationsCell={};
minDur=0.25;
Tmin=0.25;
Tmax=240;
fstflag=0;

NumReps=5;
NumSubj=length(subjStrs);
NumCond=length(DFvals);

NumberMaxRejects=0;
for i=1:length(DFvals)
%     maxDur=240;
    DurOneStruct={};
    DurTwoStruct={};
    for j=1:length(subjStrs)
        subjStr=subjStrs{j};
        
        FileNameList=dir([datadir,'Sub',subjStr,'*DF',num2str(DFvals(i)),'_*']);  FileNameList={FileNameList.name};
        for k=1:length(FileNameList)
            fname=FileNameList{k};
            [SwTimes,Durations]=ProcessKPDataOrdered(fname,datadir,minDur);
            [DurOneAll,DurTwoAll,DurAmbAll,DurFstAll,DurScdAll]=ProcessKPDataThree({fname},datadir,minDur,fstflag);
%         
            SwTimesCell{i,j,k}=SwTimes;
            DurationsCell{i,j,k}=Durations;
        end
    
    end
    
end
tmp=DurationsCell{1,4,2}
hist(tmp(:,1),100)

DursTmp=DurationsCell{1,4,2}
SwTmp=SwTimesCell{1,4,2}
TwitchIdx=find(DursTmp<minDur+0.1)
SwTmp(TwitchIdx)
numel(DursTmp(TwitchIdx))
return

savename=['SwitchTimes_NDF',num2str(length(DFvals)),...
    '_NSJ',num2str(length(subjStrs)),...
    '_NREPS',num2str(NumReps)];

save([savedir,savename,'.mat'],'DFvals',...
    'NumReps','DurationsCell','SwTimesCell','NumSubj','NumCond');
    disp([savedir,savename,'.mat'])
