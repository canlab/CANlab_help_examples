k = length(DAT.conditions);

% subregion names
posnames = {'vermis'    'rIns'    'rV1'    'rThal'    'lIns'    'rdpIns'    'rS2_Op'    'dACC'};
negnames = {'rLOC'    'lLOC'    'rpLOC'    'pgACC'    'lSTS'    'rIPL'    'PCC'};

%% NPS Response
% ------------------------------------------------------------------------

printhdr('NPS responses by condition');
% ------------------------------------------------------------------------

% Raw/Unscaled data NPS responses

figtitle = 'NPS response raw data';
create_figure('nps', 1, 2);

for i = 1:k
    
    [DAT.npsresponse(i), ~, ~, DAT.npspos_by_region(i), DAT.npsneg_by_region(i)] = apply_nps(DATA_OBJ{i}, 'noverbose', 'notables');
    
    DAT.npsresponse_cosinesim(i) = apply_nps(DATA_OBJ{i}, 'noverbose', 'notables', 'cosine_similarity');
end

% First plot
printstr('NPS by condition, dot product')
printstr(dashes)
disp(DAT.conditions)
barplot_columns(DAT.npsresponse, figtitle, 'colors', DAT.colors, 'dolines', 'nofig');
set(gca, 'XTickLabel', DAT.conditions, 'XTickLabelRotation', 45, 'FontSize', 14);
title('NPS - dot product');

subplot(1, 2, 2)
printstr('NPS by condition, cosine similarity')
printstr(dashes)
disp(DAT.conditions)
barplot_columns(DAT.npsresponse_cosinesim, figtitle, 'colors', DAT.colors, 'dolines', 'nofig');
set(gca, 'XTickLabel', DAT.conditions, 'XTickLabelRotation', 45, 'FontSize', 14);
title('NPS - cosine similarity');

savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

%% NPS Subregions

printhdr('NPS subregions');
% ------------------------------------------------------------------------

figtitle = 'NPS subregions raw data';
create_figure('nps subregions', 2, k);

clear posdat negdat spos sneg xx
for i = 1:k
    
    % Get averages
    posdat{i} = nanmean(DAT.npspos_by_region{i})'; % mean across subjects
    spos{i} = ste(DAT.npspos_by_region{i})'; % ste
    
    negdat{i} = nanmean(DAT.npsneg_by_region{i})'; % mean across subjects
    sneg{i} = ste(DAT.npsneg_by_region{i})'; % ste
    
    xx{i} = [posdat{i}; posdat{i} + spos{i}; posdat{i} - spos{i}; negdat{i}; negdat{i} + sneg{i}; negdat{i} - sneg{i}];
    
end

% Get range for plot
xx = cat(1, xx{:});
myrange = [min(xx) max(xx)];

for i = 1:k
    
    subplot(2, k, i)
    
    hh = tor_polar_plot({[posdat{i} posdat{i} - spos{i} posdat{i} + spos{i}]}, [DAT.colors(i) DAT.colors(i) DAT.colors(i)], {posnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    if i == 1, ylabel('Positive regions'), end
    title(DAT.conditions{i});
    
    subplot(2, k, k + i)
    
    hh = tor_polar_plot({[negdat{i} negdat{i} - sneg{i} negdat{i} + sneg{i}]}, [DAT.colors(i) DAT.colors(i) DAT.colors(i)], {negnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    if i == 1, ylabel('Negative regions'), end
    
end

drawnow, snapnow

savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);


%% NPS Contrasts
% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end
% ------------------------------------------------------------------------

printhdr('NPS contrasts - unscaled data');

% cell sizes
% sz = cellfun(@size, DAT.npsresponse, repmat({1}, 1, size(DAT.npsresponse, 2)), 'UniformOutput', false);
% sz = cat(1, sz{:});
k = length(DAT.conditions);

DAT.npscontrasts = {};

% npsdat = cat(2, DAT.npsresponse{:}); DAT.npscontrasts = npsdat * DAT.contrasts';
% Apply contrasts a different way, allowing for differences across number of images in different sets

for c = 1:size(DAT.contrasts, 1)
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    DAT.npscontrasts{c} = cat(2, DAT.npsresponse{wh}) * mycontrast(wh)';
    
    % subregions
    DAT.npspos_by_region_contrasts{c} = zeros(size(DAT.npspos_by_region{wh(1)}));
    DAT.npsneg_by_region_contrasts{c} = zeros(size(DAT.npsneg_by_region{wh(1)}));
    
    for j = 1:length(wh)
        
        DAT.npspos_by_region_contrasts{c} = DAT.npspos_by_region_contrasts{c} + DAT.npspos_by_region{wh(j)} * mycontrast(wh(j));
        DAT.npsneg_by_region_contrasts{c} = DAT.npsneg_by_region_contrasts{c} + DAT.npsneg_by_region{wh(j)} * mycontrast(wh(j));
        
    end
end

figtitle = 'NPS contrasts unscaled data';
create_figure('nps');

barplot_columns(DAT.npscontrasts, figtitle, 'colors', DAT.contrastcolors, 'nofig');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

%% NPS Subregions: Contrasts

printhdr('NPS subregions');
% ------------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

figtitle = 'Contrasts on NPS subregions raw data';
create_figure('nps subregions', 2, kc);

clear posdat negdat spos sneg xx
for i = 1:kc
    
    % Get averages
    posdat{i} = nanmean(DAT.npspos_by_region_contrasts{i})'; % mean across subjects
    spos{i} = ste(DAT.npspos_by_region_contrasts{i})'; % ste
    
    negdat{i} = nanmean(DAT.npsneg_by_region_contrasts{i})'; % mean across subjects
    sneg{i} = ste(DAT.npsneg_by_region_contrasts{i})'; % ste
    
    xx{i} = [posdat{i}; posdat{i} + spos{i}; posdat{i} - spos{i}; negdat{i}; negdat{i} + sneg{i}; negdat{i} - sneg{i}];
    
end

% Get range for plot
xx = cat(1, xx{:});
myrange = [min(xx) max(xx)];

for i = 1:kc
    
    subplot(2, kc, i)
    
    hh = tor_polar_plot({[posdat{i} posdat{i} - spos{i} posdat{i} + spos{i}]}, [DAT.contrastcolors(i) DAT.contrastcolors(i) DAT.contrastcolors(i)], {posnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    if i == 1, ylabel('Positive regions'), end
    title(DAT.contrastnames{i});
    
    subplot(2, kc, kc + i)
    
    hh = tor_polar_plot({[negdat{i} negdat{i} - sneg{i} negdat{i} + sneg{i}]}, [DAT.contrastcolors(i) DAT.contrastcolors(i) DAT.contrastcolors(i)], {negnames}, 'nofigure', 'nonneg', 'fixedrange', myrange);
    
    if i == 1, ylabel('Negative regions'), end
    
end

drawnow, snapnow

savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);


    
    
%% Save results
% ------------------------------------------------------------------------
savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, '-append', 'DAT');


