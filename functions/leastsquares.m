%% the variables x and y should be column vectors corresponding to the
% scatterplot you are trying to fit. 
% 'k' instructs the program what exponent to fit to x. 
% "coeff" will give a column vector [c;m] where m is
% slope and c is intercept. 
% yHat gives expected values for each value of x and is used to plot line
% of best fit


function [coeff yHat] = leastsquares(x,y,k)

if ~exist('k','var'), k=1; end
% this is actually not right- if k >1, you need another column for each
% power of x
X = [ones(size(x)), x.^k];

% gives the constant and the slope for the line you are fitting
coeff = regress(y,X);
% and the expected y values under your model
yHat = X * coeff;
