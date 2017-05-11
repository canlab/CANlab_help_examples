
% subregion names
posnames = {'vermis'    'rIns'    'rV1'    'rThal'    'lIns'    'rdpIns'    'rS2_Op'    'dACC'};
negnames = {'rLOC'    'lLOC'    'rpLOC'    'pgACC'    'lSTS'    'rIPL'    'PCC'};

%% NPS Subregions

printhdr('NPS subregions');
% ------------------------------------------------------------------------

figtitle = 'NPS subregions raw data';
create_figure(figtitle, 2, k);

clear posdat negdat spos sneg xx
for i = 1:k

    xx{i} = [DAT.NPSsubregions.posdat{i}; ...
        DAT.NPSsubregions.posdat{i} + DAT.NPSsubregions.stepos{i}; ...
        DAT.NPSsubregions.posdat{i} - DAT.NPSsubregions.stepos{i}; ...
        DAT.NPSsubregions.negdat{i}; DAT.NPSsubregions.negdat{i} + DAT.NPSsubregions.steneg{i}; 
        DAT.NPSsubregions.negdat{i} - DAT.NPSsubregions.steneg{i}];
    
end

% Get range for plot
xx = cat(1, xx{:});
myrange = [min(xx) max(xx)];

for i = 1:k
    
    subplot(2, k, i)
    
    hh = tor_polar_plot({[DAT.NPSsubregions.posdat{i} DAT.NPSsubregions.posdat{i} - DAT.NPSsubregions.stepos{i} DAT.NPSsubregions.posdat{i} + DAT.NPSsubregions.stepos{i}]}, [DAT.colors(i) DAT.colors(i) DAT.colors(i)], {posnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    if i == 1, ylabel('Positive regions'), end
    title(DAT.conditions{i});
    
    subplot(2, k, k + i)
    
    hh = tor_polar_plot({[DAT.NPSsubregions.negdat{i} DAT.NPSsubregions.negdat{i} - DAT.NPSsubregions.steneg{i} DAT.NPSsubregions.negdat{i} + DAT.NPSsubregions.steneg{i}]}, [DAT.colors(i) DAT.colors(i) DAT.colors(i)], {negnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    if i == 1, ylabel('Negative regions'), end
    
end

drawnow, snapnow

savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);



%% NPS Subregions: Contrasts

printhdr('NPS contrasts subregions');
% ------------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

figtitle = 'Contrasts on NPS subregions raw data';
create_figure(figtitle, 2, kc);

clear xx

for i = 1:kc

    xx{i} = [DAT.NPSsubregions.posdat_contrasts{i}; ...
        DAT.NPSsubregions.posdat_contrasts{i} + DAT.NPSsubregions.stepos{i}; ...
        DAT.NPSsubregions.posdat_contrasts{i} - DAT.NPSsubregions.stepos{i}; ...
        DAT.NPSsubregions.negdat_contrasts{i}; ...
        DAT.NPSsubregions.negdat_contrasts{i} + DAT.NPSsubregions.steneg{i};
        DAT.NPSsubregions.negdat_contrasts{i} - DAT.NPSsubregions.steneg{i}];
    
    
end

% Get range for plot
xx = cat(1, xx{:});
myrange = [min(xx) max(xx)];

for i = 1:kc
    
    subplot(2, kc, i)
    
    mydat = {[DAT.NPSsubregions.posdat_contrasts{i} DAT.NPSsubregions.posdat_contrasts{i} - DAT.NPSsubregions.stepos{i} ...
             DAT.NPSsubregions.posdat_contrasts{i} + DAT.NPSsubregions.stepos{i}]};
         
    hh = tor_polar_plot(mydat, [DAT.contrastcolors(i) DAT.contrastcolors(i) DAT.contrastcolors(i)], {posnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    if i == 1, ylabel('Positive regions'), end
    title(DAT.contrastnames{i});
    
    subplot(2, kc, kc + i)
    
    mydat = {[DAT.NPSsubregions.negdat_contrasts{i} DAT.NPSsubregions.negdat_contrasts{i} - DAT.NPSsubregions.steneg{i} ...
             DAT.NPSsubregions.negdat_contrasts{i} + DAT.NPSsubregions.steneg{i}]};
         
    hh = tor_polar_plot(mydat, [DAT.contrastcolors(i) DAT.contrastcolors(i) DAT.contrastcolors(i)], {negnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    if i == 1, ylabel('Negative regions'), end
    
end

plugin_save_figure;
close


