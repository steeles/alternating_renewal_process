%noise_adaptation

function [u1 u2 s1 s2 tax n1 n2 iboth] = SFA(pars,bPlot)

if ~exist('pars','var')
    Gamma = .3; 
    t_in_seconds = 30;
    timescale = .01;
    dt = .1;
else
    v2struct(pars);
end

time_units = t_in_seconds/timescale;
t_tot = time_units/dt;
tax = dt*timescale:dt*timescale:t_in_seconds;

Beta = 1; tau_a = 200; tau_n = 10;

iboth = ones(1,t_tot) * .6;
i1 = ones(1,t_tot)*0; i2 = ones(1,t_tot)*0;
sig = .0/sqrt(dt);
u1 = zeros(1,t_tot); u2 = zeros(1,t_tot);
u1(1) = .1;
a1 = zeros(1,t_tot); a2 = zeros(1,t_tot);
n1 = zeros(1,t_tot); n2 = zeros(1,t_tot);

for t = 1:t_tot-1
    a1(t+1) = a1(t) + dt/tau_a*(-a1(t) + u1(t));
    val1 = -Beta*u2(t) - Gamma*a1(t) +iboth(t) +i1(t) +n1(t);
    
    u1(t+1) = u1(t) + dt*(-u1(t) + f(val1));
    n1(t+1) = n1(t) + dt*(-n1(t)/tau_n + sig*sqrt(2/tau_n)*randn(1));
    
    a2(t+1) = a2(t) + dt/tau_a*(-a2(t) + u2(t));
    val2 = -Beta*u1(t) - Gamma*a2(t) +iboth(t) +i1(t) +n1(t);
    u2(t+1) = u2(t) + dt*(-u2(t) + f(val2));
    n2(t+1) = n2(t) + dt*(-n2(t)/tau_n + sig*sqrt(2/tau_n)*randn(1));
    
end

if 1
    figure; plot(tax,u1,tax,u2,tax,a1,tax,a2)
end

function Fu = f(u)
k = 0.1; theta = 0.5;

% if size(u)==1
Fu = 1/(1+exp(-(u-theta)/k));
% else
% Fu = 1./(1+exp((theta-u)./k));
% end
    