%% X and Y should be column vectors for the scatterplot
% this program lets you get an estimate of the distribution of slopes for
% the line of best fit for your data. Instead of relying on a rarified
% sample that may have really bad outliers or whatnot, you resample- with
% replacement- from the data (so that on some iterations of your estimate
% you wind up leaving out the bad data, or whatever- this procedure gives
% you the illusion of having more data, essentially).
% At the end, you wind up having a histogram of the estimates of the slope
% that you obtain from each subset of your data that you re-sample.

function slopehist = babybootstrap(x,y,numBoot,k)

%figure; plot(x,y,'.');
if ~exist('k','var'), k = 1; end

% start off with an estimate of your coefficients
[coeff yHat] = leastsquares(x,y,k);

% initialize your slope histogram (for polynomial models, you have multiple
% coefficients, so I think you should have a histogram for each coefficient)
slopehist = zeros(size(coeff,1),numBoot);

% numBoot is the number of times that you resample the data
for i = 1:numBoot

% KEY STEP IN BOOTSTRAPPING- just generate a random list of the indices
% of the data values that you want to throw into this estimate- this
% constitutes sampling with replacement, as you choose a truly random set
% of the values going into this analysis
ind = round(rand(1,length(x))*(length(x)-1))+1;
% your new x and y vectors are now available
newx = x(ind);
newy = y(ind);
% and you run the regression on your "new" ;) data
[coeff yHat] = leastsquares(newx,newy);

% now save your coefficients into an array and run hist on the column that
% corresponds to your coefficient of interest
slopehist(:,i) = coeff;

end

