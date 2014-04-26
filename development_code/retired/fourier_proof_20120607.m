% trying to show buildup expression in fourier space gives the same buildup
% function as monte carlo simulations in time domain


nSwitches = 400;

if ~exist('g1','var')
    g1 = [2;2]; g2 = [5;2];
end

a0 = g1(1); b0 = g1(2); a1 = g2(1); b1 = g2(2); % i think? unless it's theta

% gampdf takes theta, so does Dan's original fourier expression for gamma
% density

th0 = 1/b0; th1 = 1/b1;


% Now I generate the dominance durations from each distribution for
% nSwitches/2 samples on each of nTrials
durs1=gamrnd(g1(1),1/g1(2),nSwitches/2,1);

% dominance durations for percept 2
durs2=gamrnd(g2(1),1/g2(2),nSwitches/2,1);

figure; subplot(211); mk_Nice_Hist(durs1); hold on;
x = linspace(0,10,200);
y1 = gampdf(x,g1(1),1/(g1(2)));
plot(x,y1,'b');

subplot(212); mk_Nice_Hist(durs2); hold on;
x = linspace(0,10,200);
y2 = gampdf(x,g2(1),1/(g2(2)));
plot(x,y2,'b');



Durs=[];
Durs(1:2:length(durs1)+length(durs2)-1,:)=[durs1 ones(length(durs1),1)];
Durs(2:2:length(durs1)+length(durs2),:)=[durs2 ones(length(durs2),1)*2];



BUF = make_buildup_function2(Durs, .001, 10);
tax = .001:.001:10;

% I need to make sure to capture the full distribution, so I'm going to use
% the histogram axis- for these pars, I seem to need about 10 s, which
% equals 20 sec for this to get symmetric about t=0;

% I'm going to start by trying to put in the true gamma parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% housekeeping, time distortion
m = 14;
N=2^m; % total number of points
L=40;   % I think I need 10 s
df=1/L; 
f=(0:(N-1))*df; % discrete frequencies, but not all are used; remember that f 
                % is related to omega = 2*pi*f;
dt=L/N;
t=((-N/2):(N/2-1))*dt;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% specific parameters are a0, a1, b0, b1, etc
% I'm actually going to use theta, since all the builtin code seems geared
% towards it
mean0 = a0*th0; mean1 = a1*th1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expression time!

% first, f is omega (w) /2 pi, so...
w = 2 * pi * f;
w = w(2:end);

fT0_transform = (1 + 1i*w*th0).^-a0;
fT1_transform = (1 + 1i*w*th1).^-a1;
%FT1_CCDF_transform = 1./(1i*w) .* (1 - (1+1i*w*th1).^-a1);

tmp_num = fT0_transform .* fT1_transform;
tmp_den = 1-tmp_num;

tmp_coeff = (1-(1+1i*w*th0).^-a0).*fT0_transform;

p_transform_1given0 = tmp_coeff .* (1 + tmp_num./tmp_den);

% p_transform_1given0 = fT0_transform .* FT1_CCDF_transform + ...
%     1./(1i*w).*((FT1_CCDF_transform.*fT0_transform.^2 .* fT1_transform * 1i.*w)./...
%     (1-fT0_transform.*fT1_transform));

p_transform_1given0 = [mean0/(mean1+mean0) p_transform_1given0];


%% and now it says, "inverse fourier transform that, then integrate from 0:t"

rho_hat_an=p_transform_1given0;

rho_hat_an((N/2+1+1):N) = conj(rho_hat_an((N/2+1-1):-1:2)); % backwards to the second ind
rho=(N/L)*ifft(rho_hat_an);
rho=rho([ (N/2+1+1):N 1:(N/2+1) ]);


plot(t,rho);

%%
p_1given0 = dt * cumsum(real(rho));




figure;
plot(tax,BUF,'b',t,p_1given0,'ro');
% t

