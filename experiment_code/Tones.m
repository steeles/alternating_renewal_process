function [Tones,t]=Tones(Tdur)
% JR Test program to generate tones
%
% f=freq in kHz; t in ms

f=0.001*[392 415.3 440 466.16 493.88 523.25 554.37 587.33 622.25 659.26 698.46 739.99 783.99 830.61 880];
fs=44.1;
dt=1/fs;
%Tdur=150;
t=[dt:dt:Tdur]'-dt;
tramp=5;
rampon=min(t/tramp,ones(length(t),1));
rampoff=flipud(rampon);
tones=rampon.*sin(2*pi*f(1)*t).*rampoff;
for j=2:12;
	tones=[tones rampon.*sin(2*pi*f(j)*t).*rampoff];
end
Tones=tones;
end	