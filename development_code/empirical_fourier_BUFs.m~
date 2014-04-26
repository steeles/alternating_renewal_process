% empirical fourier bufs

clear;
bPlot=1;
n = 1;

% first I'm going to see what the empirical BUF is
KPushETs_ss

durs1 = durs(durs(:,2)==1,1);
durs2 = durs(durs(:,2)==2,1);
dursLength = min(length(durs1),length(durs2));
durs1 = durs1(1:dursLength); durs2 = durs2(1:dursLength);
mn0 = mean(durs1); mn1 = mean(durs2);
var0 = var(durs1); var1 = var(durs2);


timestep = .001; window = 10; timeline = timestep:timestep:window;

%figure; hold on;
[BUF nWindows] = make_buildup_function2(durs, timestep, window);

if bPlot
    figure; plot(timeline, BUF);
    title('Empirical BUF and fourier BUF with MLE parameters')
end

durs1 = durs(durs(:,2)==1,1);
[g1 alpha beta fVal] = find_gamma_pars(durs1);
        
durs2 = durs(durs(:,2)==2,1);
[g2 alpha beta fVal] = find_gamma_pars(durs2);

 g1(2) = 1/(g1(2));
g2(2) = 1/(g2(2));

bufpars = [g1' g2'];

[fBUF tax] = make_fourier_buildup_function(bufpars);
hold on; plot(tax,fBUF)

%% now the fit of gamma pars from the empirical BUF

f = @(bufpars)compare_buildup_functions(bufpars,BUF,timeline);

bufpars0 = [mn0^2/var0 var0/mn0 mn1^2/var1 var1/mn1];

[bufparsf fval] = fminsearch(f,bufpars0);

figure;
[BUFfit t] = make_fourier_buildup_function(bufparsf);

%BUF_up = interp1(t,BUFfit,tax);

plot(t,BUFfit,timeline,BUF); title(num2str(bufparsf))