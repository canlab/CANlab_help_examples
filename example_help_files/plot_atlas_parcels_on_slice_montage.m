% Plot brain parcels from an atlas in MNI152 space

% Create an fmridisplay object with a pre-set slice set. The set contains
% two montages: A sagittal montage with slices around the midline, and an
% axial montage with a series of slices.  o2 is an object with the montages
% registered in them, so blobs can be added/removed/etc.

o2 = canlab_results_fmridisplay([], 'multirow', 1);
brighten(.6)

% Find the file for the Glasser 2016 Nature parcellation, in MNI space:
parcellation_file = which('HCP-MMP1_on_MNI152_ICBM2009a_nlin.nii');

% Create region object from the parcellation file: First load into
% fmri_data, then region(). 
r = region(fmri_data(parcellation_file), 'unique_mask_values');

% Add the regions to the first two montages registered in o2
% in unique, bilaterally symmetric colors (the default options for
% region.montage).
o2 = montage(r, o2, 'wh_montages', 1:2);

drawnow, snapnow

% Save the figure, if desired

% scn_export_papersetup(800);
% saveas(gcf, 'Glasser_parcels_montage.png');
