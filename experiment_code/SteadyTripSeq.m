function [steadyseq]=SteadyTripSeq(tones,indA,indB,gap,nreps)
% Generate long triplet sequence A_B_A_gap
%
% if indA > indB we have H_L_H_gap
% f=freq in kHz; t in ms
%
% standard dfs:
% Tdur=120;gap=120;repeats=40;
%
% %result(condn).params=[Tdur repeats indL indH gap condn# or DF];
% result(2).params=[Tdur repeats 6 2 gap 4];
% result(3).params=[Tdur repeats 9 4 gap 5];
% result(4).params=[Tdur repeats 12 6 gap 6];
% result(1).params=[Tdur repeats 8 5 gap 3];
% result(5).params=[Tdur repeats 10 3 gap 7];
% result(6).params=[Tdur repeats 7 5 gap 2];
% result(7).params=[Tdur repeats 11 3 gap 8];


fbase=0.392;
fs=44.1;
dt=1/44.1;
%r = 1e-2;
r=1e-1;
gapz=zeros(floor(gap/dt),1);
length(gapz);
tripunit=zeros(3*length(tones(:,1))+length(gapz),1);
length(tripunit);
    tripunit=[tones(:,indA);tones(:,indB);tones(:,indA);gapz];
    tripunit=r*tripunit/rms(tripunit);
%    sound(tripunit(:,j),44100)
tripreps=tripunit;
for i=2:nreps;
    tripreps=[tripreps;tripunit];
end
steadyseq=tripreps;
end
        
    
