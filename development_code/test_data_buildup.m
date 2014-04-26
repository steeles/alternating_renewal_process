clear;
bPlot=1;
n = 1;

% first I'm going to see what the empirical BUF is
KPushETs_ss


%% test for correlations
% four kinds of correlations- p(P1(sw)|P2(sw-1)), p(p2(sw)|P1(sw-1),
% p(P1(sw)|P1(sw-1)), p(P2(sw)|P2(sw-1))

% if using generated or simulated durs, create trial structure
%durs(2:10:end,:)=zeros(size(durs(1:10:end,:)));

durs1 = durs(durs(:,2)==1,1);
durs2 = durs(durs(:,2)==2,1);
dursLength = min(length(durs1),length(durs2));
        durs1 = durs1(1:dursLength); durs2 = durs2(1:dursLength);
%%
[corr_p_previous_p sig_p_prev_p] = corrcoef(durs(1:end-1), durs(2:end))

[corr_btwn_p2_previous_p1 sig_p2_prev_p1] = corrcoef(durs1,durs2)

p1s_after_p2s = durs1(3:end);
p2s_before_p1s = durs2(2:end); p2s_before_p1s = p2s_before_p1s(1:length(p1s_after_p2s));

[corr_btwn_p1_previous_p2 sig_p1_prev_p2] = corrcoef(p1s_after_p2s,p2s_before_p1s)

[corr_btwn_p1_prev_p1 sig_p1_prev_p1] = corrcoef(durs1(1:end-1),durs1(2:end))
[corr_btwn_p2_prev_p2 sig_p2_prev_p2] = corrcoef(durs2(1:end-1),durs2(2:end))


%%
timestep = .001; window = 10; timeline = timestep:timestep:window;

%figure; hold on;
[BUF tax nWindows] = make_switchTriggeredBUF(durs, timestep, window);
if bPlot, plot(tax,BUF,'r'); end

%% now I'm going to make some fits to derive the distrs that gave me that
% BUF


durs1 = durs(durs(:,2)==1,1);
[g1 alpha beta fVal] = find_gamma_pars(durs1);

% % [min_Alpha, betaAtMinAlpha, max_Alpha, betaAtMaxAlpha]=...
% %     find_gamma_confidence_intervals(alpha,beta,durs1,fVal,g1,bPlot);
% 
% g1_LowerUpperBounds = [min_Alpha max_Alpha; betaAtMinAlpha betaAtMaxAlpha];


durs2 = durs(durs(:,2)==2,1);
[g2 alpha beta fVal] = find_gamma_pars(durs2);

% [min_Alpha, betaAtMinAlpha, max_Alpha, betaAtMaxAlpha]=...
%     find_gamma_confidence_intervals(alpha,beta,durs2,fVal,g2,bPlot);
% g2_LowerUpperBounds = [min_Alpha max_Alpha; betaAtMinAlpha betaAtMaxAlpha];

steady_state=mean(durs2)/(mean(durs1)+mean(durs2));


%% plot those fits to check

    if bPlot
       figure; subplot(121)
       %mk_Nice_Hist(durs1); 
       hist(durs1); hold on;
       
       
       x = linspace(0,max(durs1)+2,200);
       y = gampdf(x,g1(1),(g1(2)));
       plot(x,y*length(durs1),'b'); mk_Nice_Plot
       %title(num2str(g1'));
       
               subplot(122); hist(durs2); %mk_Nice_Hist(durs2); 
               hold on;
         x = linspace(0,max(durs2)+5,200);
       y = gampdf(x,g2(1),(g2(2)));
       plot(x,y*length(durs1),'b'); mk_Nice_Plot
       %title(num2str(g2')); 
       legend([num2str(length(durs2)) ' durations']);
       
       %%
        subplot(211)
       y1 = gampdf(x,g1_LowerUpperBounds(1,1),g1_LowerUpperBounds(2,1));
       y2 = gampdf(x,g1_LowerUpperBounds(1,2),g1_LowerUpperBounds(2,2));
        plot(x,y1,'r--',x,y2,'g--')
        legend(['sample hist n = ', num2str(length(durs1))],'optimal fit',...
            'lower bound par fit','upper bound par fit')
        
        subplot(212); mk_Nice_Hist(durs2); hold on;
         x = linspace(0,max(durs2)+2,200);
       y = gampdf(x,g2(1),(g2(2)));
       plot(x,y,'b'); 
        
       y1 = gampdf(x,g2_LowerUpperBounds(1,1),1/g2_LowerUpperBounds(2,1));
       y2 = gampdf(x,g2_LowerUpperBounds(1,2),1/g2_LowerUpperBounds(2,2));
        plot(x,y1,'r--',x,y2,'g--')
        legend(['sample hist n = ', num2str(length(durs2))],'optimal fit',...
            'lower bound par fit','upper bound par fit')
    
        filename = ['gamma fit hists' num2str(n)];
        title(filename)
    print('-depsc', filename);
    
    end



%% now I'm going to simulate some distrs with those derived fits, and use
% that to make a BUF

    
    nRep = 10000;
    alltheBUFs(nRep,length(timeline))=0;
    h1=figure; subplot(121); title([num2str(nRep) ' simulated BUFs ' ...
        num2str(nWindows) 'windows']); hold on
    subplot(122); title([num2str(nRep) ' scrambled BUFs']); hold on
    simulated_durs = make_2gamma_distrs(g1,g2,length(durs));
    simdurs1 = simulated_durs(simulated_durs(:,2)==1,:);
    simdurs2 = simulated_durs(simulated_durs(:,2)==2,:);
    
    
    for foo=1:nRep
        simdurs(length(simulated_durs),2)=0;
        simdurs(1:2:length(simulated_durs)-1,:) = simdurs1(randperm(length(simdurs1)),:);
        simdurs(2:2:length(simulated_durs),:) = simdurs2(randperm(length(simdurs2)),:);
        
        BUF_sim = make_buildup_function2(simdurs,timestep,window);
        alltheBUFs(foo,:) = BUF_sim;
        if bPlot
        subplot(121); plot(timeline,BUF_sim,'Color',[.7 .7 .7]);
        
        
        % try also with scrambled
        dursLength = min(length(durs1),length(durs2));
        durs1 = durs1(1:dursLength); durs2 = durs2(1:dursLength);
        
        durs1_scrambled = durs1(randperm(dursLength));
        durs2_scrambled = durs2(randperm(dursLength));
        
        durs_scrambled(1:2:dursLength*2-1,:) = [durs1_scrambled ones(length(durs1),1)];
        durs_scrambled(2:2:dursLength*2,:) = [durs2_scrambled ones(length(durs2),1)*2];
        
        BUF_scrambled = make_buildup_function2(durs_scrambled,timestep,window);
        
        subplot(122); plot(timeline,BUF_scrambled,'m')
        end
    end
    %%
subplot(121); plot(timeline,BUF,'b', 'LineWidth',3); 
plot([timeline(1) timeline(end)],[steady_state steady_state],'k--');
plot(timeline,mean(alltheBUFs),'r:', 'LineWidth',3)
axis([0 window 0 1]);

subplot(122); plot(timeline,BUF,'b', 'LineWidth',3); 
plot([timeline(1) timeline(end)],[steady_state steady_state],'k--')
axis([0 window 0 1]);

filename = ['experimental_simulated_scrambled_BUFS' num2str(n)];
%print('-depsc',filename);
%%
tmp = sort(alltheBUFs);

upperbound = tmp(250,:);
lowerbound = tmp(end-250,:);

figure; plot(timeline, BUF,'b',timeline,upperbound,'r:',timeline,lowerbound,'r:')


h_x=xlabel('time'); h_y= ylabel('p(P2)');h_t= title('Buildup with 95% CIs');
mk_Nice_Plot(h_t,h_x,h_y)
%print -depsc 'BUF_CIs1')

%% look at first percept

first_pInds = find(durns_corrected(:,2)==0); %all durs in 1 trial preceded
                                                % by row of zeros
for trInd = 1:length(first_pInds)-1
    trialdurs = durns_corrected(first_pInds(trInd)+1:first_pInds(trInd+1)-1,:);
    % grab stats on first percept and all coherent percepts
    first_percepts(trInd,:) = trialdurs(1,:);
    other_percepts{trInd} = trialdurs(3:2:end-1,:);
    other_percept_stats(trInd,:) = [mean(trialdurs(3:2:end,1)) std(trialdurs(3:2:end,1))];
    trial{trInd} = trialdurs;
end

%
trial{length(first_pInds)} = durns_corrected(first_pInds(end)+1:end,:);

%% least squares fit
opt.T=40; opt.m=12;
[bufpars_fit BUFfit t] = find_fourier_BUF_fit(BUF,timeline,bPlot,opt,[g1;g2]);
hold on;



%%
clf;
plot(taxs08,BUFs08,'Color',[0 .75 .75]);
hold on; plot(taxfit, BUFfit,'r--')
axis([0 10 0 .9]);
mk_Nice_Plot
xlabel('time (s)'); ylabel('p(2 str)');
legend('switch triggered average','model fit')



%%
% check trial avg data
durs1 = durns_corrected(durns_corrected(:,2)==1,1);
[g1 alpha beta fVal] = find_gamma_pars(durs1);

% % [min_Alpha, betaAtMinAlpha, max_Alpha, betaAtMaxAlpha]=...
% %     find_gamma_confidence_intervals(alpha,beta,durs1,fVal,g1,bPlot);
% 
% g1_LowerUpperBounds = [min_Alpha max_Alpha; betaAtMinAlpha betaAtMaxAlpha];


durs2 = durns_corrected(durns_corrected(:,2)==2,1);
[g2 alpha beta fVal] = find_gamma_pars(durs2);
%%



[BUF tax] = make_trial_averaged_BUF(durns_corrected,.01,10);
figure; plot(tax,BUF);
axis([0 10 0 .7]);

[BUFfit taxfit] = make_fourier_buildup_function([g1;g2]);
hold on; plot(taxfit, BUFfit,'r')


[BUFfitUp] = interp1(taxfit,BUFfit,tax,'cubic');
calc_rSquared(BUF,BUFfitUp)