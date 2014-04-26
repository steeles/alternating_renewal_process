% LC spike fq adaptation model (like Shpiro et al 2007, eq 4)
% by Sara Steele
% characterized as a -subtractive- slow process eg term -beta*u2-g*a1


function [u1 u2 tax a1 a2] = binocular_rivalry_anim_LCsfa

% alex asked an excellent question- where's the stochasticity?

%nullcline animation

%basic parameters

taua = 100;
beta = 0.9;
g = 1;
iboth=0.0;
%NOTE: for i1=0.8 and i2=0.2, nullclines intersect but no oscillations?
i1=0.4;
i2=0.6;
kf = 0.1;
thf = 0.2;

% integration pars
dt = 0.1;
time = 18000;
tax = dt:dt:time*dt;

%initial conditions
a1 = .3; a2 = .4;
u1 = 0; u2 = 0;

%plot nullclines
u1_line = -.5:.02:1;
u2_line = u1_line;
% 
% arg1 = -beta*u1_line-g*a1+iboth;
% arg2 = -beta*u2_line-g*a2*iboth;
% 
% y1=(1+exp(thf-(arg1)./kf)).^(-1);
% y2=(1+exp(thf-(arg2)./kf)).^(-1);
% 
% plot(y1,xline,'r',xline,y2,'b')

a1(time)=0;
a2(time)=0;

u1(time)=0;
u2(time)=0;
for t=1:time 
    a1(t+1) = a1(t)+dt*(1/taua)*(u1(t)-a1(t));
    a2(t+1) = a2(t)+dt*(1/taua)*(u2(t)-a2(t));
    
    
    val1 = -beta*u2(t)-g*a1(t)+iboth+i1;
    val2 = -beta*u1(t)-g*a2(t)+iboth+i2;
    
    u1(t+1) = u1(t)+dt*(-u1(t)+(1+exp((thf-val1)/kf))^(-1));
    u2(t+1) = u2(t)+dt*(-u2(t)+(1+exp((thf-val2)/kf))^(-1));

   
%     arg1 = -beta*xline-g*a1(t)+iboth;
%     arg2 = -beta*xline-g*a2(t)*iboth;
%    

    y1=f(-beta*u1_line-g*a1(t)+iboth+i1,thf,kf);
    y2=f(-beta*u2_line-g*a2(t)+iboth+i2,thf,kf);
    %y2=(1+exp(thf-(arg2)./kf)).^(-1);
    
    %for teh_seks
    %dt=dt*1.0001;
    
%     if mod(t,10)==0
%     plot(y1,u1_line,'r',u2_line,y2,'b', ...
%     u1(max(t-70,1):t+1),u2(max(t-70,1):t+1),'k',u1(t+1),u2(t+1),'ko'),...
%     %a1(max(t-70,1):t+1),a2(max(t-70,1):t+1),'r',a1(t+1),a2(t+1),'ro');
%     
%     
%     h_x=xlabel('U1');
%     h_y=ylabel('U2');
%     axis([-.5 1.2 -.5 1.2])
%     drawnow;
%     end
    

end
figure;

plot(1:time+1,u1,'r',1:time+1,u2,'b',1:time+1,a1,'r--',1:time+1,a2,'b--')

function Fu = f(u,thf,kf)

if size(u)==1
Fu = 1/(1+exp((thf-u)/kf));
else
Fu = 1./(1+exp((thf-u)./kf));
end