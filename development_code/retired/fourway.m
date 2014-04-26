%fourway.m

% synaptic depression Laing & Chow model 
% Steeles Jan 26 2012
% * characterized as a /divisive/ slow process with term -B*u2*g2

function u1=fourway


%basic parameters

taud = 150;
B = 0.53;
gam = 0.3;
iboth=0.4;
%NOTE: for i1=0.8 and i2=0.2, nullclines intersect but no oscillations?
i1=0.0;
i2=0.0;
kf = 0.1;
thf = 0.1;

% integration pars
dt = 0.1;
time = 40000;

%initial conditions
g1 = 0; g2 = 0;
u1 = 0.8; u2 = 0;
%basic parameters for SFA model

taua = 100;
beta = 0.9;
g = 1;

%initial conditions
a1 = .3; a2 = .4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
u_null_line = -.5:.02:1;

u1(time+1)=0;
u2(time+1)=0;
g1(time+1)=0;
g2(time+1)=0;
a1(time+1)=0;
a2(time+1)=0;
u1sfa(time+1)=0;
u2sfa(time+1)=0;

for t=1:time
    
    g1(t+1) = g1(t) + dt * (1/taud) * (1-g1(t)-gam*u1(t)*g1(t));
    g2(t+1) = g2(t) + dt * (1/taud) * (1-g2(t)-gam*u2(t)*g2(t));
    
    u1(t+1) = u1(t)+ dt*(-u1(t)+f_sig(-B*u2(t)*g2(t)+i1+iboth, thf, kf));
    u2(t+1) = u2(t)+ dt*(-u2(t)+f_sig(-B*u1(t)*g1(t)+i2+iboth, thf, kf));
    
    % calculate the nullclines where dUi/dt=0
    
    y1=f_sig(-B*u_null_line*g2(t)+i1+iboth,thf,kf);
    y2=f_sig(-B*u_null_line*g1(t)+i2+iboth,thf,kf);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %and for SFA model
    
    a1(t+1) = a1(t)+dt*(1/taua)*(u1(t)-a1(t));
    a2(t+1) = a2(t)+dt*(1/taua)*(u2(t)-a2(t));
    
    
    val1 = -beta*u2(t)-g*a1(t)+iboth+i1;
    val2 = -beta*u1(t)-g*a2(t)+iboth+i2;
    
    u1sfa(t+1) = u1(t)+dt*(-u1(t)+(1+exp((thf-val1)/kf))^(-1));
    u2sfa(t+1) = u2(t)+dt*(-u2(t)+(1+exp((thf-val2)/kf))^(-1));

    y1sfa=f_sig(-beta*u_null_line-g*a1(t)+iboth+i1,thf,kf);
    y2sfa=f_sig(-beta*u_null_line-g*a2(t)+iboth+i2,thf,kf);

      
    %for teh_seks
    dt=dt*1.0001;
    
    if mod(t,30)==0
        subplot(1,2,1)
        plot(y1,u_null_line,'r',u_null_line,y2,'b', ...
        u1(max(t-70,1):t+1),u2(max(t-70,1):t+1),'k',u1(t+1),u2(t+1),'ko'),...
        %g1(max(t-70,1):t+1),g2(max(t-70,1):t+1),'r',g1(t+1),g2(t+1),'ro');
        subplot(1,2,2)
        plot(y1sfa,u_null_line,'r',u_null_line,y2sfa,'b', ...
        u1sfa(max(t-70,1):t+1),u2sfa(max(t-70,1):t+1),'k',...
        u1sfa(t+1),u2sfa(t+1),'ko')...
  %a1(max(t-70,1):t+1),a2(max(t-70,1):t+1),'r',a1(t+1),a2(t+1),'ro');

    h_x=xlabel('U1');
    h_y=ylabel('U2');
    axis([-.5 1.2 -.5 1.2])
    drawnow;
    end
end
figure;

plot(1:time+1,u1,'r',1:time+1,u2,'b',1:time+1,g1,'r--',1:time+1,g2,'b--')

% LC spike fq adaptation model (like Shpiro et al 2007, eq 4)
% by Sara Steele
% characterized as a -subtractive- slow process eg term -beta*u2-g*a1



% alex asked an excellent question- where's the stochasticity?

%nullcline animation

%basic parameters

taua = 100;
beta = 0.9;
g = 1;

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
    dt=dt*1.0001;
    
    if mod(t,10)==0
    plot(y1,u1_line,'r',u2_line,y2,'b', ...
    u1(max(t-70,1):t+1),u2(max(t-70,1):t+1),'k',u1(t+1),u2(t+1),'ko'),...
    %a1(max(t-70,1):t+1),a2(max(t-70,1):t+1),'r',a1(t+1),a2(t+1),'ro');
    
    
    h_x=xlabel('U1');
    h_y=ylabel('U2');
    axis([-.5 1.2 -.5 1.2])
    drawnow;
    end
    

end
figure;

plot(1:time+1,u1,'r',1:time+1,u2,'b',1:time+1,a1,'r--',1:time+1,a2,'b--')

function Fu = f(u,thf,kf)

if size(u)==1
Fu = 1/(1+exp((thf-u)/kf));
else
Fu = 1./(1+exp((thf-u)./kf));
end

function Fu = f_sig(u,thf,kf)

if size(u)==1
    Fu = 1/(1+exp((thf-u)/kf));
else
    Fu = 1./(1+exp((thf-u)./kf));
end