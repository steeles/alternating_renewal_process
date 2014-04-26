function SDT_curves


numLine = 2*pi*(-1799:1800)/3600;
x = linspace(-179,180,length(numLine));

gaussian = 1/sqrt(2*pi*.05^2) * exp(numLine.^2/(-2*.05^2));
gauss = gaussian/sum(gaussian);
numLine2 = numLine - 5*pi/180;
gaussian2 = 1/sqrt(2*pi*.05^2) * exp(numLine2.^2/(-2*.05^2));
gauss2 = gaussian2/sum(gaussian2);

plot(x,gauss,'b',x,gauss2,'r','LineWidth',10)

axis([-15 20 -.002 .015])

end