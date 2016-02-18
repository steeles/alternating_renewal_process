function plot_H_timeCourse(Durs,tau)


if Durs(1,1) ~=0
    Durs = [0 0 ; Durs];
end

dt = .001;
switchtimes = round(cumsum(Durs(:,1))/dt)*dt; % round to hundredths 
ttot = switchtimes(end);


tax = 0:dt:ttot;
h1timeCourse(length(tax)) = 0;
h2timeCourse(length(tax)) = 0;

for ind = 1:length(Durs)-1
    
    tInds = 1+round((switchtimes(ind)/dt+1):(switchtimes(ind+1)/dt));
   
    sInd = dt:dt:((length(tInds))*dt);
    
    dur = Durs(ind+1,1);
    %nSteps = round(dur/dt);
    
    %keyboard;
    
    if Durs(ind+1,2) == 1
        h1timeCourse(tInds) = h1timeCourse(tInds(1)-1)...
            * exp(-(sInd/tau)) + 1*(1-exp(-sInd/tau));
        
        h2timeCourse(tInds) = h2timeCourse(tInds(1)-1)...
            * exp(-(sInd/tau));
        
    else
        h1timeCourse(tInds) = h1timeCourse(tInds(1)-1)...
            * exp(-(sInd/tau));
        
        h2timeCourse(tInds) = h2timeCourse(tInds(1)-1)...
            * exp(-(sInd/tau)) + 1*(1-exp(-sInd/tau));
        
    end
end

figure; plot(tax,h1timeCourse,'Color',[250 188 81]/256); hold on;
    plot(tax,h2timeCourse,'Color',...
        [87.3 195 226]/256);
    mk_Nice_Plot;
        
    
    