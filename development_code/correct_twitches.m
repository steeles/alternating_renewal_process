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

clear;

cd ~/Dropbox/my' codes'/rinzel/development_code/

%load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF8_NSJ15_NREPS3.mat');
%newFilename = 'Corrected_15SJ_3REP.mat';


 load('/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/SwitchTimes_NDF1_NSJ8_NREPS5.mat');
 newFilename = 'Corrected_8SJ_5REP.mat';

% Later I'm going to need to figure out which trials from this data set
% match the DF=5 of the first one, and analyze the extra trials

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
            % cInd = 8; sInd = 7; rInd = 2;
            DursTmp = DurationsCell{cInd,sInd,rInd};
            SwTmp = SwTimesCell{cInd,sInd,rInd};
            
            if DursTmp(1,2)==3
                DursTmp(2,1) = sum(DursTmp(1:2,1));
                DursTmp = DursTmp(2:end,:);
                SwTmp = SwTmp(2:end,:);
            end
            
            DursTmp = [0 0;DursTmp];
            DurSwitch = [ DursTmp, SwTmp];
            
            twitches = logical(DursTmp(2:end,1)<threshTwitch);
            DurSwitchFixed = DurSwitch;
            
            if any(twitches)
                % only one entry in twitches and it's a 1; trial is all Seg
                if twitches == 1
                    DurSwitchFixed(3,:)=[240-(SwTmp(1,1)+DursTmp(2,1)) 2 240 2];
                    %DurSwitch
                    if any(DurSwitchFixed(3:end,1)<threshTwitch)
                        error('a twitch got through!')
                    end
                    DurationsCell{cInd,sInd,rInd} = DurSwitchFixed(:,1:2);
                    SwTimesCell{cInd,sInd,rInd} = DurSwitchFixed(:,3:4);
                    continue                    
                end
                
                twitchDiff = [0; 0; diff(twitches)]; % 1 for on, -1 for off
                twitchDiff(2) = 0;
                % [twitchDiff DurSwitch]
                
                twitchOn = find(twitchDiff==1)-1; % inds of last durs before all twitches
                twitchOff = find(twitchDiff==-1); % inds of next durs after
                
                if ~isempty(twitchOff) && twitchOff(1) <= twitchOn(1) % if we start with a twitch,
                    twitchOff = twitchOff(2:end); % ignore it!
                end
                
                killRows = [];
                
                % step through each twitch
                
                for twInd = 1:length(twitchOn)
                    
                    if twInd > length(twitchOff)
                        % if we end in the "on" position, both buttons
                        % pressed down, stop at the last percept
                        
                        DurSwitchFixed = DurSwitchFixed(1:twitchOn(end),:);
                        continue % should spit us out of twInd loop
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
                            
%                             DurSwitchFixed 
%                             DurSwitch
%                           
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
                            killRows = [killRows preInd+2:postInd-1];
%                           
                        end
                    else
                        disp('Nothing happened!');
                    end
                    
                end
                
                DurSwitchFixed(killRows,:) = [];
               
            end
            
            if any(DurSwitchFixed(3:end,1)<threshTwitch)
                error('a twitch got through!')
            end
            DurationsCell{cInd,sInd,rInd} = DurSwitchFixed(:,1:2);
            SwTimesCell{cInd,sInd,rInd} = DurSwitchFixed(:,3:4);
            
        end
    end
end

%% save things correctly to work with previous code

cd '/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/';

save(newFilename, 'DFvals', 'DurationsCell', 'NumCond', 'NumReps',...
    'NumSubj','SwTimesCell');

