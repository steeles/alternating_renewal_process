function laing_chow_full

taua = 100;
beta = 1.1;
g = 0.5; % g = 1.0;
iboth= 1.0;
tauN = 10;
%NOTE: for i1=0.8 and i2=0.2, nullclines intersect but no oscillations?
i1=0.01;
i2=0.0;
kf = 0.1;
thf = 0.2;
sig = 0.03;

% integration pars
dt = 0.1;
time = 1000000;
tax = dt:dt:time*dt;

%initial conditions
a1 = .3; a2 = .4;
%a1 = 0; a2 = 0;
u1 = 0; u2 = 0;
n1 = 0; n2 = 0;

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

n1(time)=0; n2(time)=0;

for t=1:time-1 
    a1(t+1) = a1(t)+dt*(1/taua)*(u1(t)-a1(t));
    a2(t+1) = a2(t)+dt*(1/taua)*(u2(t)-a2(t));
    
    n1(t+1) = n1(t)+dt*(-n1(t)/tauN+sig*sqrt(2/tauN)*randn(1));
    n2(t+1) = n2(t)+dt*(-n2(t)/tauN+sig*sqrt(2/tauN)*randn(1));
    
    
    
    
    val1 = -beta*u2(t)-g*a1(t)+iboth+i1+n1(t);
    val2 = -beta*u1(t)-g*a2(t)+iboth+i2+n2(t);
    
    u1(t+1) = u1(t)+dt*(-u1(t)+(1+exp((thf-val1)/kf))^(-1));
    u2(t+1) = u2(t)+dt*(-u2(t)+(1+exp((thf-val2)/kf))^(-1));

   
%     arg1 = -beta*xline-g*a1(t)+iboth;
%     arg2 = -beta*xline-g*a2(t)*iboth;
%    

    y1=f(-beta*u1_line-g*a1(t)+iboth+i1,thf,kf);
    y2=f(-beta*u2_line-g*a2(t)+iboth+i2,thf,kf);
    %y2=(1+exp(thf-(arg2)./kf)).^(-1);
    
    %for teh_seks_pr0n
    %dt=dt*1.0001;
    %iboth = iboth+.00003;
    
%     if mod(t,100)==0
%     plot(y1,u1_line,'r',u2_line,y2,'b', ...
%     u1(max(t-70,1):t+1),u2(max(t-70,1):t+1),'k',u1(t+1),u2(t+1),'ko'),...
%     %a1(max(t-70,1):t+1),a2(max(t-70,1):t+1),'r',a1(t+1),a2(t+1),'ro');
%     
%     
%     h_x=xlabel('U1');
%     h_y=ylabel('U2');
%     %legend(['I = ' num2str(iboth)]);
%     axis([-.5 1.2 -.5 1.2])
%     drawnow;
%     end
    

end
figure;

plot(tax,u1,'r',tax,u2,'b',tax,a1,'r--',tax,a2,'b--')
legend('u1','u2')
function Fu = f(u,thf,kf)

if size(u)==1
Fu = 1/(1+exp((thf-u)/kf));
else
Fu = 1./(1+exp((thf-u)./kf));
end