% h = plot_ARP_histBUFs(datastruct,titletext,bBootstrap)

function h = plot_ARP_histBUFs(datastruct,titletext,nBootstrap)

    if ~exist('titletext','var')
        titletext = '';
    end
    
    v2struct(datastruct);

    %text(30, 38,titletext,'HorizontalAlignment'...
     %       ,'center','VerticalAlignment', 'top', 'FontSize',20)
        
    h = figure; 
    set(gcf, 'Position', [1 1 1080 720]); % Maximize figure

    subplot(1,2,2);
    plot(tax,BUF,'b',tax,BUF_adj,'r-.') 

    if exist('nBootstrap','var') && nBootstrap
        [upperbound lowerbound] = find_bootstrap_BUF_CIs(Durs,g1,g2,nBootstrap,tax,window,step);
        hold on; plot(tax,upperbound,'Color',[.7 .7 .7])
        plot(tax,lowerbound,'Color',[.7 .7 .7])
    end
    
    axis([0 10 0 1]);  mk_Nice_Plot;
    legend(sprintf('BUF (n=%d)',rows),'ARP','MC', 'Location', 'Best')
    title(titletext);
    
    subplot(2,2,1);
    
    xaxmax = max([durs1; durs2]);
    yaxmax = length(durs1);
    
    plot_gamma_hist_fit(durs1,g1);
    %histfit(durs1,10,'gamma')
    xlabel('')
    xlim([0 xaxmax * 1.25]);
    title(sprintf('grouped, n = %d',yaxmax))
    
    text(xaxmax * .8, yaxmax * .3, sprintf('k = %.2f, th = %.2f',g1(1), g1(2)));
    
    subplot(2,2,3);
    plot_gamma_hist_fit(durs2,g2)
    %histfit(durs2,10,'gamma')
    xlabel('');
    xlim([0 xaxmax * 1.25]);
    title(sprintf('split, n = %d',length(durs2)))
    
    text(xaxmax * .8, yaxmax * .3, sprintf('k = %.2f, th = %.2f',g2(1), g2(2)));
    
    
    
    
    
end