function [perceptdurns] = KPushETs
% get the KeyPresses and compute PerceptDurns
global result fname;
KPsfname=strcat(fname,'.mat');
%KPsfname=strcat(txt_subjdate,'.KPs.mat');
%load('KPsinBRec.mat');
load(KPsfname);
KeyPresses;
if isempty(KeyPresses)
    KeyPresses = cell(2,1); 
    KeyPresses{1} = struct('Down',[],'Up',[]);
    KeyPresses{2} = struct('Down',[],'Up',[]);
end
perceptdurns=zeros(1,2);
% ets for 1 stream
if isempty(KeyPresses{1}.Up)
    KeyPresses{1}.Up=zeros(1,6);
    KeyPresses{1}.Down=zeros(1,6);
    'KeyPresses for Percept 1 was empty'
end
if isempty(KeyPresses{2}.Up)
    KeyPresses{2}.Up=zeros(1,6);
    KeyPresses{2}.Down=zeros(1,6);
    'KeyPresses for Percept 2 was empty'
end
numdur1=length(KeyPresses{1}.Up(:,1));
numdur2=length(KeyPresses{2}.Up(:,1));
kalign=1;
for k=1:numdur1;
    delt=etime(KeyPresses{1}.Up(k,:),KeyPresses{1}.Down(kalign,:));
    if delt>0
    durns=[delt 1.];
    perceptdurns= vertcat(perceptdurns,durns);kalign=kalign+1;
    else 'a negative duration, Percept #1'
    end
end
kalign=1;
for k=1:numdur2;
    delt=etime(KeyPresses{2}.Up(k,:),KeyPresses{2}.Down(kalign,:));
    if delt>0
    durns=[delt 2.];
    perceptdurns= vertcat(perceptdurns,durns);kalign=kalign+1;
    else 'a negative duration, Percept #2'
    end
end
