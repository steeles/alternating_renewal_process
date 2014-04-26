%% function mk_Nice_Plot(h_title,h_xlabel,h_ylabel,h_legend)

function mk_Nice_Plot(varargin)

line = get(gca, 'Children');
set(line,'LineWidth',2)
%set(gca,'box','off')

    set(gca,'FontName','Arial', ...
    'FontSize',18, ...
    'FontWeight','bold', ...
    'LineWidth',2);
    
set(gca,'box','off')
if nargin>=1
        
        h_t = varargin{1};
    set(h_t,'FontName','Arial', ...
    'FontSize',16, ...
    'FontWeight','bold');
end

if nargin >=2
    h_x = varargin{2};        
    set(h_x,'FontName','Arial', ...
    'FontSize',16, ...
    'FontWeight','bold');
end

if nargin >=3

    h_y = varargin{3};
    set(h_y,'FontName','Arial', ...
    'FontSize',16, ...
    'FontWeight','bold');
    

                      
end

if nargin >=4
    h_l = varargin{4};
    set(h_l,'FontName','Arial', ...
    'FontSize',16, ...    
    'FontWeight','normal');
end

if nargin >=5
    line = get(gca, 'Children');
    set(line,'LineWidth',1)
end


set(gcf, 'PaperPositionMode', 'auto');

end

    