% we want to know how variation in the mean used at the BEGINNING of
% intervals to draw the next interval

function [H1cell H2cell mnsCell1 mnsCell2] = find_Hs_and_mns(DursCell,pars)

k1 = pars(1);
k2 = pars(2);
b1 = pars(3);
b2 = pars(4);
m1 = pars(5);
m2 = pars(6);
tau = pars(7);

nDurs = length(DursCell);

H1cell{nDurs} = [];
H2cell{nDurs} = [];
mnsCell1{nDurs} = [];
mnsCell2{nDurs} = [];

for ind = 1:nDurs
    
    [H1 H2] = compute_H_2(DursCell{ind},tau);
    
    H1cell{ind} = H1; H2cell{ind} = H2;
    
    mnsCell1{ind} = exp(m1 * H1(:,1) + b1);
    mnsCell2{ind} = exp(m2 * H2(:,1) + b2);
    
end

