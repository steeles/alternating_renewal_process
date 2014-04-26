function h = bigFigure;

h = figure; screenSize = get(0,'Screensize');
set(gcf, 'Position', screenSize); % Maximize figure