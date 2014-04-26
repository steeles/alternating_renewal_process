



function error = compare_buildup_functions(bufpars,BUF,tax)

[BUFproposed t] = make_fourier_buildup_function(bufpars);


BUF_adj = interp1(t,BUFproposed,tax,'cubic','extrap');  % put the two BUFs on the same time res

error = sum((BUF_adj - BUF).^2);