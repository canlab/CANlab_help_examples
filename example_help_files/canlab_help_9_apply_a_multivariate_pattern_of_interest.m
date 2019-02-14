% Concept:
% --------------------------------------------------------------------
%   This walkthrough explains how to do a "pattern of interest" (POI) analysis
%   using an a priori multivariate pattern. It generalizes the "region of
%   interest" (ROI) approach. ROI analyses usually involve averaging signal
%   over the voxels within an ROI. The POI approach applies a weighted average,
%   with the weights specified by the pattern. The "pattern response" is a
%   single number that reflects the magnitude of activity in the pattern.
%   If the pattern is a mask of 1's and 0's, the POI response is equivalent
%   to averaging, up to the scaling of the values (which are usually
%   assumed to be arbitrary, but the same across participants/test
%   datasets).
%
% Required toolboxes:
% --------------------------------------------------------------------
%   Matlab signal processing toolbox
%   Matlab statistics/machine learning toolboxes
%   SPM12
% Two CANlab toolboxes from https://github.com/canlab
%   https://github.com/canlab/CanlabCore
%   https://github.com/canlab/Neuroimaging_Pattern_Masks
%
% Add SPM12 and all CANlab toolboxes with subfolders to the Matlab path
%

% Load some data images. These are N = 30 subjects from Wager et al. 2008,
% Neuron. Each image is a contrast between regulating and looking at
% aversive images.
test_data_obj = load_image_set('emotionreg');

% Load a set of patterns that we want to apply
% These are Partial Least Squares (PLS)-based signatures from Kragel et al.
% 2018 Nature Neurosci.
% Three patterns relate to Pain, Cognitive Control, and Negative Emotion,
% respectively.

[obj, names] = load_image_set('pain_cog_emo');
bpls_wholebrain = get_wh_image(obj, [8 16 24]);
names_wholebrain = names([8 16 24]);

% Incidentally, we could also extract patterns for local subregions,
% e.g., only within the dorsal anterior cingulate (dACC) or other regions
% of interest. The code below would extract relevant images, but we will
% not do this here.
%   bpls_subregions = get_wh_image(obj, [1:6 9:14 17:22]);
%   names_subregions = names([1:6 9:14 17:22]);

%  Make plots
% Yellow: positive associations. Blue: Negative associations.  Plot shows mean +- std. error for each pattern of interest

create_figure('Kragel Pain-Cog-Emo maps', 1, 3);

% Notes:
% An important thing to do is to make sure that the images you're comparing
% have been resampled to the same space and voxel size, with voxels that line up
% across both image sets.  The function below handles this automatically,
% as do other related functions in the toolboxes, e.g., apply_mask.m.
% They use the object method resample_space.m
%
% Another consideration is how to handle missing data values and values of
% 0, which are often considered missing data in fMRI images. This is handled here by 
% canlab_pattern_similarity, which treats 0s in the data images as missing, and excludes them,
% but does not exclude 0s in pattern masks, which may be valid values. The
% impact of this on the calculated similarity metrics varies across
% similarity metrics.
%
% In the plot below, yellow areas are positive correlations, blue are
% negative:
stats = image_similarity_plot(test_data_obj, 'average', 'mapset', bpls_wholebrain, 'networknames', names_wholebrain, 'nofigure');
axis image

% Now let's take the values and make a bar plot instead:
subplot(1, 3, 2)

barplot_columns(stats.r', 'nofigure', 'colors', {[1 .9 0] [.2 .2 1] [1 .2 .2]}, 'names', names_wholebrain)
set(gca, 'FontSize', 14)
ylabel('Pattern similarity (r)');
title('Similarity (r) with patterns')

% Now let's recalculate similarity using a different metrric, cosine
% similarity.  We'll have to resample the data image first:

test_data_obj = resample_space(test_data_obj, bpls_wholebrain);

% Then calculate the pattern similarity:

clear csim
for i = 1:3
    
    csim(:, i) = canlab_pattern_similarity(test_data_obj.dat, bpls_wholebrain.dat(:, i), 'cosine_similarity');
    
end

% Now we can plot this

subplot(1, 3, 3)

barplot_columns(csim, 'nofigure', 'colors', {[1 .9 0] [.2 .2 1] [1 .2 .2]}, 'names', names_wholebrain)
set(gca, 'FontSize', 14)
ylabel('Pattern similarity (cosine sim)');
title('Pattern response (cosine similarity)')


