% Extract data from each region in a standardized atlas, averaging over voxels in the region

% Method 1
% pass fmri_data object img into canlab_connectivity_preproc, using the 'extract_roi' keyword and passing in the atlas
img = load_image_set('emotionreg');  % a sample fmri_data object; insert your single-subject 4-D time series object here

% Replace img with your single-subject 4-D time series object here, which
% would usually be image data corresponding to one run.  You'd save the
% output for each run, and concatenate across runs along with a metadata
% table describing the task conditions and sessions.

my_atlas = load_atlas('canlab2018_2mm');
[img_preprocessed, region_average_data] = canlab_connectivity_preproc(img, 'extract_roi', my_atlas, 'unique_mask_values');

% NOTE: Customize additional inputs to canlab_connectivity_preproc by
% passing in nuisance regressors (outlier 'spikes', movement-related
% regressors)

% Method 2
b = brainpathway;
img = load_image_set('emotionreg');  % a sample fmri_data object; insert your single-subject 4-D time series object here
img = resample_space(img, b.region_atlas); % resample the image to the voxel space/dims of atlas stored in b
b.voxel_dat = img.dat;

region_average_data = b.region_dat; % images x brain regions
region_labels = b.region_atlas.labels; % labels (names) for the brain regions

% next: Run canlab_connectivity_preproc, bandpass filtering and nuisance
% regression
% Create an image object storing the region averages
% Pass the image object into canlab_connectivity_preproc

