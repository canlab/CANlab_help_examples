%% Prepare data files
% BLOCK 1
% ---------------------------------------------------------------

% Establish that images are on path
% if not, you'll get an empty variable basedir
basedir = fileparts(which('con_00810001.img'));

% Load behavioral data
%    "Reappraisal success", one score per person, in our example
beh = importdata('X_Y_data.txt')
success = beh.data(:, 2);           % Reappraisal success

% Load brain data
%    Reappraise - Look Neg contrast images, one image per person
imgs = filenames(fullfile(basedir, 'con_*img'), 'char', 'absolute');

% Create the fmri_data object called "dat".  Store the contrast image data
% in it.
dat = fmri_data(imgs);

% Load mask

mask = which('gray_matter_mask.img')

maskdat = fmri_data(mask);

%% BLOCK 2
% ---------------------------------------------------------------
% Check mask

% This is an underlay brain:

o2 = canlab_results_fmridisplay([], 'compact2', 'noverbose');
drawnow, snapnow;

% This is a basic gray-matter mask we will use for analysis:
% It can help reduce multiple comparisons relative to whole-image analysis
% but we should still look at what's happening in ventricles and
% out-of-brain space to check for artifacts.

o2 = addblobs(o2, region(maskdat));

drawnow, snapnow;

%% BLOCK 3
% ---------------------------------------------------------------
% Check that we have valid data in all voxels for all subjects

% Create a mean image across the 30 contrast images, and store in "m"
% object.  
m = mean(dat);

% This line counts how many subjects have non-zero, non-nan data.
% zero is treated as a missing value.  
% This illustrates how you can do lots of customized things with the data.

m.dat = sum(~isnan(dat.dat) & dat.dat ~= 0, 2);
%o2 = addblobs(o2, region(m), 'maxcolor', [1 0 0], 'mincolor', [0 0 1]);
orthviews(m)

% problem - fix?
% mdat = replace_empty(dat);
% m = replace_empty(m);
% mdat.dat = m.dat;
% o2 = addblobs(o2, region(mdat), 'maxcolor', [1 0 0], 'mincolor', [0 0 1]);

%% BLOCK 4
% ---------------------------------------------------------------
% Check histograms of individual subjects for global shifts in contrast values

h = qchist(dat);
axh = get(h, 'Children')
for i = 1:length(axh), axes(axh(i)); title(' '); end

%% BLOCK 5
% ---------------------------------------------------------------
% Examine predictor distribution and leverages

X = scale(success, 1); X(:, end+1) = 1;
H = X * inv(X'* X) * X';

create_figure('levs', 2, 1); 
plot(success, 'o', 'MarkerFaceColor', [0 .3 .7], 'LineWidth', 3); 
set(gca, 'FontSize', 24); 
xlabel('Subject number'); 
ylabel('Reappraisal success');

subplot(2, 1, 2);
plot(diag(H), 'o', 'MarkerFaceColor', [0 .3 .7], 'LineWidth', 3); 
set(gca, 'FontSize', 24); 
xlabel('Subject number'); 
ylabel('Leverage');


%% BLOCK 6
% Run regression
% The regress method takes predictors that are attached in the object's X
% attribute (X stands for design matrix) and regresses each voxel's
% activity (y) on the set of regressors.  
% This is a group analysis, in this case correlating brain activity with
% reappraisal success at each voxel.

% .X must have the same number of observations, n, in an n x k matrix.
% n images is the number of COLUMNS in dat.dat

% mean-center success scores and attach them to dat in dat.X
dat.X = scale(success, 1);

% runs the regression at each voxel and returns statistic info and creates
% a visual image.  regress = multiple regression.

out = regress(dat);

% out has statistic_image objects that have information about the betas
% (slopes) b, t-values and p-values (t), degrees of freedom (df), and sigma
% (error variance).  The critical one is out.t.
% out = 
% 
%         b: [1x1 statistic_image]
%         t: [1x1 statistic_image]
%        df: [1x1 fmri_data]
%     sigma: [1x1 fmri_data]

% Now let's try thresholding the image at q < .05 fdr-corrected.
 t = threshold(out.t, .05, 'fdr');
 
% ...and display
orthviews(t)

% This is a multiple regression, and there are two output t images, one for
% each regressor.  We've only entered one regressor, why two images?  The program always
% adds an intercept by default.  Intercept is th last column of design matrix

% Image   1  <--- brain contrast values correlated with "success"
% Positive effect:   0 voxels, min p-value: 0.00001192
% Negative effect:   0 voxels, min p-value: 0.00170529
% Image   2 FDR q < 0.050 threshold is 0.003193
% 
% Image   2 <--- intercept, because we have mean-centered, this is the
% average group effect (when success = average success).  "Reapp - Look"
% contrast in the whole group.
% Positive effect: 3133 voxels, min p-value: 0.00000000
% Negative effect:  51 voxels, min p-value: 0.00024068

% re-threshold at p < .005 uncorrected
t = threshold(out.t, .005, 'unc');
orthviews(t)
%% BLOCK 7
% Display the results on slices

o2 = removeblobs(o2);
% multi_threshold lets us see the blobs with significant voxels at the
% highest (most stringent) threshold, and voxels that are touching
% (contiguous) down to the lowest threshold, in different colors.
o2 = multi_threshold(out.t, 'o2', o2, 'thresh', [.005 .01 .05], 'sizethresh', [1 1 1]);

%% BLOCK 8: Add a new montage and re-display

o2 = removeblobs(o2);
o2 = montage(o2, 'coronal', 'slice_range', [-20 20], 'onerow');
o2 = addblobs(o2, region(out.t));


%% BLOCK 9: Look for signal in ventricles, white matter, outside of brain
%
% We want to diagnose potential problems due to outliers, etc...

% Strategy 1:  Apply a very liberal threshold.
t = threshold(out.t, .05, 'unc');

o2 = removeblobs(o2);
o2 = addblobs(o2, region(t));

% Strategy 2: Extract mean signal from WM and ventricles
m = extract_gray_white_csf(dat);
create_figure('gray'); 
barplot_colored(m);
set(gca, 'XTickLabel', {'Gray' 'White' 'CSF'}, 'XTick', [1:3]);
ylabel('Contrast values');

%% BLOCK 10: Compare results to meta-analysis for positive controls

% Map from neurosynth.org 
metaimg = which('emotion regulation_pAgF_z_FDR_0.01_8_14_2015.nii')
r = region(metaimg)
o2 = removeblobs(o2);
o2 = addblobs(o2, r, 'maxcolor', [1 0 0], 'mincolor', [0 0 1]);


%% BLOCK 11: Apply gray-matter mask and show FDR-thresholded results

% This can increase power by focusing on areas we think there are plausible
% effects. First is the success effect (regressor) and second is the
% intercept (group average contrast) map.

%t = threshold(out.t, .05, 'fdr', 'mask', mask);

t = apply_mask(out.t, maskdat);
t = threshold(t, .05, 'fdr');
o2 = removeblobs(o2);
o2 = addblobs(o2, region(t));

%% BLOCK 12: Refine analysis by removing outlier and ranking predictor values

% exclude high-leverage subject 16
datno16 = dat;
datno16.dat(:, 16) = [];

% try rank: robust...
% Ranking is a kind of nonparametric

datno16.X = success;
datno16.X(16) = [];
datno16.X = scale(rankdata(datno16.X), 1);

% Re-run regression
out = regress(datno16);

% Apply gray matter mask and threshold
t = apply_mask(out.t, maskdat);
t = threshold(t, .005, 'unc');
%orthviews(t)

% Select the reappraisal success effect only and show it
t1 = select_one_image(t, 1);
o2 = removeblobs(o2);
o2 = multi_threshold(t1, 'o2', o2, 'thresh', [.005 .01 .05], 'sizethresh', [1 1 1]);

% Select the intercept (group average contrast) effect only and show it
t2 = select_one_image(t, 2);
o2 = removeblobs(o2);
o2 = multi_threshold(t2, 'o2', o2, 'thresh', [.005 .01 .05], 'sizethresh', [1 1 1]);

%% Block 13: Extract and plot data from (biased) regions of interest
% Let's visualize the correlation scatterplots in the areas we've
% discovered as related to Success

% Select the Success regressor map
r = region(t1);

% Extract data from all regions
r = extract_data(r, datno16);

% Select only regions with 3+ voxels
wh = cat(1, r.numVox) < 3;
r(wh) = [];

% Make a loop and plot each region
for i = 1:length(r)
    % Show the region
    o2 = removeblobs(o2);
    o2 = addblobs(o2, r(i), 'splitcolor', {[0 0 1] [0 1 1] [1 .5 0] [1 1 0]});
    orthviews(r(i));
    
    % Plot the scatterplot
    create_figure('scatterplot_region');
    
    % Use this line for non-robust correlations:
    %plot_correlation_samefig(r(i).dat, datno16.X);
    
    % Use this line for robust correlations:
    plot_correlation_samefig(r(i).dat, datno16.X, [], 'k', 0, 1);
  
    xlabel('Reappraise - Look Neg brain response');
    ylabel('Reappraisal success');
    
    input('Press a key to continue');
end


%% Block 14: Extract and plot data from unbiased regions of interest
% Let's visualize the correlation scatterplots in some meta-analysis
% derived ROIs

% Select the Success regressor map
r = region(metaimg);

% Extract data from all regions
r = extract_data(r, datno16);

% Select only regions with 20+ voxels
wh = cat(1, r.numVox) < 20;
r(wh) = [];

% Make a loop and plot each region
for i = 1:length(r)
    % Show the region
    o2 = removeblobs(o2);
    o2 = addblobs(o2, r(i), 'splitcolor', {[0 0 1] [0 1 1] [1 .5 0] [1 1 0]});
    orthviews(r(i));
    
    % Plot the scatterplot
    create_figure('scatterplot_region');
    
    % Use this line for non-robust correlations:
    %plot_correlation_samefig(r(i).dat, datno16.X);
    
    % Use this line for robust correlations:
    plot_correlation_samefig(datno16.X, r(i).dat, [], 'k', 0, 1);
  
    ylabel('Reappraise - Look Neg brain response');
    xlabel('Reappraisal success');
    
    input('Press a key to continue');
end

%% Block 15: Multivariate prediction from unbiased ROI averages

contrast_dat = cat(2, r.dat);  % these will be the predictors
y = datno16.X;                 % this is the outcome to be explained

STATS = xval_regression_multisubject('lasso', {y}, {contrast_dat}, 'holdout_method', 'loo', 'pca', 'ndims', 'variable');

