% clean script to run key analyses for ARP data from James's data set
% should compute cum hist and anovas, find r values, normalize, plot

workingdir='/Users/steeles/Dropbox/my codes/rinzel/experiment_code/data/James Data/';
cd(workingdir)
data=load('SwitchTimes_NDF8_NSJ15_NREPS3.mat');

DFvals=data.DFvals;
NumCond=data.NumCond;
NumSubj=data.NumSubj;
NumReps=data.NumReps;
SwTimesCell=data.SwTimesCell;
DurationsCell=data.DurationsCell;

window = 15; step = .1;

nTaus = 20;
tau_ax = logspace(-.5,1.75,nTaus);

rVals = zeros(1,nTaus); r2Vals = zeros(1,nTaus);

for i=1:NumCond
    for j=1:NumSubj
        [DursStSt durs1 durs2] = catDursStStTrials(DurationsCell,i,j);
        nDurs = length(DursStSt);
        
        
        
        if nDurs >100
            
            
            
            fracDom = (mean(durs1(2:end-1))/(mean(durs2(2:end-1))+...
                mean(durs1(2:end-1))));
            
            if abs(fracDom-.5) < .1
                
                tax = []; BUF = [];
                
                g1 = gamfit(durs1); g2 = gamfit(durs2);
                
                rVals = zeros(1,nTaus); r2Vals = zeros(1,nTaus);
                
                % compute H x dur correlation for each tau over all trials
                for tInd = 1:nTaus
                    H1_tot = []; H2_tot = []; Durs = [];
                    tau = tau_ax(tInd);
                    
                    for k = 1:NumReps
                        
                        % there's a way to make the code faster by not
                        % recomputing all this for every tau 
                        DursWithTransients = DurationsCell{i,j,k};
                        
                                               

%            vvv          any(DursWithTransients(:,2)==3)
%                            fprintf('condn %d, subject %d,trial %d has mixed percept \n',i,j,k)
%                            continue
%                            elseif
%                             
                        if  DursWithTransients(1,2)==2
                            fprintf('condn %d, subject %d,trial %d starts split \n',i,j,k)
                            continue
                        else
                           
                           
                            
                           [H1 H2] = compute_H_2(DursWithTransients, tau, 0);
                            
                           % cut off the transients
                           Durs = [Durs; DursWithTransients(3:end-1,:)];
                           H1_tot = [H1_tot; H1(3:end-2,:)];
                           H2_tot = [H2_tot; H2(3:end-2,:)];
                        end
                    end
                    
                    [rVals(tInd) r2Vals(tInd)] = compute_H_corrs(H1_tot(:,1),H2_tot(:,1),Durs);
                    
                    
                end
                figure;
                
                [foo maxRi] = max(rVals);
                [foo maxR2i] = max(r2Vals);
                
                maxRtau = tau_ax(maxRi);
                maxR2tau = tau_ax(maxR2i);
                
                Tbar = mean(Durs(:,1));
                
                
                semilogx(tau_ax,rVals,'g'); hold on; mk_Nice_Plot;
                semilogx(tau_ax,r2Vals,'r'); 
                title(sprintf('condn %d, subject %d, best ~ %.2f, mnDur = %.2f',i,j,maxRtau,Tbar))
                legend('r','r2','Location','Best'); xlabel('tau'); ylabel('corr & r2')
                xlim([min(tau_ax) max(tau_ax)])
                
                
                tau = maxRtau;
               
                for k = 1:NumReps
                    
                    % there's a way to make the code faster by not
                    % recomputing all this for every tau
                    
                    DursWithTransients = DurationsCell{i,j,k};
                    
                    
%                     any(DursWithTransients(:,2)==3)
%                         fprintf('condn %d, subject %d,trial %d has mixed percept \n',i,j,k)
%                         continue
%             vvv     elseif
                    
                    
                    if  DursWithTransients(1,2)==2
                        fprintf('condn %d, subject %d,trial %d starts split \n',i,j,k)
                        continue
                    else
                        
                        
                        
                        [H1 H2] = compute_H_2(DursWithTransients, tau, 0);
                        
                        % cut off the transients
                        Durs = [Durs; DursWithTransients(3:end-1,:)];
                        H1_tot = [H1_tot; H1(3:end-2,:)];
                        H2_tot = [H2_tot; H2(3:end-2,:)];
                    end
                end
                
                compute_H_corrs(H1_tot(:,1),H2_tot(:,1),Durs,1);
                
                text(0.5, 1,sprintf('condn %d subj %d, tau = %.2f', i, j, tau),'HorizontalAlignment'...
            ,'center','VerticalAlignment', 'top', 'FontSize',20)
                
                % i need to functionalize this
%                 f = @(tau)compute_H_corrs(DursWithTransients,tau);
%                 g = @(tau)-f(tau);
%                 
%                 [tauH fval] = fminsearch(g,Tbar/2);
%                 
%                 compute_cum_history(DursWithTransients,tauH,1);
%                 
%                 
                %% BUF stuff
                
                for k = 1:NumReps
                    
                    Durs = DurationsCell{i,j,k}(3:end,:);
                    
                    if Durs(1,2) == 1 && ~any(Durs(:,2)==3)
                        [BUF(k,:) tax rows] = make_switchTriggeredBUF(Durs,step,window);
                    
                    end
                    
                    
                end
                
                BUF = mean(BUF);
                
                % make ARP prediction for BUF based on gamma pars
                
                [BUF_pred tax_pred] = make_fourier_buildup_function([g1 g2]);
                
                % time warp
                
                BUF_adj = interp1(tax_pred,BUF_pred,tax,'cubic','extrap');
               
                % make MC BUF based on the number of durations in BUF
                %DursMC = make_2gamma_distrs(g1, g2, nDurs);
                
                %[BUFmc taxmc] = make_switchTriggeredBUF(DursMC,.1,15);
                
                
                bigFigure; subplot(1,2,2);
                plot(tax,BUF,'b',tax,BUF_adj,'r-.') %,tax,BUFmc,'g--');
                %keyboard;
                if 1
                    [upperbound lowerbound] = find_bootstrap_BUF_CIs(Durs,g1,g2,10000,tax,window,step);
                    hold on; plot(tax,upperbound,'Color',[.7 .7 .7])
                    plot(tax,lowerbound,'Color',[.7 .7 .7])
                end
                
                axis([0 10 0 1]);  mk_Nice_Plot; 
                legend('BUF','ARP','MC', 'Location', 'Best')
                %title(['LSE fit for BUF '...
                % [num2str(g1(ind,:)) num2str(g2(ind,:))] ', found ' num2str(bufpars_fit)]);
                
                %durs1S = Durs(Durs(:,2)==1,1); durs2S = Durs(Durs(:,2)==2,1);
                subplot(2,2,1);
                %histfit(durs1,10,'gamma')
                plot_gamma_hist_fit(durs1,g1); 
                xlabel('')
                %title(['Subject ' num2str(ind)]);
                %[g1 CI_gam1] = gamfit(durs1S); %disp(CI_gam1)
                
                %legend(sprintf('r = %.3f ', corr1(i,j)), sprintf('p = %.2f', p1))

                title(sprintf('grouped, n = %d',length(durs1)))
                subplot(2,2,3);
                %histfit(durs2,10,'gamma')
                plot_gamma_hist_fit(durs2,g2)
                
                %legend(sprintf('r = %.3f ', corr2(i,j)), sprintf('p = %.2f', p2))
                
                title(sprintf('split, n = %d',length(durs2)))
                %[g2 CI_gam2] = gamfit(durs2S); %disp(CI_gam2)
                
                %keyboard;
            end
        end
                    
    end
end
