%% Perform a voxel-wise t-test
%
% Edited/commented by Bogdan Petre on 9/14/2016, Tor Wager July 2018 
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
% As a summary, here is a complete set of commands to load the data and run
% the entire analysis:
% 
%     img_obj = load_image_set('emotionreg');         % Load a dataset
%     t = ttest(img_obj);                             % Do a group t-test
%     t = threshold(t, .05, 'fdr', 'k', 10);          % Threshold with FDR q < .05 and extent threshold of 10 contiguous voxels
%     r = region(t);                                  % Turn t-map into a region object with one element per contig region
%  
%     % Show regions and print a table with labeled regions:
%     montage(r);
%     table(r);                                       % Print a table of results using new region names
%  
% Now, let's walk through it step by step.

%% Load sample data

% Load sample data using load_image_set(), which produces an fmri_data
% object. Data loading exceeds the scope of this tutorial, but a more
% indepth demosntration may be provided by load_a_sample_dataset.m

[image_obj, networknames, imagenames] = load_image_set('emotionreg');

%% Do a t-test

% Voxel-wise tests estimate parameters for each voxel independently. The
% fmri_data/ttest function performs this just like the native matlab
% ttest() function, and similarly returns a p-value and t-stat. Unlike the
% matlab ttest() function, fmri_data/ttest performs this for every voxel in
% the fmri_data object. All voxels are evaluated independently, but all are
% evaluated nonetheless. A statistic_image is returned.

t = ttest(image_obj);

%% Visualize the results
% There are many options. See methods(statistic_image) and methods(region)

orthviews(t)

% As can be seen, the ttest() result is unthresholded. The threshold
% function can be used to apply a desired alpha level using any of a number
% of methods. Here FDR is used to control for alpha=0.05. Note that no
% information is erased when performing thresholding on a statistic_image.

t = threshold(t, .05, 'fdr');
orthviews(t)

% Many neuroimaging packages (e.g., SPM and FSL) do one-tailed tests 
% (with one-tailed p-values) and only show you positive effects 
% (i.e., relative activations, not relative deactivations).  
% All the CANlab tools do two-sided tests, report two-tailed p-values. 
% By default, hot colors (orange/yellow) will show activations, and cool
% colors (blues) show deactivations.

% We can also apply an "extent threshold" of > 10 contiguous voxels:

t = threshold(t, .05, 'fdr', 'k', 10);
orthviews(t)

% montage is another visualization method. This function may require a
% relatively large amount of memory, depending on the resolution of the 
% anatomical underlay image you use. We recommend around 8GB of free memory. 
%
create_figure('montage'); 
montage(t)

%% Print a table of results

% First, we'll have to convert to another object type, a "region object".
% This object groups voxels together into "blobs" (often of contiguous
% voxels). It does many things that other object types do, and inter-operates
% with them closely.  See methods(region) for more info.

% Create a region objecft called "r", with contiguous blobs from the
% thresholded t-map:

r = region(t);

% Print the table:

r = table(r);

% You can get help and options for any object method, like "table". But
% because the method names are simple and often overlap with other Matlab functions 
% and toolboxes (this is OK for objects!), you will often want to specify
% the object type as well, as follows:

help region.table

% The method region.table ("table" method for "region" object) attempts to
% autolabel the regions with a combined atlas composed of several published
% atlases. The region object r that is returned has fields called 'title'
% and 'shorttitle' that now have names of atlas regions attached to them.

%% Show a montage focused on each region in the table

% Now, let's make another montage of each region, showing a slice with the
% region center and labeling each region. This will help us visually
% inspect the clusters in the table:

o2 = montage(r, 'regioncenters', 'colormap');

snapnow

%% More options for visualizing the results map

% o2 is another type of object, an 'fmridisplay' type object. This object
% holds handles for multiple slices and surfaces, so you can add and remove
% blobs easily. Let's first create a montage:

o2 = montage(r);
snapnow

% Maybe we don't like the solid color. Let's remove those blobs and re-plot
% them in a colormap with different colors:

o2 = removeblobs(o2);

o2 = montage(r, o2, 'colormap', 'mincolor', [0 0 1], 'maxcolor', [.8 .5 .7]);

snapnow

% We've passed o2 back into region.montage so that it can use the existing
% slices and display setup. 

% All of the lower-level functions that these commands run are designed to
% be modular, too. region.montage runs canlab_results_fmridisplay.m, which sets up
% various configurations of slices. That function uses fmridisplay.montage
% to attach slice montages at different orientations and locations to the
% figure and the registry in o2, the fmridisplay object. And
% fmridisplay.addblobs adds the blobs, with various options for color,
% transparency, and scaling of colors.  We can use any of the many options
% in addblobs.  Let's try making the blobs transparent instead:

o2 = removeblobs(o2);

o2 = montage(r, o2, 'colormap', 'trans', 'mincolor', [0 0 1], 'maxcolor', [.8 .5 .7]);

snapnow

% Finally, let's create a montage with a complete set of slices and surfaces, for a
% fairly comprehensive view of the results map. We do this with the 'full'
% option to region.montage (there are many other options).

o2 = montage(r, 'colormap', 'full');



%% Write the t-map to disk

% Now we need to save our results. You can save the objects in your
% workspace or you can write your resulting thresholded map to an analyze
% file. The latter may be useful for generating surface projections using 
% Caret or FreeSurfer for instance.
%
% Thresholding did not actually eliminate nonsignificant voxels from our 
% statistic_image object (t). If we  simply write out that object, we will 
% get t-statistics for all voxels. 

t.fullpath = fullfile(pwd, 'example_t_image.img');
write(t)

% If we use the 'thresh' option, we'll write thresholded values:
write(t, 'thresh')

t_reloaded = statistic_image(t.fullpath, 'type', 'generic');
orthviews(t_reloaded)