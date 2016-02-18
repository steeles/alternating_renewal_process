% generate 



function durs = make_autocorrelated_durs(k,th,n,bPlot,r,decay)

if ~exist('k','var'), k = 3; end
if ~exist('th','var'), th = 2; end          %pars for generating distr
if ~exist('n','var'), n= 10000; end
if ~exist('r','var'), r = 4; end            % corr factor
if ~exist('decay','var'), decay = 2; end    % memory factor
if ~exist('bPlot','var'), bPlot = 0; end


durs = [];
durs(1) = gamrnd(k,th);

lf = 1-(exp(-k*th/r)); % lead factor; numbers get added to this and then that sum gets used to scale gamma draws

memfilt = 1;

for ind = 1:n-1
            %mod lead factor to keep mean, ie avg scale = 1    % some scale factor that's smaller when arg is larger
            
   % let's construct a memory filter type deal... contribution from previous durs 
   % gets weaker and weaker. [i think there's going to be some kind of
   % buildup here so that the means are gonna shrink as there's more
   % "history"
   % weighted average of durs so far goes into negative exp
   
   
   durs(ind+1) = (lf+exp(-dot(durs,memfilt)/r)) * gamrnd(k,th);
   memfilt = [memfilt/decay 1];
   
end

durs = durs';
if bPlot
    

    plot(durs)
    histfit(durs,20,'gamma')
    [g ci]= gamfit(durs); [h p] = goodness_of_gamma_fit(durs,g)
    
    acf(durs,5)
    
end