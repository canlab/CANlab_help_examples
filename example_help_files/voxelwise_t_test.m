%% Perform a voxel-wise t-test
%
% Edited/commented by Bogdan Petre on 9/14/2016 
%
% In this example we perform a second level analysis on first level
% statistical parametric maps. Specifically we use a t-test to obtain an
% ordinary least squares estimate for the group level parameter. 
%
% Incidentally, we use the emotion regulation data provided with
% CANlab_Core_Tools. This dataset consists of first level analyses, where
% those analyses produced parameter estimates for a within subject task
% contrast (reappraise neg vs. look neg). There are 30 such maps, one for
% each subject
%
% These data were published in:
% Wager, T. D., Davidson, M. L., Hughes, B. L., Lindquist, M. A., 
% Ochsner, K. N.. (2008). Prefrontal-subcortical pathways mediating 
% successful emotion regulation. Neuron, 59, 1037-50.
%
% By the end of this example we will have regenerated the results of figure
% 2A of this paper.
%
% We can load this data using load_image_set(), which produces an fmri_data
% object. Data loading exceeds the scope of this tutorial, but a more
% indepth demosntration may be provided by load_a_sample_dataset.m

[image_obj, networknames, imagenames] = load_image_set('emotionreg');

% Voxel-wise tests estimate parameters for each voxel independently. The
% fmri_data/ttest function performs this just like the native matlab
% ttest() function, and similarly returns a p-value and t-stat. Unlike the
% matlab ttest() function, fmri_data/ttest performs this for every voxel in
% the fmri_data object. All voxels are evaluated independently, but all are
% evaluated nonetheless. A statistic_image is returned.

t = ttest(image_obj);

% which can be visualized

orthviews(t)

% As can be seen, the ttest() result is unthresholded. The threshold
% function can be used to apply a desired alpha level using any of a number
% of methods. Here FDR is used to control for alpha=0.05. Note that no
% information is erased when performing thresholding on a statistic_image.

t = threshold(t, .05, 'fdr');
orthviews(t)

% montage is another visualization method. This function requires a
% relatively large amount of memory. For this example, you will need around 
% 8GB of free memory. I've commented it out by default to avoid any
% surprises. Uncomment this line if you have adequate resources.
%
% create_figure('montage'); montage(t)
%

% Now we need to save our results. You can save the objects in your
% workspace or you can write your resulting thresholded map to an analyze
% file. The latter may be useful for generating surface projections using 
% Caret or FreeSurfer for instance.
%
% We need to do some preprocessing of our statistic_image object before we
% can output something useful. Recall that thresholding did not actually 
% eliminate insignificant voxels from our statistic_image object (t). If we
% simply write out that object, we will get t-statistics for all voxels. We
% need to mask insigificant voxels.

mask = t.convert2mask;
t_thresh = t.apply_mask(mask);
write(t_thresh, 'fname', [pwd ,'/t_thresh.img']);