%dom_dur_2_distrs Steeles January 23 2012
function dom_dur_2_distrs(g1,g2)
%clear all

% experimental parameters
nTrials = 400;
nSwitches = 32; % must be even! closest way to control trial time; sets number of random durations to draw
time_Step = .1;

% Gamma distribution parameters-
% think about best way to store gam pars;
% g1.shape=2;
% g1.scale=2;
% 
% g2.shape=5;
% g2.scale=2;

if ~exist('g1','var')
    g1 = [2;2]; g2 = [5;2];
end

% Now I generate the dominance durations from each distribution for
% nSwitches/2 samples on each of nTrials
Durs1=gamrnd(g1(1),1/g1(2),1,nTrials*nSwitches/2);
% make sure I'm generating the distr's I want to be; if you're not
% troubleshooting you can comment this out
%figure; subplot(2,2,1); hist(Durs1); axis([0 60 0 nTrials*nSwitches/5])

% dominance durations for percept 2
Durs2=gamrnd(g2(1),1/g2(1),1,nTrials*nSwitches/2);
% another reality check
%subplot(2,2,3); hist(Durs2); axis([0 60 0 nTrials*nSwitches/5])

% I have to shuffle these up to get them to switch between distrs of
% durations on each trial
Durs=[Durs1;Durs2];
Durs=reshape(Durs,nSwitches,nTrials);
Durs=Durs';

% if i look at the columns I'll be using for percept 1 do i get the
% expected distr of durations?
%subplot(2,2,2); hist([Durs(:,1);Durs(:,5);Durs(:,9)])
% and again; another reality check, you can comment these out
%subplot(2,2,4); hist([Durs(:,2);Durs(:,6);Durs(:,10)])


% now we're going to turn those into their percepts over a fixed time
% interval- the duration of the shortest trial will be the cutoff to trim
% each trial's perceptual timecourse vector to a standard size
trialTime=min(sum(Durs,2));
cutoff=floor(trialTime/time_Step); % want to make sure we don't have
percepts(nTrials,cutoff)=0;         % shorter timecourse vecs than percept mtx


for ind=1:nTrials
    
    timecourse=[];
    for sw=1:nSwitches
        if mod(sw,2)==1 
            timecourse=[timecourse zeros(1,ceil(Durs(ind,sw)/time_Step))];
        else    %using ceil to avoid roundoff errors affecting dimension of the mtx
            timecourse=[timecourse ones(1,ceil(Durs(ind,sw)/time_Step))];
        end
    end
    
    timecourse=timecourse(1:cutoff);

    percepts(ind,:)=timecourse;

end
% this will generate an error, but matlab seems to handle it just fine
 plot((1:cutoff/5)*time_Step,...
    sum(percepts(:,1:(cutoff/5))/nTrials))
xlabel('time (s)')
ylabel('Probability of segregation')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now I will try to recover the pars for the 2 gam distrs- output in
% command window should be a 2 vector with g(1)=alpha or the "shape"
% parameter and g(2)=1/theta, or the inverse of the "scale" parameter

% 
% g1_mean=mean(Durs1);
% g1_var=sum((Durs1-g1_mean).^2)/(length(Durs1)-1);
% 
% beta = g1_mean/g1_var;
% alpha = g1_mean*beta;
% 
% [g1 fval exitFlags] = fminsearch(@gam_Likelihood,[alpha; beta],...
%     [],Durs1);
% 
% g2_mean=mean(Durs2);
% g2_var=sum((Durs2-g2_mean).^2)/(length(Durs2)-1);
% 
% beta2 = g2_mean/g2_var;
% alpha2 = g2_mean*beta2;
% 
% 
% 
% [g2 fval exitFlags] = fminsearch(@gam_Likelihood,[alpha2; beta2],...
%     [],Durs2);
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%
% % the scale parameter (theta) is reparameterized to 1/theta for the
% % likelihood calculation. 
% function error = gam_Likelihood(g,x)
% 
% LogLik = g(1)*log(g(2))-log(gamma(g(1)))...
%     + (g(1)-1).*log(x)-g(2).*x;
% error = -(sum(LogLik));
