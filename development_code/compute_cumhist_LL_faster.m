

function LL = compute_cumhist_LL_faster(DursCell,pars)

k1 = abs(pars(1)); % +
k2 = abs(pars(2)); % +

b1 = pars(3); % 
b2 = pars(4); % 

m1 = pars(5);
m2 = pars(6);
tau = abs(pars(7)); % +


th1 = exp(b1)/k1;
th2 = exp(b2)/k2;

LL = 0;

if ~iscell(DursCell)
    tmp = DursCell;
    DursCell = [];
    DursCell{1} = tmp;
end

for tInd = 1:length(DursCell)
    
    Durs = DursCell{tInd};
    if length(Durs)<4, continue; end
    %keyboard
    startInd = find(Durs(:,2)==1,1);
    
    Durs = Durs(startInd:end,:);
    
    nSwitches = length(Durs);
    
    lik(nSwitches)=0;
    
    
    lik(1) = gampdf(Durs(1,1),k1,th1);
    lik(2) = gampdf(Durs(2,1),k2,th2);
    
    [H1 H2] = compute_H_2(Durs(1:end-1,:),tau);
    
    for ind = 3:nSwitches
        
        if Durs(ind,2) == 1
            th_new = exp(b1 + m1*H1(ind,1))/k1;
            lik(ind) = gampdf(Durs(ind,1),k1, th_new);
            
        else
            
            th_new = exp(b2 + m2*H2(ind,1))/k2;
            lik(ind) = gampdf(Durs(ind,1),k2,th_new);
        end
    end
    lik(lik==0) = eps;
    LL = LL+sum(log(lik),'omitnan');
    if isnan(LL)
       keyboard;
    end
end
