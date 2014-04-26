%function test_fft_sara

m=10;
N=2^m;  % total number of points
L=2;    % total length (in time?)
df=1/L;
f=(0:(N-1))*df; % discrete frequencies, but not all are used; remember that f 
                % is related to omega = 2*pi*f;
dt=L/N;
t=((-N/2):(N/2-1))*dt;

p=8;    % "shape" or power in gamma function; k, alpha
mu=0.3; % mean of the distribution
tau = mu/p; % dividing by p keeps mean fixd at mu; theta, 1/beta

rho_hat_an=(1./(1+1i*2*pi*f*tau)).^p;
rho_hat_an((N/2+1+1):N) = conj(rho_hat_an((N/2+1-1):-1:2));
rho=(N/L)*ifft(rho_hat_an);
rho=rho([ (N/2+1+1):N 1:(N/2+1) ]);



proper_gam_pdf = gampdf(t,p,tau);
plot(t,proper_gam_pdf,'b',t,real(rho),'ro');

