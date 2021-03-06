% test code replicating Shpiro et al 2008 "Balance between noise and
% adaptation"
% there's something tricky with time- she took one time step to be 10 ms
% and a dt of .1, so t_tot is in milliseconds but the operations carried
% out in the diffeq's are based on a .01 s timescale, eg multiply by
% dt=0.1, not dt=.001 or dt of 1 (if simulation was carried out in ms
% timescale). But, tax comes out as t in seconds.
%
% pars = struct('Gamma',.1,'Delta',0,'iboth',.6,'SFA',1,'SD',0,'sig',.12)
% [u1 u2 s1 s2 tax n1 n2 iboth] = noise_adaptation(pars,bPlot)

function [u1 u2 s1 s2 tax n1 n2 iboth] = noise_adaptation(pars,bPlot)




% 
% I'm going to try to translate the above from the paper
% 
% For each set of parameters tested, we calculate 5000 s time courses of
% the models? behavior, which allows for at least 250 switches in 
% dominance, and obtain the time series of the dominance durations for each
% set of the models? parameters. 


% t_in_seconds = 500;
% dt = .001;
% t_tot = t_in_seconds/dt;
% tax = dt:dt:t_in_seconds;


tau_neur = 1;
tau_slow = 200; % 2 sec real time
tau_noise = 10; % 0.1 sec real time
 

if ~exist('pars','var') || isempty(pars)
    t_in_seconds = 500;
    
    timescale = .01;                % 10 ms timescale of neural processes
    timesteps = t_in_seconds/timescale;
    dt = .1; % for some reason dt is .1 of the timescale, eg 1 ms
    t_tot = timesteps/dt;
    tax = dt*timescale:dt*timescale:t_in_seconds;
    
    Gamma = .3; Delta = 1.5; 
    iboth = ones(1,t_tot) * .6;
    i1 = 0; i2 = 0; %i1 = -.05; i2 = .1;
    SFA = 1;
    SD = 0;
    if SFA
        sig = .12/sqrt(dt);
    else
        sig = .02/sqrt(dt);
    end
    
    
else
    
    t_in_seconds = pars.t_in_seconds;
    
    timescale = .01;                % 10 ms timescale of neural processes
    timesteps = t_in_seconds/timescale;
    dt = .1; % for some reason dt is .1 of the timescale, eg 1 ms
    t_tot = timesteps/dt;
    tax = dt*timescale:dt*timescale:t_in_seconds;
    
    
    Gamma = pars.Gamma; Delta = pars.Delta; sig = pars.sig/sqrt(dt);
    iboth = ones(1,t_tot) * pars.iboth;
    SFA = pars.SFA; SD = pars.SD;
    
    i1 = pars.i1; i2 = pars.i2;
end
if ~exist('i1','var')
    i1 = 0;
end
if ~exist('i2','var')
    i2 = 0;
end




if SFA && ~SD, 
    Beta = 1;
elseif SD && ~ SFA
    Beta = 0.75;
else
    error('Choose SD or SFA')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pars to vary
% Gamma = .3; Delta = 1.5; sig = .120;
% iboth = ones(1,t_tot) * .6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

u1 = zeros(1,t_tot); u2 = zeros(1,t_tot);
%%%%%%%%%%%%
% hard code the first percept
u1(1:10) = 1;
% slow process- either a or d
s1 = zeros(1,t_tot); s2 = [zeros(1,t_tot)];
n1 = zeros(1,t_tot); n2 = zeros(1,t_tot);
%s1(1) = .1;

for t = 1:t_tot-1

    if SFA
        
        s1(t+1) = s1(t) + dt/tau_slow * (-s1(t) + u1(t));
        s2(t+1) = s2(t) + dt/tau_slow * (-s2(t) + u2(t));
        
        val1 = -Beta*u2(t)-Gamma*s1(t)+iboth(t)+n1(t)+i1;
        val2 = -Beta*u1(t)-Gamma*s2(t)+iboth(t)+n2(t)+i2;
        
        u1(t+1) = u1(t) + dt/tau_neur * (-u1(t)+f(val1));
        u2(t+1) = u2(t) + dt/tau_neur * (-u2(t)+f(val2));
    else
        % I'm trying a change to minus in end parentheses after 2007 paper
        % description of LC-synaptic depression
        s1(t+1) = s1(t) + dt/tau_slow * (1-s1(t)-Delta*s1(t)*u1(t));
        s2(t+1) = s2(t) + dt/tau_slow * (1-s2(t)-Delta*s2(t)*u2(t));
        
        val1 = -Beta*u2(t)*s2(t) + iboth(t) + n1(t);
        val2 = -Beta*u1(t)*s1(t) + iboth(t) + n2(t);
        
        u1(t+1) = u1(t) + dt/tau_neur * (-u1(t)+f(val1));
        u2(t+1) = u2(t) + dt/tau_neur * (-u2(t)+f(val2));
        
    end
    n1(t+1) = n1(t)+dt*(-n1(t)/tau_noise+sig*sqrt(2/tau_noise)*randn(1));
    n2(t+1) = n2(t)+dt*(-n2(t)/tau_noise+sig*sqrt(2/tau_noise)*randn(1));
    %iboth(t+1) = iboth(t) + .000003;
end

if exist('bPlot','var') && bPlot==1
    plot(tax,u1,tax,u2);
    
    if SFA
        tit = ['I=' num2str(mean(iboth)) ',G=' num2str(Gamma) ];
    else
        tit = ['I=' num2str(mean(iboth)) ',d=' num2str(Delta) ];
    end
    
    title(tit);
    cd ~/Dropbox/my' codes'/rinzel/simulations/
    print('-depsc', [tit '.eps'])
end

function Fu = f(u)
k = 0.1; theta = 0;

% if size(u)==1
Fu = 1/(1+exp(-(u-theta)/k));
% else
% Fu = 1./(1+exp((theta-u)./k));
% end
    