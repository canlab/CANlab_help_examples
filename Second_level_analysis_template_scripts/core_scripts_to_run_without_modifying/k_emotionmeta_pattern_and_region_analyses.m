roimask_imagename = 'Buhle_Silvers_2014_Emotion_Regulation_Meta_thresh.img';

%% Add this to access the roimask
if isempty(which(roimask))
    gunzip(which([roimask_imagename, '.gz']))
end

roimask = which(roimask_imagename); % not 1/0

roimask_shortname = 'EmoMetaMask'; % this is a short, unique name identifying this map in saved output

mymetric = 'cosine_similarity'; % 'dotproduct/', 'cosine_similarity', or 'correlation'

% If you hard-code region names for thresholded regions here, they will be
% used in later table/plot output. 10 chars max for display in table object output.
regionnames = {'L vl/dlPFC'    'L STS'    'R vlPFC'    'L IPL'    'R IPL'    'aMCC/pSMA' 'R dlPFC'};

thresh_value = 2.68;  % height threshold for defining discrete ROIs, in raw units
% thresh_k_value = 75;  % extent threshold for defining discrete ROIs
thresh_k_value = 50;  % extent threshold for defining discrete ROIs; Change this to get to the 7 regions.


%% Basic info

printhdr('Pattern of interest and ROIs');

if isempty(roimask)
    fprintf('%s is not on path. Skipping this analysis.\n', roimask_imagename);
    return
else
    printstr(roimask);
    printstr(sprintf('Saving figures named: %s', roimask_shortname));
    printstr(sprintf('Similarity metric: %s', mymetric));
end

%% Load mask, prep thresholded and unthresholded versions
% --------------------------------------------------------------------
roimask_obj = fmri_data(roimask, [], 'noverbose');

roimask_thresh = threshold(roimask_obj, [thresh_value Inf], 'raw-between', 'k', thresh_k_value); % p < .005 equivalent, extent thresholded  0.05 FWE-corr


%% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
whmontage = 5; 
plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------


%% Visualize and save unthresholded mask
% ------------------------------------------------------------------------

axes(o2.montage{whmontage}.axis_handles(5))
title('Unthresholded mask');

r = region(roimask_obj);
o2 = removeblobs(o2);
o2 = addblobs(o2, r);
%o2 = addblobs(o2, r, 'splitcolor', {[0 0 1] [0 1 1] [1 .5 0] [1 1 0]});

figtitle = sprintf('%s_unthresholded', roimask_shortname);
set(gcf, 'Tag', figtitle);
plugin_save_figure;


%% Apply "Pattern of interest" analysis with unthresholded map
% Create figure and plot for contrasts
% ------------------------------------------------------------------------

clear mycon_nothresh
kc = length(DATA_OBJ_CON);

for i = 1:kc
    
    mycon_nothresh{i} = apply_mask(DATA_OBJ_CON{i}, roimask_obj, 'pattern_expression', 'ignore_missing', mymetric);  % weighted average, z-scores are weights
    
end

figtitle = sprintf('%s_pattern_response_nothresh', roimask_shortname);
create_figure(figtitle, 1, 2);

barplot_columns(mycon_nothresh, figtitle, 'colors', DAT.contrastcolors, 'nofig');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);

title(format_strings_for_legend(figtitle))

subplot(1, 2, 2);
barplot_columns(mycon_nothresh, figtitle, 'colors', DAT.contrastcolors, 'nofig', 'noviolin', 'noind');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);

plugin_save_figure;

%% Visualize and save thresholded mask
% ------------------------------------------------------------------------

axes(o2.montage{whmontage}.axis_handles(5))
title('Thresholded mask');

r = region(roimask_thresh);
o2 = removeblobs(o2);
o2 = addblobs(o2, r);

figtitle = sprintf('%s_thresholded', roimask_shortname);
set(gcf, 'Tag', figtitle);
plugin_save_figure;


%% Apply "Pattern of interest" analysis with thresholded map
% Create figure and plot for contrasts
% ------------------------------------------------------------------------

clear mycon_thresh
kc = length(DATA_OBJ_CON);

for i = 1:kc
    
    mycon_thresh{i} = apply_mask(DATA_OBJ_CON{i}, roimask_thresh, 'pattern_expression', 'ignore_missing', mymetric);  % weighted average, z-scores are weights
    
end

figtitle = sprintf('%s_pattern_response_thresh', roimask_shortname);
create_figure(figtitle, 1, 2);

barplot_columns(mycon_thresh, figtitle, 'colors', DAT.contrastcolors, 'nofig');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);

title(format_strings_for_legend(figtitle))

subplot(1, 2, 2);
barplot_columns(mycon_thresh, figtitle, 'colors', DAT.contrastcolors, 'nofig', 'noviolin', 'noind');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);

plugin_save_figure;

%% Print pattern response values
% ------------------------------------------------------------------------

printhdr(sprintf('%s pattern response values unthresholded', roimask_shortname));

varnames =  DAT.contrastnames;
varnames = strrep(varnames, ' - ', '_vs_');
varnames = strrep(varnames, '-', '_vs_');
varnames = strrep(varnames, ' ', '_');

x = cat(2, mycon_nothresh{:});
T = array2table(x, 'VariableNames', varnames);
disp(T);

printhdr(sprintf('%s pattern response values thresholded', roimask_shortname));

x = cat(2, mycon_thresh{:});
T = array2table(x, 'VariableNames', varnames);
disp(T);

%% Show thresholded regions
% ------------------------------------------------------------------------

rois = region(roimask_thresh);

figtitle = sprintf('%s_ROIs', roimask_shortname);

o3 = montage(rois, 'regioncenters', 'nosymmetric', 'colormap');

set(gcf, 'Tag', figtitle);

% Names added automatically if in r.shorttitle, but in this case we have
% named them manually:

k = length(rois);

for i = 1:k
    
    title(o3.montage{i}.axis_handles(1), regionnames{i}); 
    
end
    
plugin_save_figure;

%% Extract ROI data for each thresholded region
% Save extracted data, make table, plot
% ------------------------------------------------------------------------

% Get names
if exist('regionnames', 'var') && iscell(regionnames)
    if length(regionnames) ~= length(rois)
        error('regionnames is not the same length as thresholded roi region object.');
    else
        for i = 1:length(rois)
            rois(i).shorttitle = regionnames{i};
        end
    end
end

% for Conditions
% ------------------------------------------------------------------------

printhdr(sprintf('%s thresholded ROI t-tests by condition', roimask_shortname));

[roi_table_conditions, rois_with_condition_data] = ttest_table_by_condition(rois, DATA_OBJ, 'conditions', DAT.conditions);

disp(roi_table_conditions)

savematfilename = [roimask_shortname '_regions_with_condition_data'];
savename = fullfile(resultsdir, savematfilename);

fprintf('Saving: %s\n', savematfilename);
save(savename, 'rois_with_condition_data', 'roi_table_conditions');


%% Extract ROI data, table for Contrasts
% ------------------------------------------------------------------------

% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end
% ------------------------------------------------------------------------


printhdr(sprintf('%s thresholded ROI t-tests by contrast', roimask_shortname));

[roi_table_contrasts, rois_with_contrast_data] = ttest_table_by_condition(rois, DATA_OBJ_CON, 'conditions', DAT.contrastnames);

disp(roi_table_contrasts)

savematfilename = [roimask_shortname '_regions_with_contrast_data'];
savename = fullfile(resultsdir, savematfilename);

fprintf('Saving: %s\n', savematfilename);
save(savename, 'rois_with_contrast_data', 'roi_table_contrasts');

%% Plot ROIs for each contrast
% ------------------------------------------------------------------------

nrows = ceil(kc ./ 3);
ncols = ceil(kc ./ nrows);

figtitle = sprintf('%s_ROI_t_tests_by_contrast', roimask_shortname);

create_figure(figtitle, nrows, ncols);

roidatafun = @(i, j) rois_with_contrast_data(j).dat(:, i);

nregions = length(rois_with_contrast_data);

myfontsize = get_font_size(kc);
myaxislabels = format_strings_for_legend(regionnames);
mypointsize = get_point_size(kc, nregions);

clear axh my_contrast_data

for i = 1:kc
    
    for j = 1:nregions
        
        my_contrast_data{j} = roidatafun(i, j);
        
    end
    
    printstr(DAT.contrastnames{i});
    mycolor = repmat(DAT.contrastcolors(i), nregions); 
    
    axh(i) = subplot(nrows, ncols, i);
    
    handles = barplot_columns(my_contrast_data, 'colors', mycolor, 'names', myaxislabels, 'nofig');
    
    title(DAT.contrastnames{i});
    xlabel('Region');
    ylabel('ROI mean');
    
end

if length(axh) > 1
    
kludgy_fix_for_y_axis(axh);

end

plugin_save_figure;




%%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% Sub-functions
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

%% Get font size
% -------------------------------------------------------------------------

function myfontsize = get_font_size(k)
% get font size
if k > 10
    myfontsize = 8;
elseif k > 8
    myfontsize = 9;
elseif k > 5
    myfontsize = 12;
elseif k > 2
    myfontsize = 14;
else
    myfontsize = 18;
end
end


%% Fix y-axis values
% -------------------------------------------------------------------------

function kludgy_fix_for_y_axis(axh)
% Matlab is having some trouble with axes for unknown reasons

axis2 = get(axh(2), 'Position');

% re-set axis 1
mypos = get(axh(1), 'Position');
mypos([2 4]) = axis2([2 4]);  % re-set y start and height
set(axh(1), 'Position', mypos);

end


%% set point size
% -------------------------------------------------------------------------
function ptsize = get_point_size(n, k)

ptsize = 12 ./ (.5*n*log(1 + k));

end

% Not used - post hoc setting
function set_point_size(handles, n, k)

myhandles = handles.point_han(:);
myhandles(cellfun(@isempty, myhandles)) = [];
ptsize = get_point_size(n, k);
ptfun = @(x) set(x, 'MarkerSize', ptsize);
cellfun(ptfun, myhandles);

end