% make exp. hists

load('~/Dropbox/my codes/rinzel/08.22.06.2011_3DF_4trl_reorder2.mat')


nConditions = length(rnet08_reorder2);

% initialize
g1_pars_mean(2,nConditions)=0;
g1_pars_std(2,nConditions)=0;

g2_pars_mean(2,nConditions)=0;
g2_pars_std(2,nConditions)=0;



for condition_ind = 1:nConditions
    
    conditionDurs = rnet08_reorder2(condition_ind).data;
    df = rnet08_reorder2(condition_ind).params(end);
    
    
    nonzeroInds = conditionDurs(:,2)~=0;
    conditionDurs = conditionDurs(nonzeroInds,:);
    
    dataInds1 = conditionDurs(:,2)==1;
    dataInds2 = conditionDurs(:,2)==2;
    
    Durs1 = conditionDurs(dataInds1,1)';
    Durs2 = conditionDurs(dataInds2,1)';
    
        find_gamma_fit(Durs1(1:50),1);
        find_gamma_fit(Durs2(1:50),1);

%%  Bootstrap

    nBoot = 100;
    
    g1s(2,nBoot) = 0;
    g2s(2,nBoot) = 0;
    
    % set up a subplot of the range of gam shapes
    h=figure;
    
    % set up x axes for each duration type
    
    x1 = linspace(0,max(Durs1)+2,200);
    x2 = linspace(0,max(Durs2)+2,200);    

    
    for bootInd = 1:nBoot

    % KEY STEP IN BOOTSTRAPPING- just generate a random list of the indices
    % of the data values that you want to throw into this estimate- this
    % constitutes sampling with replacement, as you choose a truly random set
    % of the values going into this analysis
    samplingInds1 = round(rand(1,length(Durs1))*(length(Durs1)-1))+1;
    samplingInds2 = round(rand(1,length(Durs2))*(length(Durs2)-1))+1;
    
    % your new x and y vectors are now available
    newDurs1 = Durs1(samplingInds1);
    newDurs2 = Durs2(samplingInds2);

    % and you run the regression on your "new" ;) data
    g1 = find_gamma_fit(newDurs1,0);
    g2 = find_gamma_fit(newDurs2,0);
    
    g1s(:,bootInd)=g1;
    g2s(:,bootInd)=g2;
    

    y1 = gampdf(x1,g1(1),1/(g1(2)));
    y2 = gampdf(x2,g2(1),1/(g2(2)));
    
    figure(h);
    subplot(211); hold on; plot(x1,y1,'Color',[.7 .7 .7]);
    subplot(212); hold on; plot(x2,y2,'Color',[.7 .7 .7]);
    
    
       
       
    % now save your coefficients into an array and run hist on the column that
    % corresponds to your coefficient of interest
  
    end
    g1_pars_mean(:,condition_ind) = mean(g1s,2);
    g1_pars_std(:,condition_ind) = std(g1s,0,2);
    y1 = gampdf(x1,g1_pars_mean(1,condition_ind),1/g1_pars_mean(2,condition_ind));
    
    
    g2_pars_mean(:,condition_ind) = mean(g2s,2);
    g2_pars_std(:,condition_ind) = std(g2s,0,2);
    y2 = gampdf(x2,g2_pars_mean(1,condition_ind),1/g2_pars_mean(2,condition_ind));
    
    
    subplot(211); mk_Nice_Hist(Durs1);
    plot(x1,y1,'r')
    
    title1 = ['Df = ' num2str(df) ', 1 stream'];
    title(title1)
    h1 = gca;
    xlabel('time (s)')
    
    

    subplot(212); mk_Nice_Hist(Durs2);
    plot(x2,y2,'r')
    
    title2 = ['Df = ' num2str(df) ', 2 streams'];
    title(title2)
    h2 = gca;
    xlabel('time (s)')
    
end




