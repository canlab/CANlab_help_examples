roimask_imagename = 'v4-topics-100_25_inhibition_response_control_pFgA_z_FDR_0.01.nii';

if ~exist(which(roimask_imagename), 'file')
    try
    roimask = gunzip([roimask_imagename '.gz']);
    roimask_imagename = roimask{1};
    catch
    end
end

% this map is similar but with fewer unique regions:
%roimask_imagename = gunzip('v4-topics-100_49_conflict_interference_control_pFgA_z_FDR_0.01.nii.gz');

roimask = which(roimask_imagename); % not 1/0

roimask_shortname = 'Neurosynth_Inhib_RI'; % this is a short, unique name identifying this map in saved output

mymetric = 'cosine_similarity'; % 'dotproduct', 'cosine_similarity', or 'correlation'

if ~exist(roimask, 'file')
    fprintf('Cannot find file: %s\nSkipping.\n', roimask_imagename);
end

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

disp('Unthresholded:')
r_nothr = region(roimask_obj);

desc = descriptives(roimask_obj);

thresh_value = double(desc.prctile_vals(desc.prctiles == 1)); % first percentile; height threshold for defining discrete ROIs, in raw units
thresh_k_value = 50;  % extent threshold for defining discrete ROIs


roimask_thresh = threshold(roimask_obj, [thresh_value Inf], 'raw-between', 'k', thresh_k_value); % p < .005 equivalent, extent thresholded  0.05 FWE-corr

fprintf('Thresholded at %3.3f and k = %3.3f contiguous\n', thresh_value, thresh_k_value)

r_thr = region(roimask_thresh);

% Label the regions, print a table
[rpos, rneg] = table(r_thr);
r_thr = [rpos rneg];

% If you hard-code region names for thresholded regions here, they will be
% used in later table/plot output. 10 chars max for display in table object output.
regionnames = {}; %{'L vl/dlPFC'    'L STS'    'R vlPFC'    'L IPL'    'R IPL'    'aMCC/pSMA' 'R dlPFC'};

for i = 1:length(r_thr)
    
    regionnames{i} = r_thr(i).shorttitle; %sprintf('R%d', i);
    
end

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

o2 = removeblobs(o2);
o2 = addblobs(o2, r_nothr);
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

barplot_columns(mycon_nothresh, figtitle, 'colors', DAT.contrastcolors, 'nofig', 'names', DAT.contrastnames);
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);

title(format_strings_for_legend(figtitle))

subplot(1, 2, 2);
barplot_columns(mycon_nothresh, figtitle, 'colors', DAT.contrastcolors, 'nofig', 'noviolin', 'noind', 'names', DAT.contrastnames);
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

barplot_columns(mycon_thresh, figtitle, 'colors', DAT.contrastcolors, 'nofig', 'names', DAT.contrastnames);
set(gca, 'XTickLabelRotation', 45);

title(format_strings_for_legend(figtitle))

subplot(1, 2, 2);
barplot_columns(mycon_thresh, figtitle, 'colors', DAT.contrastcolors, 'nofig', 'noviolin', 'noind', 'names', DAT.contrastnames);
set(gca, 'XTickLabelRotation', 45);

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

% First figure: zoomed-in

figtitle = sprintf('%s_ROIs', roimask_shortname);

o3 = montage(r_thr, 'regioncenters', 'nosymmetric', 'colormap');

set(gcf, 'Tag', figtitle);

% Names now added automatically 
% k = length(r_thr);
% 
% for i = 1:k
%     
%     title(o3.montage{i}.axis_handles(1), regionnames{i}); 
%     
% end
    
plugin_save_figure;


%% Extract ROI data for each thresholded region
% Save extracted data, make table, plot
% ------------------------------------------------------------------------

% Get names
if exist('regionnames', 'var') && iscell(regionnames)
    if length(regionnames) ~= length(r_thr)
        error('regionnames is not the same length as thresholded roi region object.');
    else
        for i = 1:length(r_thr)
            r_thr(i).shorttitle = regionnames{i};
        end
    end
end

% for Conditions
% ------------------------------------------------------------------------

printhdr(sprintf('%s thresholded ROI t-tests by condition', roimask_shortname));

[roi_table_conditions, rois_with_condition_data] = ttest_table_by_condition(r_thr, DATA_OBJ, 'conditions', DAT.conditions);

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

[roi_table_contrasts, rois_with_contrast_data] = ttest_table_by_condition(r_thr, DATA_OBJ_CON, 'conditions', DAT.contrastnames);

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
    mycolor = repmat(DAT.contrastcolors(i), 1, nregions); 
    
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