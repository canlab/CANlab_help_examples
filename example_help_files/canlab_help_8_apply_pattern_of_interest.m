
% Load a dataset of 21 subjects
% Several fmri_data objects are included. Two of interest are datasets for 
% Nback vs. Rest contrast and 3-back vs. 2-back contrast. Each dataset
% contains one contrast image per person (N = 21 images).

load('/Users/torwager/Google Drive/SHARED_DATASETS_gdrive/A_Multi_lab_world_map/2016_CORT_Nback_Stress/data/CORT_WM_data.mat')

% Load a "pattern of interest" from a Neurosynth 'reverse inference'
% analysis of working memory. This is in the Neuroimaging_pattern_masks
% repository, so this will only work if you have this repository with
% subfolders on your path.

poi = which('working_memory_pFgA_z_FDR_0.01.nii.gz');
poi = fmri_data(poi);

% Calculate pattern response (expression) for Nback vs. Rest

pexp_new_wm = apply_mask(dat_nback_vs_rest, poi, 'pattern_expression', 'ignore_missing');

% Add results for 3-back vs. 2-back

pexp_new_wm(:, 2) = apply_mask(dat_3back_vs_2back, poi, 'pattern_expression', 'ignore_missing');

% compare to previous result from several years ago (possibly slightly different neurosynth pattern)
% [pexp_wmmeta_nback_vs_rest./norm(pexp_wmmeta_nback_vs_rest) pexp_new_wm./norm(pexp_new_wm)]
% corrcoef(ans) % correlation is 0.96, so close enough despite likely small diffs in neurosynth maps from different sources.

% normalize just to equate scale across the two datasets (vs. rest and 3 vs 2)
% This will not affect inferential statistics (P-values) or effect sizes

for i = 1:2
    pexp_new_wm(:, i) = pexp_new_wm(:, i) ./ norm(pexp_new_wm(:, i));
end

%% Plot the individuals.  
% This also gives us effect sizes (Cohen's d) for each condition.

create_figure('Pattern expression');
barplot_columns(pexp_new_wm, 'nofig', 'nobars', 'colors', {[.3 .3 .5] [.3 .3 .5]}, 'names', {'N-Back vs. Rest' '3-Back vs. 2-back'});

hh = plot_horizontal_line(0);
set(hh, 'LineWidth', 2, 'LineStyle', '--');

ylabel('Neurosynth pattern response');

set(gca, 'FontSize', 18);

% save
% saveas(gcf, fullfile(pwd, 'nback_vanast_pattern_response.svg'));


