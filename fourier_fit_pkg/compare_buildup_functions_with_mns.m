



function error = compare_buildup_functions_with_mns(shapepars,BUF,tax,mu0,mu1)

th0 = mu0/shapepars(1); th1 = mu1/shapepars(2);
bufpars = [shapepars(1) th0 shapepars(2) th1];
[BUFproposed t] = make_fourier_buildup_function(bufpars);


BUF_adj = interp1(t,BUFproposed,tax,'cubic','extrap');  % put the two BUFs on the same time res

error = sum((BUF_adj - BUF).^2);