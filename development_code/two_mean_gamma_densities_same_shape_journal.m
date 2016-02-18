function two_mean_gamma_densities_same_shape_journal(muTgroup,muTseg)
%For paper, muTgroup=[7,5,1]'; muTseg=[3,5,9]';
%function two_mean_gamma_densities_same_shape_journal(mu_Tgroup,muTseg)
%Identical Integer gamma densities with shape parameter n and mean=muT (s)
%muT is ngroups-by-1 vector

fs=20;

mg=[1 2 4];%These are the integer values of n in the gamma-densities
nplots=length(mg);
t=linspace(0,40,1000);
nt=length(t);
dt=t(2)-t(1);

igroupColor=[1 0 0;0 0.5 0;0 0 1];%for 3 different mu0,mu1 values
nLineStyle=[{'-'};{'--'};{'-:'}];%different style for each plot withi a group

for igroup=1:length(muTgroup)
P_10_ann=zeros(nplots,nt);
Gamma0=P_10_ann;
Gamma1=Gamma0;

for ip=1:nplots%loop over shape, n, vaules for a group of mu vaues
    n=mg(ip);
    muT0=muTgroup(igroup);
    muT1=muTseg(igroup);
tau0=muT0/n;
tau1=muT1/n;
omegap0=i*(1/tau0 + 1/tau1);
L=1:(n-1);
omegap=i*( (tau0+tau1) + sqrt( (tau0-tau1)^2+4*tau0*tau1*exp(i*2*pi*L/n) ) )/(2*tau0*tau1);
omegam=i*( (tau0+tau1) - sqrt( (tau0-tau1)^2+4*tau0*tau1*exp(i*2*pi*L/n) ) )/(2*tau0*tau1);
omegapm=[omegap,omegam];
omega=[omegap0,omegapm];
lambda=i*omega;

K=1:(2*n-1);
KF=1:n;
D=zeros(1,2*n-1);
aux1=D;
for j=1:(2*n-1)
    %keyboard
    Jind=K(K~=j);
    term_vec=lambda(j)-lambda(Jind);
    D(j)=prod(term_vec);
    
    aux1(j)=tau1*gamma(n+1)*sum( (1./(gamma(KF+1).*gamma(n+1-KF))).*...
        (lambda(j)*tau1).^(KF-1) );
end

nu=real(-lambda(1:n));

H=zeros(n,length(t));
P=H;
for j=1:(2*n-1)
    coeff=aux1(j)*( D(j)*(tau0*tau1)^n )^(-1);
    H(j,:)=real( coeff*exp(lambda(j)*t) );
    P(j,:)=real( coeff*(1/lambda(j))*( exp(lambda(j)*t) - 1 ) );
end
    
h=sum(H,1);
%keyboard
P_10_ann(ip,:)=sum(P,1);
Gamma0(ip,:)=gampdf(t,n,muT0/n);
Gamma1(ip,:)=gampdf(t,n,muT1/n);



%keyboard
end%loop over ip,

fsi=18;
fh6=figure(6);
%keyboard
p10h=plot(t,P_10_ann,'LineWidth',2,'Color',igroupColor(igroup,:));
mk_Nice_Plot;
set(p10h(1),'LineStyle','-')
set(p10h(2),'LineStyle','--')
set(p10h(1),'LineStyle','-.')
if(igroup==1)
    set(gca,'FontSize',fs,'FontName','Arial')
    xlabel('t (s)','FontSize',fs,'FontName','Arial')
    ylabel('p_{1|0}','FontSize',fs,'FontName','Arial')
    set(gca,'XLim',[0 20])
    set(gca,'YLim',[0 1])
    hold on
end


if(igroup==2) %Plots gamma-densities for muTgroup=muTseg=5
figure(8)
%G=[Gamma0(1,:);Gamma1(1,:);Gamma0(2,:);Gamma1(2,:);Gamma0(3,:);Gamma1(3,:)];
hpi=plot(t,Gamma0,'-','LineWidth',2,'Color',[0 0.5 0]);
mk_Nice_Plot
set(hpi(1),'LineStyle','-.')
set(hpi(2),'LineStyle','--')
set(hpi(3),'LineStyle','-')
set(gca,'FontSize',fs,'FontName','Arial')
set(gca,'XLim',[0 20])
xlabel('t (s)','FontSize',fs)
ylabel('\Gamma density','FontSize',fs,'FontName','Arial')
%keyboard
tgh1=text(3.5,0.19,'4','FontSize',fs,'FontName','Arial')
tgh2=text(3.5,0.15,'2','FontSize',fs,'FontName','Arial')
tgh3=text(3.5,0.11,'1','FontSize',fs,'FontName','Arial')
tgh4=text(3.5-1.8,0.19,'\alpha = ','FontSize',fs,'FontName','Arial')
end%for if statement controlling plotting of gamma densities


end%igroup
figure(6)
tmuh1=text(16,0.25,'0.3, 0.7','FontSize',fs,'FontName','Arial');
tmuh2=text(16,0.45,'0.5, 0.5','FontSize',fs,'FontName','Arial');
tmuh3=text(16,0.85,'0.9, 0.1','FontSize',fs,'FontName','Arial');
tmuh4=text(9.5,0.825,'(\mu_1, \mu_0) = ','FontSize',fs,'FontName','Arial');

th1=text(6.1,0.652,'4','FontSize',fs,'FontName','Arial');
th2=text(7.1,0.552,'2','FontSize',fs,'FontName','Arial');
th3=text(8.1,0.42,'1','FontSize',fs,'FontName','Arial');
th4=text(4.3,0.652,'\alpha = ','FontSize',fs,'FontName','Arial');

%keyboard
hold off


%keyboard


%hold off

end

