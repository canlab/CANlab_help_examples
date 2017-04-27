mymetric = 'cosine_sim';    % 'dotproduct' or 'cosine_sim'

% Controlling for group admin order covariate (mean-centered by default)

group = [];
if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'group')
    group = DAT.BETWEENPERSON.group; % empty for no variable to control/remove
end


% subregion names
posnames = {'vermis'    'rIns'    'rV1'    'rThal'    'lIns'    'rdpIns'    'rS2_Op'    'dACC'};
negnames = {'rLOC'    'lLOC'    'rpLOC'    'pgACC'    'lSTS'    'rIPL'    'PCC'};

k = length(DAT.conditions);

clear negdat posdat
switch mymetric
    
    case 'cosine_sim'
        
        negdat = DAT.NPSsubregions.npsneg_by_region_cosinesim;
        posdat = DAT.NPSsubregions.npspos_by_region_cosinesim;
        
        % NOTE: may not be defined yet for cosine_sim
        posdatc = DAT.NPSsubregions.npspos_by_region_contrasts;
        negdatc = DAT.NPSsubregions.npsneg_by_region_contrasts;
        
    case 'dotproduct'
        
        negdat = DAT.NPSsubregions.npsneg_by_region;
        posdat = DAT.NPSsubregions.npspos_by_region;
        
        posdatc = DAT.NPSsubregions.npspos_by_region_contrasts;
        negdatc = DAT.NPSsubregions.npsneg_by_region_contrasts;
        
end

np = length(posnames);
colors = seaborn_colors(np + length(negnames));
poscolors = colors(1:np);
negcolors = colors(np+1:end);

%% NPS Subregions

printhdr('NPS subregions');
% ------------------------------------------------------------------------

figtitle = 'NPS subregions raw data';
create_figure(figtitle, 2, k);

for i = 1:k
    
    printhdr(DAT.conditions{i});
    
    subplot(2, k, i)
    
    %hh = tor_polar_plot({[DAT.NPSsubregions.posdat{i} DAT.NPSsubregions.posdat{i} - DAT.NPSsubregions.stepos{i} DAT.NPSsubregions.posdat{i} + DAT.NPSsubregions.stepos{i}]}, [DAT.colors(i) DAT.colors(i) DAT.colors(i)], {posnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    barplot_columns(posdat{i}, figtitle, 'colors', poscolors, 'noviolin', 'noind', 'nofig', 'names', posnames, 'covs', group, 'wh_reg', 0);
    
    if i == 1, ylabel('Positive regions'), end
    title(DAT.conditions{i});
    
    subplot(2, k, k + i)
    
    %hh = tor_polar_plot({[DAT.NPSsubregions.negdat{i} DAT.NPSsubregions.negdat{i} - DAT.NPSsubregions.steneg{i} DAT.NPSsubregions.negdat{i} + DAT.NPSsubregions.steneg{i}]}, [DAT.colors(i) DAT.colors(i) DAT.colors(i)], {negnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    barplot_columns(negdat{i}, figtitle, 'colors', negcolors, 'noviolin', 'noind', 'nofig', 'names', negnames, 'covs', group, 'wh_reg', 0);
    
    if i == 1, ylabel('Negative regions'), end
    
end


savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);
drawnow, snapnow



%% NPS Subregions: Contrasts

printhdr('NPS contrasts subregions');
% ------------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

figtitle = 'Contrasts on NPS subregions raw data';
create_figure(figtitle, 2, kc);

for i = 1:kc
    
    printhdr(DAT.contrastnames{i});
    
    subplot(2, kc, i)
    
    %hh = tor_polar_plot(mydat, [DAT.contrastcolors(i) DAT.contrastcolors(i) DAT.contrastcolors(i)], {posnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    barplot_columns(posdatc{i}, figtitle, 'colors', poscolors, 'noviolin', 'noind', 'nofig', 'names', posnames, 'covs', group, 'wh_reg', 0);
    
    if i == 1, ylabel('Positive regions'), end
    title(DAT.contrastnames{i});
    
    subplot(2, kc, kc + i)
    
    %hh = tor_polar_plot(mydat, [DAT.contrastcolors(i) DAT.contrastcolors(i) DAT.contrastcolors(i)], {negnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    barplot_columns(negdatc{i}, figtitle, 'colors', negcolors, 'noviolin', 'noind', 'nofig', 'names', negnames, 'covs', group, 'wh_reg', 0);
    
    if i == 1, ylabel('Negative regions'), end
    
end


savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);
drawnow, snapnow

