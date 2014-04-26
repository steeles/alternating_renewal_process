function StTripNtrials
% Steady Triplet Ntials records durations for ncon=number of conditions,
% say DF values; condition index: kc.  The 'identity' of the kc-th
% condition for a trial
% is in kc-th col of the matrix indcond:  eg suppose we are running 3 conditions (ncon=3), then on the
% kt-th trial the row indcond(kt,:) has the identities for the 3
% conditions. Say, if we are running 3 different values of DF: the 3 cols
% of indcond(kt,:) for trial kt might be (2, 8, 5) for the DF values of 2, 8, 5.
% We must define the mapping for result(kc).data, say for kc=1 we put all
% durations for DF=2; for kc=2 we store durations for DF=5; for kc=3,
% durations for DF=8.
%
% There will be numtrial for each condition; trial index: kt.   
%  Do it in groups:
%   Trial 1: for ncon  conditions
%   Trial 2: for ncon  conditions
%    ...
%   Trial numtrial: for ncon conditions
% store results in the Structure:  result has ncon components
%   result.names   subj ID&date&condition param and numtrials  ... maybe repeated numtrial times
%   result.params  params common and specific to the conditions
%   result.data   concatenate the durations over trials for each condition.
%
%  the sound sequence for each trial/cond are pregenerated and just read in
%  here.
%  There is 20 sec pause btw runs (and after 'space bar', a brief warning beep then 2 sec then start run;  
%  and 60 sec pause after "Subject Done" to allow for writing of 'result'
%
global result txt_subjdate;
fs = 44100; r = 1e-1;warningdur=3;
dt=1/fs;t=[dt:dt:warningdur]'-dt;warning=r*sin(2*pi*800*t);
APwarning=audioplayer(warning,fs);
% identify the subject and conditions and numtrials
%txt_subjdate='10.23.06.2011_3DF_2trl';
%txt_subjdate='04.14.10.2011_DF37_3trl';
%txt_subjdate='01.28.10.2011_DF37_2trl';
txt_subjdate='testing StTripNtrials2';
ncon=1;numtrial=5;
%ncon=1;numtrial=2;
for k=1:ncon;result(k).names=txt_subjdate;end;
Tdur=120;gap=120;repeats=40;
%%Tdur=120;gap=120;repeats=50;
%result(condn).params=[Tdur repeats indL indH gap condn# or DF];
result(2).params=[Tdur repeats 6 2 gap 4];
result(3).params=[Tdur repeats 9 4 gap 5];
result(4).params=[Tdur repeats 12 6 gap 6];
result(1).params=[Tdur repeats 8 5 gap 3];
result(5).params=[Tdur repeats 10 3 gap 7];
result(6).params=[Tdur repeats 7 5 gap 2];
result(7).params=[Tdur repeats 11 3 gap 8];

%
% randomize cond ordering (and across subjects) from one trial to the next
%
% set up the trials (each row of indcond is a trial) and load pre-generated sound sequences
%
%indcond=[4 5 6; 5 6 4; 6 4 5;4 6 5];
%%indcond=[4;4;4;4];
indcond=[3 7; 3 7; 3 7;3 7];
%indcond=[2 8; 2 8; 2 8;2 8];
%indcond=[3 7];
%%indcond=[4 7 5 3 6];
%%steadyseq4=load('testseqshortDF4.mat')
steadyseq3=load('HLHdf3seq.mat')
steadyseq7=load('HLHdf7seq.mat')
steadyseq4=load('HLHdf4seq.mat')
steadyseq5=load('HLHdf5seq.mat')
steadyseq6=load('HLHdf6seq.mat')
steadyseq2=load('HLHdf2seq.mat')
steadyseq8=load('HLHdf8seq.mat')
% steadyseq4=load('HLHdf4shseq.mat')
% steadyseq5=load('HLHdf5shseq.mat')
% steadyseq6=load('HLHdf6shseq.mat')
for k=1:ncon;result(k).data=[];result(k).rawdata=[]; end;
figure (444); clf;
uicontrol('style','text','string','Response Window','fontsize',20,...
   'units','normalized','position',[.1,.6,.8,.2]);
uicontrol('style','text','string','To initiate session hit spacebar.','fontsize',14,...
   'units','normalized','position',[.1,.5,.8,.2]);
uicontrol('style','text','string','Subject: hold down leftarrow key for one stream, rightarrow for two.','fontsize',14,...
   'units','normalized','position',[.1,.4,.8,.2]);
drawnow;
while ~ waitforbuttonpress; end;

for kt=1:numtrial
    for kc=1:ncon
        condid=indcond(kt,kc);
        clear global KeyPresses;global KeyPresses;
        global prevleft; global prevright;
        prevleft=0;prevright=0;  
        set(gcf,'KeyPressFcn', {@KeyRecorder,'Down'}); 
        set(gcf,'KeyReleaseFcn', {@KeyRecorder,'Up'});
      if condid==3 AP=audioplayer(steadyseq3.steadyseq,fs);end;
%%    if condid==4 AP=audioplayer(steadyseq4.testseqshortDF4,fs);end;
      if condid==4 AP=audioplayer(steadyseq4.steadyseq,fs);end;
      if condid==5 AP=audioplayer(steadyseq5.steadyseq,fs);end;
      if condid==6 AP=audioplayer(steadyseq6.steadyseq,fs);end;
      if condid==7 AP=audioplayer(steadyseq7.steadyseq,fs);end;
      if condid==2 AP=audioplayer(steadyseq2.steadyseq,fs);end;
      if condid==8 AP=audioplayer(steadyseq8.steadyseq,fs);end;

      pause(20);
%%      pause(5);
      play(APwarning);while isplaying(APwarning)pause(0.1);end;pause(2);
      play(AP)
% this next "while" prevents program from proceeding until play(AP) is complete
       while isplaying(AP)
    %& ~ waitforbuttonpress
       pause(0.1); end;
 %   end
%%% JR... is this "clear playsnd" doing anything?
    clear playsnd
      KPsfname=strcat(txt_subjdate,'.mat');
      save(KPsfname,'KeyPresses');
      result(kc).rawdata=[result(kc).rawdata;KeyPresses];
      perceptdurns=KPushETs;
      result(kc).data=[result(kc).data;perceptdurns];     
    end;
    txt_trial=strcat('trial #',num2str(kt)','of',num2str(numtrial),'is done. Do NOT terminate code.')
      uicontrol('style','text','string',txt_trial,'fontsize',14,...
   'units','normalized','position',[.1,.2,.8,.2]); drawnow; 
%%
    pause(5);  % for short durn trials/testing
  %  pause(60); % for long durn trials/sessions
end
    resultfname=strcat(txt_subjdate,'.mat');
    save(resultfname,'result');
    uicontrol('style','text','string','Session done. OK to terminate code.','fontsize',14,...
   'units','normalized','position',[.1,0.1,.8,.2]);drawnow;
end
