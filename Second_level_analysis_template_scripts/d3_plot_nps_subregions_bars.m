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

myfontsize = get_font_size(k); % This is a function defined below; ok in Matlab 2016 or later

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

% extend fig a bit
mypos = get(gcf, 'Position');
mypos(2) = mypos(2) - 150; mypos(4) = mypos(4) + 150;
set(gcf, 'Position', mypos);

clear axh axh2

for i = 1:k
    
    printhdr(DAT.conditions{i});
    
    axh(i) = subplot(2, k, i);
    
    %hh = tor_polar_plot({[DAT.NPSsubregions.posdat{i} DAT.NPSsubregions.posdat{i} - DAT.NPSsubregions.stepos{i} DAT.NPSsubregions.posdat{i} + DAT.NPSsubregions.stepos{i}]}, [DAT.colors(i) DAT.colors(i) DAT.colors(i)], {posnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    barplot_columns(posdat{i}, figtitle, 'colors', poscolors, 'noviolin', 'noind', 'nofig', 'names', posnames, 'covs', group, 'wh_reg', 0);
    
    set(gca, 'FontSize', myfontsize);
    
    xlabel('');
    if i == 1, ylabel('Positive regions'), else, ylabel(' '); end
    title(DAT.conditions{i});
    
    axh2(i) = subplot(2, k, k + i);
    
    %hh = tor_polar_plot({[DAT.NPSsubregions.negdat{i} DAT.NPSsubregions.negdat{i} - DAT.NPSsubregions.steneg{i} DAT.NPSsubregions.negdat{i} + DAT.NPSsubregions.steneg{i}]}, [DAT.colors(i) DAT.colors(i) DAT.colors(i)], {negnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    barplot_columns(negdat{i}, figtitle, 'colors', negcolors, 'noviolin', 'noind', 'nofig', 'names', negnames, 'covs', group, 'wh_reg', 0);
    
    set(gca, 'FontSize', myfontsize);
    
    xlabel('');
    if i == 1, ylabel('Negative regions'), else, ylabel(' '); end
    
    drawnow
end

kludgy_fix_for_y_axis(axh, axh2, k);

plugin_save_figure;
%close



%% NPS Subregions: Contrasts

printhdr('NPS contrasts subregions');
% ------------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

myfontsize = get_font_size(kc);

figtitle = 'Contrasts on NPS subregions raw data';
create_figure(figtitle, 2, kc);

% extend fig a bit
if kc > 4
    mypos = get(gcf, 'Position');
    mypos(2) = mypos(2) - 150; mypos(4) = mypos(4) + 150;
    set(gcf, 'Position', mypos);
end

clear axh axh2

for i = 1:kc
    
    printhdr(DAT.contrastnames{i});
    
    axh(i) = subplot(2, kc, i);
    
    %hh = tor_polar_plot(mydat, [DAT.contrastcolors(i) DAT.contrastcolors(i) DAT.contrastcolors(i)], {posnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    barplot_columns(posdatc{i}, figtitle, 'colors', poscolors, 'noviolin', 'noind', 'nofig', 'names', posnames, 'covs', group, 'wh_reg', 0);
    
    set(gca, 'FontSize', myfontsize);
    
    xlabel('');
    if i == 1, ylabel('Positive regions'), else, ylabel(' '); end
    title(DAT.contrastnames{i});
    
    axh2(i) = subplot(2, kc, kc + i);
    
    %hh = tor_polar_plot(mydat, [DAT.contrastcolors(i) DAT.contrastcolors(i) DAT.contrastcolors(i)], {negnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    barplot_columns(negdatc{i}, figtitle, 'colors', negcolors, 'noviolin', 'noind', 'nofig', 'names', negnames, 'covs', group, 'wh_reg', 0);
    
    set(gca, 'FontSize', myfontsize);
    
    xlabel('');
    if i == 1, ylabel('Negative regions'), else, ylabel(' '); end
    
    drawnow
end

kludgy_fix_for_y_axis(axh, axh2, kc);

plugin_save_figure;
%close


%%
function myfontsize = get_font_size(k)
% get font size
if k > 12
    myfontsize = 6;
elseif k > 10
    myfontsize = 8;
elseif k > 8
    myfontsize = 9;
elseif k > 6
    myfontsize = 10;
elseif k > 5
    myfontsize = 12;
elseif k > 2
    myfontsize = 14;
else
    myfontsize = 18;
end
end

%%
function kludgy_fix_for_y_axis(axh, axh2, k)
% Matlab is having some trouble with axes for unknown reasons

% 2 x k axes

axis1 = get(axh(1), 'Position');

for i = 2:k
    
    mypos = get(axh(i), 'Position');
    mypos([2 4]) = axis1([2 4]);  % re-set y start and height
    set(axh(i), 'Position', mypos);
    
end

% adjust x for bottom row
for i = 1:length(axh)
    
    referencepos = get(axh(i), 'Position');
    mypos = get(axh2(i), 'Position');
    mypos([1 3]) = referencepos([1 3]);  % re-set x start and extent
    set(axh2(i), 'Position', mypos);
    
end


end

