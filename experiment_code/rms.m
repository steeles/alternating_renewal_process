function r = rms(x)

% y=sqmatrix(x);
% s=size(y);
% r=sqrt(sum(y)/s(2));
r=sqrt(sum(x.^2)/length(x));
end

