function h = bigFigure

h = figure; screenSize = get(0,'Screensize');
set(gcf, 'Position', [1 1 1080 720]);
%set(gcf, 'Position', screenSize*.8); % Maximize figure