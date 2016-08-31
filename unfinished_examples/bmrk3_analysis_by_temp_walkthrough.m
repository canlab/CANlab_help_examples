load('bmrk3_temp_model.mat')
bmrkdata

% About this dataset
% -------------------------------------------------------------------------
%
% This dataset includes 33 participants, with brain responses to six levels
% of heat (non-painful and painful).  
% 
% Aspects of this data appear in these papers:
% Wager, T.D., Atlas, L.T., Lindquist, M.A., Roy, M., Choong-Wan, W., Kross, E. (2013). An fMRI-Based Neurologic Signature of Physical Pain. The New England Journal of Medicine. 368:1388-1397
% (Study 2)
%
% Woo, C. -W., Roy, M., Buhle, J. T. & Wager, T. D. (2015). Distinct brain systems mediate the effects of nociceptive input and self-regulation on pain. PLOS Biology. 13(1): e1002036. doi:10.1371/journal.pbio.1002036
%
% Here is the structure of the data stored in bmrk3_temp_model.mat:
%
% bmrkdata = 
% 
%          dat: {1x33 cell}  <- One cell per subject, data objects
%     subjects: {1x33 cell}  <- Subject ID numbers
%     descript: 'Each cell of bmrkdata.dat contains 6 image data (temp level 1(44.3)- l...'
%      ratings: [33x6 double] <- Average rating for each of 6 temperatures
%      
% for each subject's data object bmrkdata.dat{i}, there are 6 images with average brain responses
%     to each of 6 temperatures: 44 - 49 degrees C.
%
% To do a group analysis, we will have to create a within-person contrast
% of interest, and subject that to group analysis.

% Examples are:
% Linear contrast
linearcon = [-5 -3 -1 1 3 5]';
highlowcon = [-1 -1 -1 1 1 1]';

%% Plot the ratings
% -------------------------------------------------------------------------  

create_figure('ratings');
lineplot_columns(bmrkdata.ratings, 'color', [.7 .3 .3], 'markerfacecolor', [1 .5 0]);
xlabel('Temperature');
ylabel('Rating');

%%Prediction

%Base model: Linear, whole brain prediction
%Continuous: Regression (LASSO-PCR) Categorical: SVM, logistic regression
% Model Options:
%   -Feature selection (part of the brain)
%   -Feature integration (new features)
%
% Testing options:
%   -Cross-validations
% -Input data (what level)
% - What testing metric (classification accuracy? RMSE?) and at what level
% (single trial, condition averages, one-map-per-subjct)

% Inference options:
% - Thresholding(Bootstrapping, Permutation)
% - Component maps, voxel-wise maps
% - Global null hypothesis / sanity check (permutation tests)

%% Base Model

use_spider

braindata = [];
n = length(bmrkdata.dat); n
for i =1:n
    braindata{i} = bmrkdata.dat{i}.dat; %voxels
end

braindata = cat(2, braindata{:});

%Train a model that is predictive across population
%Condition-average maps (6 maps per person)
%Leave one subject out (LOSO) cross validation: 
    %Predict left-out subjects (all images from one subject)


%% Analyze linear effects of temperature (stimulus intensity)
% Prepare the contrast images
% -------------------------------------------------------------------------  

% This analysis is similar to doing a parametric modulation analysis by
% temperature at the first level, then doing a 2nd level group analysis.
% Actually, it's formally identical, except that we are estimating it
% differently here, by estimating one image per stimulus intensity first,
% then creating the contrast.  

% To do a group analysis, we will have to create a within-person contrast
% of interest, and subject that to group analysis.

linearcon = [-5 -3 -1 1 3 5]';

% We will use column vectors for contrasts by convention.
% We need to apply this to each person's data to get a contrast image for
% group analysis.

% We also need to set up an empty object shell to store the contrast values
% in.  All subjects are the same in terms of image dimensions, so we'll use
% the first subject by convention.

group_contrast_images = bmrkdata.dat{1};
group_contrast_images.history = {'Created from first subject'};
group_contrast_images.dat = [];
group_contrast_images.fullpath = [];
group_contrast_images.image_names = [];

% Now that we have the shell, group_contrast_images, let's do the loop:

n = length(bmrkdata.dat);

for i = 1:n
    
    group_contrast_images.dat(:, i) = bmrkdata.dat{i}.dat * linearcon;
    
end

% This applies the linear contrast to each voxel for each subject.
% bmrkdata.dat{i}.dat is a v voxel x 6 image matrix.
% * is a matrix multiplication here, dat * contrast
% It yields a v x 1 image of contrast values.

% Now we are ready for group analysis.

%% Analyze linear effects of temperature (stimulus intensity)
% Run the group analysis and show the results
% -------------------------------------------------------------------------  

t = ttest(group_contrast_images);

o2 = canlab_results_fmridisplay('compact2');
o2 = multi_threshold(t, 'o2', o2);
drawnow, snapnow

% Let's see what the FDR threshold is here:
% t = threshold(t, .05, 'fdr');
% Image   1 FDR q < 0.050 threshold is 0.010760

% So all the yellow and orange stuff, and dark/medium blue stuff, 
% in the plot is FDR-corrected

%% Define a region of interest, extract and plot data
% -------------------------------------------------------------------------  


% First, let's load a pre-prepared mask image with many interesting
% regions:

mask_image = which('atlas_labels_combined.img')
orthviews(fmri_data(mask_image))
drawnow, snapnow

% The regions are coded with integer values in the image.
% Let's create a region object that stores the voxels (the region)
% associated with each uniquely-valued area in the image.

maskregions = region(mask_image, 'unique_mask_values');

% Now let's pick out one region in the thalamus to use as an ROI.
% They are coded with integers and the integer value is now the element
% number in the region object, maskregions, so let's look at #4:
orthviews(maskregions(4))
drawnow, snapnow

% Now let's save it:
medial_thalamus = maskregions(4);

% Let's overlay it on our brain map:
o2 = addblobs(o2, medial_thalamus, 'outline', 'color', 'k');
drawnow, snapnow

% It's hard to see, but it should be a black outline in the center images.

% Now let's extract data from our contrast images:
% Don't forget to get help if you need it: help region.extract_data

medial_thalamus = extract_data(medial_thalamus, group_contrast_images);

% Now the .dat field, medial_thalamus.dat, contains activity (contrast values) averaged over
% the ROI.  medial_thalamus.all_data contains the values for each voxel.

create_figure('contrast data in thalamus');
barplot_columns(medial_thalamus.dat, 'nofig');
drawnow, snapnow

% We get a bar plot and a "violin plot" with the distribution across
% individual subjects, which we can turn off:
cla
barplot_columns(medial_thalamus.dat, 'nofig', 'noviolin', 'noind');
drawnow, snapnow

% We also get a line of statistics with the group t-test:
% Column   1:	OLS  intercept val: 0.67, b = 0.67, se = 0.21, t( 32) = 3.19, p = 0.0032

% So we get a significant reponse in our thalamic ROI.
% The P-value is only really valid if we truly picked the thalamic ROI
% based on a priori knowledge. The safest way to ensure it's a priori is to
% pick the ROIs BEFORE looking at the results from our brain map.

%% Plot activity by temperature in the ROI
% -------------------------------------------------------------------------  

% How would we apply this to the individual data, to make a plot of
% activity by temperature?  Well, we'd have to extract values from each
% subject for each temperature.

for i = 1:n
    
    % this is for one subject:  
    myroi = extract_data(medial_thalamus, bmrkdata.dat{i});
    
    % I get 6 values, one for each image, which i have to save in a matrix:
    thalamus_by_temperature(i, :) = myroi.dat';
    
    
end

% Now we can plot:

create_figure('thalamus');
lineplot_columns(thalamus_by_temperature, 'color', [.7 .3 .3], 'markerfacecolor', [1 .5 0]);
xlabel('Temperature');
ylabel('Average thalamic activity');


%% Homework: Try it on your own!

% 1. Try creating mean-centered average pain values and testing for
% brain-pain correlations across people. 
% - How does this change the intercept (group within-person temperature effects) map?
% - What areas of the brain are significant, and do they match the group within-person map?

% 2. Try applying a high vs. low pain (highlowcon above) contrast to the data and doing a group analysis

% 3. Try creating and doing a group analysis comparing the LOWEST two
% stimulus levels. Is the response increases in non-painful stimulus
% intensity different?

% 4. Try Defining a spherical ROI using sphere_roi_tool_2008, extract and plot data
%    You could also use neurosynth.org to define a pain-related posterior
%    insula coordinate, and create a sphere around that.

% Here is a more advanced idea:
% Cluster the voxels across the brain by the profile of responses across
% temperatures.  Can you characterize different brain regions with
% different functions of stimulus intensity?





