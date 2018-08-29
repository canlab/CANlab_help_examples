%% Example: Mapping images to an atlas and visualizing them with a river plot
% Often, we would like to map a results image (e.g., t-map or functional connectivity map)
% to an atlas to help localize where the activity is. The table() method is one way to do this,
% as it auto-labels regions using an atlas.  Here, we will explore another
% way of doing this, using river plots.
%
% The riverplot method creates a ribbon plot showing similarities between one
% set of spatial maps (e.g., here, a single results map) and another (here, the regions that
% comprise a standard cerebellar brain atlas).
%
% We'll load the cerebellar atlas, load a set of functional connectivity
% maps from the Buckner Lab 1,000-person functional connectivity dataset,
% and visualize the relationships between them.
%
% In addition to serving as an example of how to use the code, the results
% are informative for localizing which anatomical parts of the cerebellum
% are mapped to particular resting-state networks.
%
% Tor Wager, Aug 2018

% First, we'll load the images and define some names and colors
% -------------------------------------------------------------------

% Load the cerebellar atlas (requires the Neuroimaging_Pattern_Masks repository)
cblm = load_atlas('cerebellum');

[fc, fc_names] = load_image_set('bucknerlab_wholebrain');

% Add labels to image_names (used in riverplot.m method)
% -------------------------------------------------------------------

fc.image_names = fc_names';
cblm.image_names = cblm.labels;

% Define Colors
% -------------------------------------------------------------------

n = length(fc_names);
fc_colors = seaborn_colors(n);                          % for initial montage
fc_color = {[.5 0 1]};                                  % for riverplot
cblm_colors = colorcube_colors(num_regions(cblm));      % for riverplot

% Some display helper functions
dashes = '----------------------------------------------';
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);


%% View the atlas to see what it looks like
% -------------------------------------------------------------------
% montage(cblm) will also work here. This plot is a little nicer because
% it will show both the atlas and the networks side by side

o2 = canlab_results_fmridisplay([], 'multirow', 2);

o2 = montage(cblm, o2, 'wh_montages', 1:2);
title_montage(o2, 2, 'Cerebellar atlas');

title_montage(o2, 4, 'Functional Networks');

for i = 1:n
    
    myfc = get_wh_image(fc, i);
    o2 = addblobs(o2, region(myfc), 'wh_montages', 3:4, 'color', fc_colors{i});
    
end

% Get regions (for slice montage)
r = atlas2region(cblm);

%% Create a river plot for the overall relationship, and plot the matrix
% The ribbon thicknesses in the riverplot are proportional to the cosine
% similarity between the network map and the region.

create_figure('riverplot');

[layer1, layer2, ribbons, sim_matrix] = riverplot(fc, 'layer2', cblm, 'colors1', fc_colors, 'colors2', cblm_colors);

drawnow, snapnow

%% Visualize the matrix and identify the top network for each region
% This is a bit crowded. Let's view the matrix:

create_figure('matrix', 1, 2);
set(gcf, 'Position', [182   232   670   723]);

imagesc(sim_matrix)

set(gca, 'XTick', 1:n, 'XTickLabel', fc_names, ...
    'YTick', 1:num_regions(cblm), 'YTickLabel', format_strings_for_legend(cblm.labels), ...
    'XTickLabelRotation', 45, 'Ydir', 'reverse');

colorbar

% Change the colormap to be more intuitive
cm = colormap_tor([1 1 1], [1 0 0]);
colormap(cm)

title('Cosine similarity')

subplot(1, 2, 2)

sim_centered = zscore(zscore(sim_matrix)')';

sim_centered(sim_centered < 0) = 0;         % threshold to show only top values

imagesc(sim_centered)

set(gca, 'XTick', 1:n, 'XTickLabel', fc_names, ...
    'YTick', 1:num_regions(cblm), 'YTickLabel', format_strings_for_legend(cblm.labels), ...
    'XTickLabelRotation', 45, 'Ydir', 'reverse');

colorbar


title('Relative (double Z-scored) similarity')

drawnow, snapnow

% Get best region and make a table

[~, wh_max] = max(sim_centered');

Anatomical_Region = format_strings_for_legend(cblm.labels');
Funct_Network = format_strings_for_legend(fc_names(wh_max))';

results_table = table(Anatomical_Region, Funct_Network);
results_table = sortrows(results_table, 'Funct_Network');

disp(results_table)

%% Create a river plot and slice montage for each network
% The ribbon thicknesses in the riverplot are proportional to the cosine
% similarity between the network map and the region.

create_figure('riverplot');

% for each functional connectivity network, make a riverplot and a slice
% montage showing the most similar cerebellar regions
% -------------------------------------------------------------------

for i = 1:size(fc.dat, 2)
    
    % Select a functional connectivity network to plot
    % -------------------------------------------------------------------
    
    myfc = get_wh_image(fc, i);
    
    % riverplot
    % -------------------------------------------------------------------
    
    [layer1, layer2, ribbons, sim_matrix] = riverplot(myfc, 'layer2', cblm, 'colors1', fc_color, 'colors2', cblm_colors);
    
    % make the slice montage display
    % -------------------------------------------------------------------
    
    o2 = canlab_results_fmridisplay([], 'multirow', 1, 'nofigure');
    
    % remove some axes that we don't need
    wh_delete = 6:11;
    delete(o2.montage{2}.axis_handles(wh_delete));
    o2.montage{2}.axis_handles(wh_delete) = [];
    
    % show the top regions on the slice montage
    % -------------------------------------------------------------------
    
    
    thr = sort(sim_matrix, 'descend');
    thr = thr(7); % greater than thr is top 6 regions
    
    %wh = sim_matrix > .02;
    wh = sim_matrix > thr;
    
    myr = r(wh);
    mycolors = cblm_colors(wh);
    
    for j = 1:length(myr)
        o2 = addblobs(o2, myr(j), 'trans', 'transvalue', .7, 'color', mycolors{j}, 'noverbose');
    end
    
    drawnow, snapnow
    
    % Print summary of top regions
    % -------------------------------------------------------------------
    
    printhdr(fc.image_names{i})
    disp(char(myr.shorttitle))
    
end % network loop



