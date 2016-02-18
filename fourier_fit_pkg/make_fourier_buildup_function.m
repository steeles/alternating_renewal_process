% 6/19/2012 wrote to modularize BUF building in Fourier domain; I want to
% call this function within a fitting search function and objective subfunction
% bufpars is [a0,th0,a1,th1], optstruct is options, bPlot is whether to plot
% optstruct.T is time window, optstruct.m is resolution
% function [BUF tax] = make_fourier_buildup_function(bufpars,optstruct,bPlot)

function [BUF tax] = make_fourier_buildup_function(bufpars,optstruct,bPlot)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% housekeeping, time distortion
if ~exist('optstruct','var')
    T = 40;
    m = 12;
else
    T = optstruct.T;
    m = optstruct.m;
end



N=2^m; % total number of points
L=2*T;   % I think I need 10 s
df=1/L; 
f=(0:(N-1))*df; % discrete frequencies, but not all are used; remember that f 
                % is related to omega = 2*pi*f;
dt=L/N;
t=((-N/2):(N/2-1))*dt;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% specific parameters are a0, a1, b0, b1, etc
% I'm actually going to use theta, since all the builtin code seems geared
% towards it
a0 = bufpars(1); th0 = bufpars(2); a1 = bufpars(3); th1 = bufpars(4);

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

tmp_coeff = (1-(1+1i*w*th1).^-a1).*fT0_transform;

p_transform_1given0 = tmp_coeff .* (1 + tmp_num./tmp_den);

% p_transform_1given0 = fT0_transform .* FT1_CCDF_transform + ...
%     1./(1i*w).*((FT1_CCDF_transform.*fT0_transform.^2 .* fT1_transform * 1i.*w)./...
%     (1-fT0_transform.*fT1_transform));

p_transform_1given0 = [mean1/(mean1+mean0) p_transform_1given0];


%% and now it says, "inverse fourier transform that, then integrate from 0:t"

rho_hat_an=p_transform_1given0;

rho_hat_an((N/2+1+1):N) = conj(rho_hat_an((N/2+1-1):-1:2)); % backwards to the second ind
rho=(N/L)*ifft(rho_hat_an);
rho=rho([ (N/2+1+1):N 1:(N/2+1) ]);


%%
p_1given0 = dt * cumsum(real(rho));


BUF = p_1given0;
if ~exist('bPlot','var')
    bPlot = 0;
end
tax = t(t>=0);
BUF = BUF(t>=0);
if bPlot
        
    figure;
    plot(tax,BUF);
    
end