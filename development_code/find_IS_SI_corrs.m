% options.bPlot, bSpear, bPerm, bScrambled

% stats.Pearson = [r p rlo rup]; stats.Spearman = [r p]; stats.perm = p

function [statsIS, statsSI] = find_IS_SI_corrs(Durs,options)

if exist('options','var')
    v2struct(options)
end
% 
% if iscell(DursCell)
%     NumReps = length(DursCell);
% else
%     NumReps = 1; tmp = DursCell; DursCell = cell(1); DursCell{1} = tmp;
% end

rInd = 1; NumReps = 1;

statsIS.rPearson(NumReps,4) = 0;
statsSI.rPearson(NumReps,4) = 0;
% % this would come before here
% if exist('bNormalized','var') && bNormalized
%     Durs = normalizeDurs(Durs);
% end
%for rInd = 1:NumReps
    
    %Durs = DursCell{rInd};
    [Ipre Spre Ipost Spost] = split_Durs(Durs);
    
    if exist('bScrambled','var') && bScrambled
        Ipre = Ipre(randperm(length(Ipre)));
        Ipost = Ipost(randperm(length(Ipost)));
    end
    
    [rPear pPear rlo rup] = corrcoef(Ipre,Spost); %keyboard;
    try
        statsIS.rPearson(rInd,1:4) = [rPear(1,2) pPear(1,2) rlo(1,2) rup(1,2)];
    catch me
        statsIS.rPearson(rInd,1:4) = [rPear pPear rlo rup];
    end
    %
    % IScorrPearson(sInd,rInd,cInd) = rPear(1,2);
    % IS_pPear(sInd,rInd,cInd) = pPear(1,2);
    
    %figISText = sprintf('r_p=%.2f, CI:(%.2f,%.4f)',rPear(1,2),rlo(1,2),rup(1,2));
    
    if exist('bSpear','var') && bSpear
        [rSpear pSpear] = corr(Ipre,Spost,'type','Spearman');
        statsIS.rSpearman(rInd,1:2) = [rSpear pSpear];
        figISText = [figText sprintf('\nr_s=%.2f, p=%.4f',rSpear,pSpear)];
    end
    
    if exist('bPerm','var') && bPerm
        pPerm = rPerm(Ipre,Spost);
        statsIS.pPerm(rInd) = pPerm;
        figISText = [figText sprintf('\np_p=%.4f',pPerm)];
    end
    
    if exist('bPlot','var') && bPlot
        %     IS_pPear(sInd,rInd,cInd) = pPerm;
        subplot(2,NumReps,rInd);
        plot(Ipre,Spost,'m.'); %mk_Nice_Plot;
        xlabel('Integration'); ylabel('Next Segregation')
        
        foo = xlim; bar = ylim;
        text(.03*foo(2), .6 * bar(2), figISText);
        
        %if rInd == 1, title('I -> S'); end
    end
    
    [rPear pPear rlo rup] = corrcoef(Spre,Ipost);
   
    try
        statsSI.rPearson(rInd,1:4) = [rPear(1,2) pPear(1,2) rlo(1,2) rup(1,2)];
    catch me
        statsSI.rPearson(rInd,1:4) = [rPear pPear rlo rup];
    end
    %figSIText = sprintf('r_p=%.2f, CI:(%.2f,%.4f)',rPear(1,2),rlo(1,2),rup(1,2));
    
    if exist('bSpear','var') && bSpear
        [rSpear pSpear] = corr(Spre,Ipost,'type','Spearman');
        statsSI.rSpearman(rInd,1:2) = [rSpear pSpear];
    end
    
    if exist('bPerm','var') && bPerm
        pPerm = rPerm(Spre,Ipost);
        statsSI.pPerm(rInd) = pPerm;
    end
    
    if exist('bPlot','var') && bPlot
        
        subplot(2,NumReps, NumReps + rInd);
        plot(Spre, Ipost, 'm.'); %mk_Nice_Plot;
        xlabel('Segregation'); ylabel('Next Integration');
        
        foo = xlim; bar = ylim;
        
        text(.03*foo(2), .6 * bar(2), figSIText);
    end
%end