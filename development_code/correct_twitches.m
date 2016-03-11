% correct twitches:
% we will have 5 cases, with 3 different procedures.
% Int--> [Twitches] --> Int,      Tw -> Seg
% Seg--> [Twitches] --> Seg,      Tw -> Int      
%                                 Turn difference in SwTime from first to
%                                 last twitches into the opposite percept
% UNLESS length(Twitches) == 1, 
% then Remove Twitches, 
% Int 1 becomes Int1 + Int2 + Twitches, 
% remove Int2
% 
% IF
% Int --> [Twitches] --> Seg,     1/2 Tw Int, 1/2 Tw Seg
% Seg --> [Twitches] --> Seg,     1/2 Tw Seg, 1/2 Tw Int

%load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat')
clear;

cd ~/Dropbox/my' codes'/rinzel/development_code/
load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat')

% Later I'm going to need to figure out which trials from this data set
% match the DF=5 of the first one, and analyze the extra trials
% load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF1_NSJ8_NREPS5.mat');

% But first things first:
% At the end I'm going to want to save this into a new file with the
% variables DFvals, DurationsCell, NumCond, NumReps, NumSubj, and
% SwTimesCell

threshTwitch = 0.35;

DurationsCellOld = DurationsCell;
SwTimesCellOld = SwTimesCell;
for cInd = 1:NumCond
    for sInd = 1:NumSubj
        for rInd = 1:NumReps
            %
            %cInd = 1; sInd = 14; rInd = 1;
            DursTmp = DurationsCell{cInd,sInd,rInd};
            SwTmp = SwTimesCell{cInd,sInd,rInd};
            
            DursTmp = [0 0;DursTmp];
            DurSwitch = [ DursTmp, SwTmp];
            
            twitches = logical(DursTmp(2:end,1)<threshTwitch);
            
            if any(twitches)
                
                twitchDiff = [0; 0; diff(twitches)]; % 1 for on, -1 for off
                twitchDiff(2) = 0;
                % [twitchDiff DurSwitch]
                
                twitchOn = find(twitchDiff==1)-1; % inds of last durs before all twitches
                twitchOff = find(twitchDiff==-1); % inds of next durs after
                
                
                killRows = [];
                DurSwitchFixed = DurSwitch;
                % step through each twitch
                
                for twInd = 1:length(twitchOn)
                    
                    if twInd > length(twitchOff)
                        
                        foo = sum(DurSwitchFixed(twitchOn(end)+1:end,1));
                        
                        DurSwitchFixed = DurSwitchFixed(1:twitchOn(end),:);
                        
                        DurSwitchFixed(end,1) = DurSwitchFixed(end,1) + foo;
                        DurSwitchFixed(end,3) = DurSwitchFixed(end,3) + foo;
                        
                        continue
                    end
                    
                    
                    preInd = twitchOn(twInd); % ind of dur before this twitch
                    postInd = twitchOff(twInd); % ind of dur after this twitch
                    twitchTime = SwTmp(postInd-1,1) - SwTmp(preInd,1);
                    
                    if DursTmp(preInd,2) ~= DursTmp(postInd,2)
                        % split the difference, cut out the twitches
                        foo = twitchTime/2;
                        DurSwitchFixed(preInd,1) = DurSwitch(preInd,1)...
                            + foo;
                        DurSwitchFixed(postInd,1) = DurSwitch(postInd,1)...
                            + foo;
                        
                        DurSwitchFixed(preInd,3) = DurSwitch(preInd,3)...
                            + foo;
                            
                        
                        killRows = [killRows preInd+1:postInd-1];
                        % DurSwitchFixed(preInd+1:postInd-1,:) = [];
                        
%                         
%                         DurSwitchFixed
%                         DurSwitch
%                     
%                         keyboard
%                         
                    elseif DursTmp(preInd,2) == DursTmp(preInd,2)
                        
                        twitchLength = postInd - preInd;
                        
                        if twitchLength == 2
                            % append the pre and post duration, 
                            % get rid of twitches and post
                            foo = twitchTime + DurSwitch(postInd,1);
                            
                            DurSwitchFixed(preInd,1) = ...
                                DurSwitch(preInd,1) + foo;
                            
                            DurSwitchFixed(preInd,3) = ...
                                DurSwitch(preInd,3) + foo;
                            
                            
                            killRows = [killRows preInd+1:postInd];
                            % DurSwitchFixed(preInd+1:postInd,:) = [];
                            
%                             DurSwitchFixed 
%                             DurSwitch
%                             
                            %keyboard;
                            
                        else
                            % I have to create a new row corresponding to
                            % the twitch time 
                            if DursTmp(preInd,2) == 2, p = 1; end
                            if DursTmp(preInd,2) == 1, p = 2; end
                            
                            newRow = [twitchTime p SwTmp(preInd)+twitchTime p];
                            
                            DurSwitchFixed(preInd+1,:) = newRow;
%                              DurSwitchFixed
%                             DurSwitch
%                             
                            
                            %keyboard;
                            
                            killRows = [killRows preInd+2:postInd-1];
%                            DursSwitchFixed(preInd+2:postInd-1,:) = [];
                            
                        end
                        
                        
                    else
                        disp('Nothing happened!');
                    end
                    
                end
                
                DurSwitchFixed(killRows,:) = [];
%                 
%                 DurSwitchFixed
%                 DurSwitch
               % keyboard
                DurationsCell{cInd,sInd,rInd} = DurSwitchFixed(:,1:2);
                SwTimesCell{cInd,sInd,rInd} = DurSwitchFixed(:,3:4);
                
            end
            
        end
    end
end

%% save things correctly to work with previous code
newFilename = 'Corrected_8DF_15SJ_3REP.mat';
cd ../experiment_code/data/James' Data'/

save(newFilename, 'DFvals', 'DurationsCell', 'NumCond', 'NumReps',...
    'NumSubj','SwTimesCell');

