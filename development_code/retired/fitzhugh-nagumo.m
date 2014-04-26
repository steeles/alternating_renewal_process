% Simulations of the FitzHugh-Nagumo model.
% done for Dick FitzHugh by Eugene M. Izhikevich
% The simulation asks the user to put the initial conditions
% by clicking a point on the scree 


% Parameters of the model
a=-0.05;
b=0.02;
c=0.02;
I = -0.03;              

T=300;              % final time
tau=0.5;            % time step
time=tau:tau:T;     % time grid

vv=-0.5:0.02:1;     % need this vector to plot nullclines
vn=vv.*(a-vv).*(vv-1); % ignore this for now.
wn=vv*b/c;             % ingore this too

% ingnore this too. It sets the screen so that it does not flicker.
% you can remove this line if it bothers you
set(gcf,'DoubleBuffer','on','name','FitzHugh-Nagumo model');

plot(vv,vn+I,'r',vv,wn,'r')
axis([-0.5 1 -0.12 0.3])
[v0,w0] = ginput(1);
v=v0+0*time;       % the vector of v's. Initially at v0
w=w0+0*time;       % the vector of w's. Initially at w0

for i=1:length(time)-1  % go throuhg all time steps
    % I use 1st order Euler forward method here
    v(i+1)=v(i)+tau*(v(i)*(a-v(i))*(v(i)-1)-w(i)+I);
    w(i+1)=w(i)+tau*(b*v(i)-c*w(i));
    
    plot(vv,vn+I,'r',vv,wn,'b',v(max(i-130,1):i+1),w(max(i-130,1):i+1),'k',v(i+1),w(i+1),'ko')
    axis([-0.5 1 -0.12 0.3])
    
    % This just plots the equations. You can remove all the text commands.
    text(0.35,-0.05,'dv/dt=v(a-v)(v-1)-w+I')
    text(0.35,-0.075,'dw/dt=bv-cw')
    text(0.35,-0.1,['a=' num2str(a) ', b=' num2str(b) ', c=' num2str(c) ', I=' num2str(I)])
    text(0.75,0.25,['time=' num2str(round(time(i)))]);
    title('FitzHugh-Nagumo model');
    drawnow;    % you need this command to see the results immediately
end;

% Enjoy.

