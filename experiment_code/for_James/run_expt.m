% outer code for streaming experiment to generate necessary stimuli,
% parameter structures and filenames for experimental runs
%
% major function calls include StTripNtrials_SS and SteadyTripSeq
% SS 7/15/2012
% run_expt(numtrial,dfConds,Tdur,gap,repeats,subjID)

function pars = run_expt(varargin)

cd ~/Dropbox/my' codes'/rinzel/experiment_code/for_James/stimfiles/

if nargin==0
    subjID = 'XX';
    dfConds = [4];   % which DF conditions should be used
    ncon = length(dfConds);
    Tdur = 125; gap = 125; repeats = 40;
    numtrial = 100;
end
if nargin == 1
    numtrial = varargin{1};    
    dfConds = [4 5];   % which DF conditions should be used
    ncon = length(dfConds);
    Tdur = 125; gap = 125; repeats = 40;
    subjID = 'XX';
end
if nargin ==2
    numtrial = varargin{1};
    dfConds = varargin{2};   % which DF conditions should be used
    ncon = length(dfConds);
    Tdur = 125; gap = 125; repeats = 40;
    subjID = 'XX';
end
if nargin==6
    numtrial = varargin{1};
    dfConds = varargin{2};   % which DF conditions should be used
    ncon = length(dfConds);
    Tdur = varargin{3}; 
    gap = varargin{4}; 
    repeats = varargin{5};
    subjID = varargin{6};
end

for n = 1:ncon
    df = dfConds(n);
    switch df
        case 3
            indA = 8; indB = 5;
        case 4
            indA = 6; indB = 2;
        case 5
            indA = 9; indB = 4;
        case 6
            indA = 12; indB = 6;
        case 7
            indA = 10; indB = 3;
        case 8
            indA = 11; indB = 3;
    end
    
    filename = [num2str(df) '.' num2str(Tdur) '.' num2str(repeats)...
        '.' num2str(gap) '.' num2str(indA) '.' num2str(indB) '.mat'];
    
    stimfiles{n} = filename;
    if ~exist(stimfiles{n},'file')
        tones = Tones(Tdur);
        stseq = SteadyTripSeq(tones,indA,indB,gap,repeats);
        save(filename,'stseq')
    end
end

tmp = clock; 
fname = [num2str(tmp(1)) '.' num2str(tmp(2)) '.' num2str(tmp(3)) ...
    '.' num2str(tmp(4)) '.' num2str(tmp(5)) '.' num2str(numtrial) 'trl' 'DF='];
for n = 1:ncon
    fname = strcat(fname,num2str(dfConds(n)));
end

pars = v2struct(numtrial,dfConds,ncon,stimfiles,fname,Tdur,gap,repeats);

StTripNtrials_SS(pars)
                
%                 
%                 %%result(2).params=[Tdur repeats 6 2 gap 4];
% result(3).params=[Tdur repeats 9 4 gap 5];
% result(4).params=[Tdur repeats 12 6 gap 6];
% result(1).params=[Tdur repeats 8 5 gap 3];
% result(5).params=[Tdur repeats 10 3 gap 7];
% result(6).params=[Tdur repeats 7 5 gap 2];
% result(7).params=[Tdur repeats 11 3 gap 8];
                
            

