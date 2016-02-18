function [rBootNorm bootstat pValScram] = compute_corrZ(Xin,Yin,nBoot)

E_x = mean(Xin); E_y = mean(Yin);

X = Xin-E_x; Y = Yin-E_y;

num = sum(X.*Y);

% this is NOT the standard deviation from MATLAB, which normalizes by n-1

varX = sum(X.^2); varY = sum(Y.^2);

denom = sqrt(varX)* sqrt(varY);

r = num/denom;

%% return non-parametric measures of uncertainty


% first do as MATLAB says
if exist('nBoot','var') && nBoot
    
    bootstat = bootstrp(nBoot, @corr, Xin, Yin);
    
    rBootNorm = mean(bootstat)/std(bootstat); % essentially the z score of the correlation, yes?
    
end


% I might also minimize the squared error of the regression in
% compute_combined_cum_history