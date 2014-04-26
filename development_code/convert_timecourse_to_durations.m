function [T1 T2] = convert_timecourse_to_durations(u1,u2,tax)


u1_timecourse = u1>u2;
% now I'm going to set the labels to always label the first duration the
% first p1 duration
if u1_timecourse(2)~=1
    u1_timecourse=u2>u1;
end


dt = mean(diff(tax));
switches = diff(u1_timecourse);



switch_to_p1 = find(switches==1)*dt;
switch_to_p2 = find(switches==-1)*dt;

switch_to_p1 = switch_to_p1(1:length(switch_to_p2));
switch_to_p2 = switch_to_p2(1:length(switch_to_p1));


% 
% for swInd = 1:length(switch_to_p1)-1%+length(switch_to_p2)-1
%     T1(swInd) = (switch_to_p2(swInd)-switch_to_p1(swInd));
%     T2(swInd) = (switch_to_p1(swInd+1)-switch_to_p2(swInd));
% end


T1 = switch_to_p2(1:end-1) - switch_to_p1(1:end-1);
T2 = switch_to_p1(2:end) - switch_to_p2(1:end-1);
len = length(T1);
figure; subplot(211); hist(T1); subplot(212); hist(T2)


% now I can convert to canonical durs thingie
PTimes = reshape([T1;T2],1,length(T1)*2)';
Labels = reshape([ones(1,length(T1));2*ones(1,length(T1))],1,length(T1)*2)';

PTimes(1:2:len*2-1)=T1;
PTimes(2:2:2*len) = T2;

durs = [PTimes/1000 Labels];

% figure; 
% myacf = acf(PTimes,4);