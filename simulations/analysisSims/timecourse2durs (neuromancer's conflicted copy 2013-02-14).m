% [T1 T2] = timecourse_to_durs(u1,u2,tax)
% added 8/16/2012 by sara steele 
% T1 is taken to be the durations of events in a system that switches
% between two states, those corresponding to the state entered first (T1)
% T2 contains the durations of the state which occurs second ( and
% subsequently throughout the trial )

function [T1 T2 durs u1_timecourse T1_end T2_end] = timecourse2durs(u1,u2,tax,bPlot)


% firstu1 = find(u1>u2, 1 ); firstu2 = find(u2>u1, 1 );
% 
%     
% % now I'm going to set the labels to always label the first duration the
% % first p1 duration
%   % convert to binary representation
%   % eliminate any 0 entries in beginning
% if firstu1<firstu2 || isempty(firstu2)
    u1_timecourse = u1<u2;      % mark first event with zeros
%     u1_timecourse = [zeros(1,firstu1-1) u1_timecourse(firstu1:end)];
%     
% else
%     u1_timecourse = u2<u1;
%     u1_timecourse = [zeros(1,firstu2-1) u1_timecourse(firstu2:end)];
%     disp('Reversed T1 and T2 identities from timecourse designations')
%     figure; plot([dt:dt:10],u1_timecourse(1:10/dt));
% end


dt = mean(diff(tax));

if exist('bPlot','var') && bPlot == 1
    figure; title('Input binary timecourse')
    plot(tax,u1_timecourse);
end

if u1_timecourse(end)==0
    u1_timecourse(end)=1;
    bEnd_is_integrated = 1;
elseif u1_timecourse(end)==1
    u1_timecourse(end)=0;
    bEnd_is_integrated = 0;
else
    error('oh jeez, timecourse2durs')
end



switches = [-1 diff(u1_timecourse)];

if bEnd_is_integrated
    switches(end)=1;
else
    switches(end)=-1;
end



switch_to_p1 = find(switches==-1)*dt;
switch_to_p2 = find(switches==1)*dt;

if switch_to_p1(end)~= tax(end) && switch_to_p2(end)~=tax(end)
    disp(switch_to_p1)
    disp(switch_to_p2)
    error('whoops...')
end
%figure out which event occurs last


% if max([switch_to_p1 switch_to_p2]) == switch_to_p1(end)
%     switch_to_p2(end+1) = length(u1_timecourse)*dt; % make last timepoint
%     
% % else
% %     switch_to_p1(end+1) = length(u1_timecourse)*dt;
%     
% end

% switch_to_p1 = switch_to_p1(1:length(switch_to_p2));
% switch_to_p2 = switch_to_p2(1:length(switch_to_p1));


        % I believe this should eliminate hte final state, which should be ignored
        % as it is necessarily truncated from the end of the trial
% *ABOVE IS GOOD FOR ESTIMATING GAMMA PARS, BAD FOR BUFs*
% solution: pack only full dom durs into T1 & T2, but include last
% (incomplete) dom dur in durs;

T1=[]; T2 = []; durs = [];
for swInd = 1:length(switch_to_p1)-1%+length(switch_to_p2)-1
    t1val = (switch_to_p2(swInd)-switch_to_p1(swInd));
    T1(swInd) = t1val;
    durs(swInd*2-1,:) = [t1val 1];
    
    t2val = (switch_to_p1(swInd+1)-switch_to_p2(swInd));
    T2(swInd) = t2val;
    durs(swInd*2,:) = [t2val 2];
end


if bEnd_is_integrated
 %   T1(end)=[];
    durs = [durs; switch_to_p2(end) - switch_to_p1(end), 1];

    %if length(durs)<=2
        T1_end = switch_to_p2(end) - switch_to_p1(end);
        T2_end = [];
        
        %disp('using some truncated dur1s')
    %end
    
else
%elseif length(durs)>3
    T2_end = T2(end); T2(end) = [];
    T1_end = [];
end



    
    

% 
% T1 = (switch_to_p2(1:end-1) - switch_to_p1(1:end-1));
% T2 = (switch_to_p1(2:end) - switch_to_p2(1:end-1));
%len = length(T1);


if exist('bPlot','var') && bPlot == 1
    figure; mk_Nice_Hist([T1 T2]);
end
% 
% % now I can convert to canonical durs thingie
% PTimes = reshape([T1;T2],1,length(T1)*2)';
% Labels = reshape([ones(1,length(T1));2*ones(1,length(T1))],1,length(T1)*2)';
% % 
% % PTimes(1:2:len*2-1)=T1;
% % PTimes(2:2:2*len) = T2;
% 
% durs = [PTimes Labels; finalDur];

% figure; 
% myacf = acf(PTimes,4);