%% Overview
% A brainpathway object is a CANlab object designed for connectivity and
% computational model-based analysis of fMRI data. It holds an atlas (defining
% brain regions), voxel-level time series data, and derived node and region
% averages. In addition, it contains connectivity matrices and graph metrics
% (e.g., network degree, modularity) that can be computed from the data.
% This object allows you to attach preprocessed time series data, compute
% connectivity, reorder regions for clearer visualization, and extract graph
% theoretical metrics using state-of-the-art methods.
%
% In this demonstration, we will:
%   1. Create a brainpathway object using a default atlas or a custom atlas.
%   2. Load a subject's 4-D fMRI timeseries.
%   3. Preprocess the time series (denoising).
%   4. Attach the denoised time series into the brainpathway object.
%   5. Examine connectivity and region averages.
%   6. Reorder regions based on label groups.
%   7. (Additional) Cluster regions and extract graph metrics.

%% Step 1: Create a brainpathway object
% this will use a default atlas.

brainpathway_obj = brainpathway;


%% Step 1: (alternate option)
% load an atlas that we'd like to use
%
% this will let us manipulate or customize the atlas if we want to
% e.g. reorder the regions to keep large groups
% together and in the order you want them in plots

atlas_obj = load_atlas('canlab2024');

% Create a brainpathway object with this atlas
% (if we omit atlas_obj,
brainpathway_obj = brainpathway(atlas_obj);

%% Step 2: Load a 4-D timeseries object
% Load a 4-D timeseries object from a subject to feed into brainpathways

% Load the key 4-D image file into an fmri_data object.
fname = which('swrsub-sid001567_task-pinel_acq-s1p2_run-03_bold.nii.gz');
obj = fmri_data(fname);

%% Step 3: Preprocess the time series images
% Preprocessing includes extracting the TR, loading the movement parameter file,
% and running the denoising pipeline.

% Get the TR from the JSON file:
json_struct = jsondecode(fileread(which('sub-sid001567_task-pinel_acq-s1p2_run-03_bold.json')));
TR = json_struct.RepetitionTime;
fprintf('TR extracted: %.2f seconds\n', TR);

% Specify the movement parameter file:
mvmtfname = which('rp_sub-sid001567_task-pinel_acq-s1p2_run-03_bold.txt');

% Run the denoising pipeline:
% (This pipeline regresses out nuisance covariates such as movement regressors,
% outlier indicators, and CSF signals, and applies a high-pass filter.)
obj_denoised = obj.denoise_timeseries_pipeline(TR, 128, mvmtfname, 'plot', false, 'verbose', false);
disp('Time series denoised.');

%% Step 3-4 (Alternate): Load a saved denoised timeseries object
% If you have already preprocessed the data, you can load a saved .mat file.
load(which('swrsub-sid001567_task-pinel_acq-s1p2_run-03_bold_denoised.mat'));
disp('Loaded saved denoised object (obj_denoised).');

%% Step 5: Attach the time series data into the brainpathway object
% This step resamples the 4-D image data (in obj_denoised) to the atlas space
% and stores it in the brainpathway object (in the .voxel_dat field). This triggers
% several updates such as recalculation of region averages and connectivity matrices.
brainpathway_obj.attach_voxel_data(obj_denoised);
disp('Voxel data attached to brainpathway object.');

%% Step 6: Examine connectivity matrices and region averages
% Visualize the region-by-region connectivity matrix using the brainpathway object's
% connectivity data. You can also display connectivity based on a partition.

create_figure('region averages'); 
imagesc(zscore(brainpathway_obj.region_dat)); 
title('Region averages (z-scores)');

disp('Region x Region Connectome is in brainpathway_obj.connectivity.regions')
brainpathway_obj.connectivity.regions

% Plot the region x region connectivity matrix:
plot_connectivity(brainpathway_obj, 'regions');
title('Region x Region Connectivity');

%%
% Plot connectivity matrix showing partitions
% Here we use a specific partition (e.g., based on labels_5 in the region_atlas):

plot_connectivity(brainpathway_obj, 'regions', 'partitions', brainpathway_obj.region_atlas.labels_5);
title('Region Connectivity (Partitioned by labels\_5)');

%% Step 7: Reorder regions to make connectome plots more interpretable
% It is often helpful to reorder atlas regions so that similar regions are grouped 
% together in plots. The following example uses label groups from the atlas.
%
% The group 'labels_5' was added using the script:
%   canlab2024_add_labels_5_networks_and_large_structures
%
% First, create a labelgroup cell array from the unique values in labels_5, then reorder:
labelgroups = unique(brainpathway_obj.region_atlas.labels_5);
labelgroups = labelgroups([5:20 22:37 1 21 38 39  2:4]);  % Reorder groups as desired
%
% To preserve the original object, create a copy (note: brainpathway is a handle class,
% so copying requires a dedicated method or function):
brainpathway_obj_reordered = copy(brainpathway_obj);
%
% Reorder the regions using the reorder_regions method, specifying the labelgroups and
% the atlas property ('label_5') to compare.
brainpathway_obj_reordered.reorder_regions('labelgroups', labelgroups, 'compare_property', 'labels_5');
disp('Regions reordered based on label groups.');

plot_connectivity(brainpathway_obj_reordered, 'regions', 'partitions', brainpathway_obj_reordered.region_atlas.labels_5);

%% Step 8: Cluster regions and extract graph metrics
% Next, you can cluster the atlas regions into communities and extract graph-theoretic 
% metrics from the connectivity data. These methods utilize functions from the Rubinov &
% Sporns brain connectivity toolbox.
%
% Example: Cluster regions into communities. (Assumes brainpathway has a method cluster_regions.)
brainpathway_obj = brainpathway_obj.cluster_regions();
disp('Atlas regions clustered into communities.');

% % OR
% % Assign networks manually based on pre-defined networks stored in labels
% [~, ~, condf] = string2indicator(brainpathway_obj.region_atlas.labels_5);
% brainpathway_obj.node_clusters = condf';

% Example: Compute graph metrics such as degree, modularity, and other properties.
brainpathway_obj = brainpathway_obj.degree_calc();
disp('Graph metrics extracted from connectivity data.');
brainpathway_obj.graph_properties.regions

%% Step 9: Visualize the Graph Metrics
% Finally, you can visualize the connectivity or network graph using methods that plot 
% connectivity matrices, network graphs, or other summaries of the graph properties.

brainpathway_obj_reordered = copy(brainpathway_obj);
plot_connectivity(brainpathway_obj_reordered, 'regions', 'partitions', brainpathway_obj_reordered.node_clusters);

title('Final Connectivity Matrix After Clustering');
disp('Graph metrics and connectivity visualization complete.');