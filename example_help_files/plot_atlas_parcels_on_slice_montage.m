% Plot brain parcels from an atlas in MNI152 space


% For this example, the atlas/parcellation file must be a full
% probabilistic atlas.  This enables image thresholding based on
% probabilty values. You can do all the rest of the commands with only an
% image with labels, however.
%
% Creating an atlas object requires either images with probability maps (a 4-d image) 
% Or an integer-valued image with one integer per atlas region. 
% For full functionality, the atlas also requires both probability maps and 
% text labels, one per region, in a cell array. But some functionality will
% work without these.

parcellation_file = 'CIT168toMNI152_prob_atlas_bilat_1mm.nii';  


% Labels should be a cell array of names corresponding to integer vectors
% in the atlas

labels = {'Put' 'Cau' 'NAC' 'BST_SLEA' 'GPe' 'GPi' 'SNc' 'RN' 'SNr' 'PBP' 'VTA' 'VeP' 'Haben' 'Hythal' 'Mamm_Nuc' 'STN'};

%% Using the atlas object

% Create an atlas-type object from the parcellation file

dat = atlas(which(parcellation_file), 'labels', labels, ...
'space_description', 'MNI152 space', ...
'references', 'Pauli 2018 Bioarxiv: CIT168 from Human Connectome Project data', 'noverbose');

% Threshold at probability 0.2 or greater and k = 3 voxels or greater
dat = threshold(dat, .2, 'k', 3);

% Display with unique colors for each region:
orthviews(dat, 'unique');
drawnow, snapnow

% Convert to regions:
r = atlas2region(dat);

% Display regions in unique colors:
orthviews(r, 'unique')
drawnow, snapnow

% Display on montage (colors may not be the same!):
montage(r);
drawnow, snapnow

%% Alternative without atlas object

% You can also do this without the atlas object. This is convenient if you
% do not have the probability maps or labels to create the full atlas
% object.

% This is an example of another parcellation without probability maps:
% Glasser 2016 Nature parcellation, in MNI space:
parcellation_file = which('HCP-MMP1_on_MNI152_ICBM2009a_nlin.nii');

% Create region object from the parcellation file: First load into
% fmri_data, then region(). 
r = region(fmri_data(parcellation_file), 'unique_mask_values');

%% Alternative slice displays

% you can also create different types of slice montages, or custom ones,
% with the fmridisplay object. There are some pre-set ones, like 'multirow'

% Create an fmridisplay object with a pre-set slice set. The set contains
% two montages: A sagittal montage with slices around the midline, and an
% axial montage with a series of slices.  o2 is an object with the montages
% registered in them, so blobs can be added/removed/etc.

o2 = canlab_results_fmridisplay([], 'multirow', 1);
brighten(.6)

% Add the regions to the first two montages registered in o2
% in unique, bilaterally symmetric colors (the default options for
% region.montage).
o2 = montage(r, o2, 'wh_montages', 1:2);

drawnow, snapnow

% Save the figure, if desired

% scn_export_papersetup(800);
% saveas(gcf, 'Glasser_parcels_montage.png');
