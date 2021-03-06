% [H1 H2] = compute_H_2(Durs, tau, bPlot)

function [H1 H2] = compute_H_2(Durs, tau, bPlot)

if ~exist('tau','var')
   tau = 1; 
end

if Durs(1,1) ~=0
    Durs = [0 0 ; Durs];
end

%Durs(Durs(:,2)==3)=[]; % excise hybrid percepts?

nSwitches = length(Durs);

H1 = zeros(nSwitches,1); H2 = zeros(nSwitches,1);

% put in switchtimes as a x axis for plotting

switchTimes = [ cumsum(Durs(:,1)) Durs(:,2)];

for ind = 2:nSwitches
    
    dur = Durs(ind,1);
    
    % could also do the control structure by looking at the state ID, which
    % would allow me to come up with a 3rd option for state = 3 where they
    % both decay    
    
    % switch out of state 1 at T11 and every other T1 after that; H1 grew,
    % H2 decayed
    if Durs(ind,2)==1     %mod(ind,2) == 0

        % growth and decay
        H1(ind) = H1(ind-1) * exp(-(dur/tau)) + 1*(1-exp(-dur/tau));
        % only decay
        H2(ind) = H2(ind-1) * exp(-(dur/tau)); %+ 0*(1-exp(-dur/tau));
        
    % if index is odd, we are switching out of state 2
    
    elseif Durs(ind,2)==2
        
        % state 1 decayed
        H1(ind) = H1(ind-1) * exp(-(dur/tau)); %+ 0*(1-exp(-dur/tau));
        
        H2(ind) = H2(ind-1) * exp(-(dur/tau))+ 1*(1-exp(-dur/tau));
        
    else
        
        % decay only (?) [or should they both grow and decay?] at 0.5!
        H1(ind) = H1(ind-1) * exp(-(dur/tau)) + .5*(1-exp(-dur/tau));
        H2(ind) = H2(ind-1) * exp(-(dur/tau)) + .5*(1-exp(-dur/tau));
        
        
    end
    
end
H1 = [H1 switchTimes(:,1)];
H2 = [H2 switchTimes(:,1)];

if exist('bPlot','var') && bPlot
    figure;
    plot(H1(:,2),H1(:,1),'r', H2(:,2),H2(:,1),'b')
end
