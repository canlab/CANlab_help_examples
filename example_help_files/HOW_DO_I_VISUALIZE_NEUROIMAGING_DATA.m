%% TITLE OF HELP FILE - e.g., HOW_DO_I_VISUALIZE_DATA
% The help file shows you how to display neuroimaging data for publication

%% General instructions
% -----------------------------------------------------------------------
%
% Before you start, the CANlab_Core_Tools must be added to your path with
% subfolders. Otherwise, you will get errors.
%
% This example will use the neurologic pain signature (NPS): 
% "weights_NSF_grouppred_cvpcr" %NOTE TO TOR: This is currently in masks private
% 
% These data were published in:
% Wager, T. D., Atlas, L. Y., Lindquist, M. A., Roy, M., Woo, C.W., &
% Kross, E. (2013). An fMRI-Based Neurologic Signature of Physical Pain. 
% New England Journal of Medicine, 368:1388-97.

% ----------------------------------------------
%% Section 1: Load in data and quick view
% ----------------------------------------------
% Load in the image (any .nii or img) as an fmri_data object
nps = fmri_data(which('weights_NSF_grouppred_cvpcr.img'));

% Quickly dispaly it and eyeball its properties
figure; plot(nps)
snapnow

close all;
% ----------------------------------------------
%% Plot slices with canlab_results_fmridisplay
% ----------------------------------------------
% You must convert the fmri_data object to a region object
% This takes a lot of memory, and can hang if you have too little.
figure; o2 = canlab_results_fmridisplay(region(nps),'noverbose');
snapnow

% Alternatively, display the slices you want first, then add image data
% This function has advanced control like outlining blobs, transparency
% overlays
figure; o2 = canlab_results_fmridisplay([],'noverbose');
o2=addblobs(o2,region(nps),'color',[.5 0 .5],'outline','linewidth', 2,'transvalue', .75)
snapnow

% Change the slices with 'montagetype' function
figure; o2 = canlab_results_fmridisplay(region(nps),'montagetype','compact2','noverbose');
snapnow
close all;
% ----------------------------------------------
%% For greater control over the slices displayed, use montage
% ----------------------------------------------
% 'slice_range' allows you to select the x y z coordinates
% give it a range of values, and determine the 'spacing' between them
figure;o2 = fmridisplay;
o2 = montage(o2, 'axial', 'slice_range', [-10 10], 'onerow', 'spacing', 5);
o2 = montage(o2, 'coronal', 'slice_range', [-6 0], 'onerow','spacing', 3);
o2 = montage(o2, 'saggital', 'slice_range', [-10 10], 'spacing', 5);
o2=addblobs(o2,region(nps));
snapnow
close all

% ----------------------------------------------
%% For 3D Surface Plots
% ----------------------------------------------
% There are multple options for producing 3D brains.

% --------
% OPT1 - Plot on a 'slab' of brain like Reddan, Lindquist, Wager (2016)
% Effect Size paper
% --------
% First set up your underlay brain image (anatomical)
ovlname = 'keuken_2014_enhanced_for_underlay'; %this image is in CanlabCore
ycut_mm = -30; % Where to cut brain on Y axis
coords = [0 ycut_mm 0];
coords = [0 0 20];
anat = fmri_data(which('keuken_2014_enhanced_for_underlay.img'));
% Next set up the surface plot of your data
figure; 
set(gcf, 'Tag', 'surface'); 
f1 = gcf;
p = isosurface(anat, 'thresh', 140, 'nosmooth', 'zlim', [-Inf 20]);
view(137, 26);
lightRestoreSingle
colormap gray; 
brighten(.6); 
set(p, 'FaceAlpha', 1);
drawnow
set(f1, 'Color', 'w');
[mip, x, y, voldata] = pattern_surf_plot_mip(nps, 'nosmooth');
figure(f1)
hold on;
% Next rescale your surface data to match anatomical brainmap we want (kludge)
han = surf(x, y, mip .* 70 + 20);
set(han, 'AlphaDataMapping', 'scaled', 'AlphaData', abs(mip) .^ .5, 'FaceColor', 'interp', 'FaceAlpha', 'interp', 'EdgeColor', 'interp');
set(han, 'EdgeColor', 'none');
% Set colormap for plot
def = colormap('parula');
gray = colormap('gray');
cm = [def; gray];
colormap(cm);
view(147, 50);
axis off
% Apply to brain
drawnow; snapnow
close all;

% ---------
% OPT2 - Use default surf plot option in canlab_results_fmridisplay_marianne
% --------
figure;o2=canlab_results_fmridisplay_marianne(region(nps),'montagetype','full_surf','noverbose');
snapnow;

% --------
% OPT3 - function tor_3D, or export your data to Caret
% --------

% ----------------------------------------------
%% For plotting voxel plots of ROIs use roi_contour_map
% ----------------------------------------------
% Convert image into clusters with region()
% Determine which clusters you want to plot and select them within the cluster object e.g., cl(NUMBEROFCLUSTER(S))
figure;for i = 1:2, cl = region(nps); end
info = roi_contour_map([cl(6), cl(5), cl(20), cl(37),cl(49)], 'cluster', 'use_same_range', 'colorbar');
snapnow

% Note if you get errors here, check the number of voxels in your cluster.
% If less than 2, you cannot use this function.
% Here is an example of how to check
for i=1:57;disp(sprintf('cluster %d is %d voxels',i,cl(i).numVox));end

% Print out the clusters
table=cluster_table(cl, 0, 0,'writefile','Name_ClusterTable');