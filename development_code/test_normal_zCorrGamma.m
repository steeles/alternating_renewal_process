
n = 10000;
rho_hat(n) = 0;
r11(n) = 0; r22(n) = 0;
z1(n)=0; z2(n)=0; p11(n)=0; p22(n)=0; pTot(n)=0;

%p1 = [1 3]; p2 = [1 5];

for ind = 1
randBounds = [1 4]; % sets minimum value and range for shape parameter
p1 = rand(1,2).*[diff(randBounds), 4*diff(randBounds)] + randBounds(1);
p2 = rand(1,2).*[diff(randBounds), 4*diff(randBounds)] + randBounds(1);

for ind = 1:n
    
    Durs = make_2gamma_distrs(p1, p2, 200);
    
    [Ipre, Spre, Ipost, Spost] = split_Durs(Durs);
    
    [rho_hat(ind) r11(ind) r22(ind)...
        z1(ind) z2(ind) p11(ind) p22(ind) pTot(ind)] = ...
        compute_pWeightedR_cumhist(Spost,Ipost, Ipre, Spre);
end

%figure; hist(rho_hat,50); figure; hist(r11,50); figure; hist(r22,50)

figure; hist(pTot,20); mk_Nice_Plot; xlabel('p value'); ylabel('count');
title(sprintf('g1 = [%.2f,%.2f] | g2 = [%.2f,%.2f]',p1(1),p1(2),p2(1),p2(2)));
end