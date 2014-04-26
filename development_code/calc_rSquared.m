% takes vectorized T x nFingers Rsq 


function rSquared = calc_rSquared(X,u_x_predicted)

sum_squared_error = sum((X-u_x_predicted).^2);

total_variance = sum((X-repmat(mean(X),size(X,1),1)).^2);

rSquared = 1 - sum_squared_error./total_variance;


end