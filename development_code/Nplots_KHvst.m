function Nplots_KHvst
%
% this uses the function plotKHvst.m to plot
% several time courses of KeyHolds
%
% could be used to compare across subjects for given cond'n, say DF
% or to compare across cond'ns for a given subject.
% by John Rinzel

nplots=3; figure(1);
%datafile='08.22.06.2011_3DF...first.trial';
%r=load('steady_triplet_08/08.22.06.2011_3DF_4trl_reorder.mat');
datafile='testing StTripNtrials...first.trial';
r=load('testing_StTripNtrials.mat');
%for k=1:3 r.result(k).rawdata=r.r08new(k).rawdata; end;
subplot(nplots,1,1)
%rd1=r1.result(1).rawdata;
plotKHvst(r.result(1).rawdata,strcat('DF=4...',datafile));
subplot(nplots,1,2)
plotKHvst(r.result(2).rawdata,strcat('DF=5...',datafile));
subplot(nplots,1,3)
plotKHvst(r.result(3).rawdata,strcat('DF=6...',datafile));
%subplot(nplots,1,4)
%plotKHvst(r.result(3).rawdata,strcat('DF=6...',datafile));
%subplot(nplots,1,5)
%plotKHvst(r.result(5).rawdata,strcat('DF=7...',datafile));
end
