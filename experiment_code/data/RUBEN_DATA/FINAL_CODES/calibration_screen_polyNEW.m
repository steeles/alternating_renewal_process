function[needed_rgb]=screen_poly(wanted_lum)

%RGB=[0 64 128 192 256 320 384 448 512 576 640 704 768 832 896 960 1023]; 
%lum=[0.008 0.135 0.723 2.006 4.061 6.68 10.22 14.29 19.18 25.86 33.64 41.89 49.79 58.45 67.86 78.75 91.6];
 
RGB=[0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1]; 
%lum=[0.0015 0.01 0.112 0.482 1.295 2.645 4.5275 6.96 10.245 13.6725 18.1475 23.3375 27.93 34.575 40.975 49.45 57.6375 65.5 74.475 83.4375 91.275];

% new screen
lum=[0.125 0.54 1.35 2.53 4.39 6.47 9.08 12.1 15.9 20.3 26.6 31.1 37.8 44.0 52.1 60.5 71.7 79.9 87.4 91.2 96.4];

RGB_sc=RGB/RGB(length(RGB));
lum_sc=lum/(lum(length(lum))-lum(1));

x_rgb=[0:RGB(length(RGB))/length(RGB):RGB(length(RGB))];
y_lum=[lum(1):(lum(length(lum))-lum(1))/RGB(length(RGB)):lum(length(lum))];

x_rgb_sc=x_rgb/x_rgb(length(x_rgb));
y_lum_sc=y_lum/(y_lum(length(y_lum))-y_lum(1));

%above four lines define the mesh for PLOTTING the interpolating 
%polynomial, has nothing to do with finding values of the polynomial
 

[coefs_4,s]=polyfit(RGB_sc,lum_sc,4);
a1=coefs_4(1);
a2=coefs_4(2);
a3=coefs_4(3);
a4=coefs_4(4);
a5=coefs_4(5);

z_4=a1*x_rgb_sc.^4+a2*x_rgb_sc.^3+a3*x_rgb_sc.^2+a4*x_rgb_sc+a5;
%don't really have to do it, but now I see that to get the polynomial I 
%need roots to, z4-desired luminocity==0, I only have to subtract 
%desired luminocity from the fifth coefficient 

coefs_4(5)=coefs_4(5)-wanted_lum/(lum(length(lum))-lum(1));

needed_rgb=roots(coefs_4); % gives 4 roots, given the coefficients of 
                           % the polynomial

% find real roots among needed_rgb
if ~isreal(needed_rgb) % ~isreal gives TRUE if array has elements with 
                       % imaginary parts 
   real_roots=[];   % set an array of real roots
   for k=1:length(needed_rgb)
       if isreal(needed_rgb(k)) % isreal is TRUE if its argument is real 
          real_roots=[real_roots,needed_rgb(k)]; % add to the array of 
                                                % real roots
       end
   end 
   needed_rgb=real_roots;
end

% now find those between 0 and 1, there has to be only ONE of them
rr=find((needed_rgb<=1).*(needed_rgb>=0));
if (length(rr)==1) 
    needed_rgb=needed_rgb(rr);
else
    needed_rgb=NaN;  
end

%finally, scale it back frok between 0 and 1 to between 0 and max 
%possible RGB 
needed_rgb=needed_rgb*RGB(length(RGB));

%plot(x_rgb_sc*x_rgb(length(x_rgb)),z_4*(lum(length(lum))-lum(1)),'r',...
%RGB,lum,'g',needed_rgb,wanted_lum,'db')

return
