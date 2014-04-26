%nullcline animation

%basic parameters

taua = 100;
beta = 0.9;
g = .5;
iboth=0.5;
kf = 0.1;
thf = 0.2;

% integration pars
dt = 0.1;
time = 50000;

%initial conditions
a1 = .3; a2 = .4;
u1 = 0; u2 = 0;

%plot nullclines
xline = -.5:.02:1;
% 
arg1 = -beta*xline-g*a1+iboth;
arg2 = -beta*xline-g*a2*iboth;

y1=(1+exp(thf-(arg1)./kf)).^(-1);
y2=(1+exp(thf-(arg2)./kf)).^(-1);

plot(y1,xline,'r',xline,y2,'b')

a1(time)=0;
a2(time)=0;

u1(time)=0;
u2(time)=0;
for t=1:time 
    a1(t+1) = a1(t)+dt*(1/taua)*(u1(t)-a1(t));
    a2(t+1) = a2(t)+dt*(1/taua)*(u2(t)-a2(t));
    
    
    val1 = -beta*u2(t)-g*a1(t)+iboth;
    val2 = -beta*u1(t)-g*a2(t)+iboth;
    
    u1(t+1) = u1(t)+dt*(-u1(t)+(1+exp((thf-val1)/kf))^(-1));
    u2(t+1) = u2(t)+dt*(-u2(t)+(1+exp((thf-val2)/kf))^(-1));

   
    arg1 = -beta*xline-g*a1(t)+iboth;
    arg2 = -beta*xline-g*a2(t)*iboth;
   

    y1=(1+exp(thf-(arg1)./kf)).^(-1);
    y2=(1+exp(thf-(arg2)./kf)).^(-1);
    
    if mod(t,10)==0
    plot(xline,y1,'r',y2,xline,'b',u1(max(t-130,1):t+1),u2(max(t-130,1):t+1),'k',u1(t+1),u2(t+1),'ko');
    h_x=xlabel('U1');
    h_y=ylabel('U2');
    axis([-.5 1.2 -.5 1.2])
    drawnow;
    end
    

end
figure;
plot(1:time+1,u1,'r',1:time+1,u2,'b')

