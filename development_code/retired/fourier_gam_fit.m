% take fft of a sample pdf and try to fit it with a fourier gamma
% pdf

function fourier_gam_fit(samples)

[count bin] = mk_Nice_Hist(samples); % gives you a hist with area 1
hold on;
% is this useful at all?
%count_remastered = interp1(bin,count,linspace(min(bin),max(bin),100),'cubic');

f_sample_density = fft(count);

figure;
plot(abs(f_sample_density(1:round(length(f_sample_density)/2))))
print -depsc '~/Dropbox/my codes/rinzel/fourier_sample_density'

 [g fval exitFlags] = fminsearch(@fourier_gamma,rand(1,2),...
    [],f_sample_density)

plot(bin,gampdf(bin,g(1),g(2)))

function error = fourier_gamma(g,x)

fq = 0:length(x)-1;

f_hat = (1+1i*(fq./g(2))).^(-g(1));

x_time = ifft(x);
f_time = ifft(f_hat);
error = sum((f_time-x_time).^2);

