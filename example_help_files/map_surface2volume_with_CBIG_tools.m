

% https://www.xquartz.org/

% https://surfer.nmr.mgh.harvard.edu/fswiki/rel7downloads
% https://surfer.nmr.mgh.harvard.edu/fswiki//FS7_mac



% [projected, projected_seg] = CBIG_RF_projectfsaverage2Vol_single(lh_input_array, rh_input_array, interpolation, path_to_mapping, path_to_mask)

cifti_struct = cifti_read('transcriptomic_gradients.dscalar.nii');
leftdata = cifti_struct_dense_extract_surface_data(cifti_struct, 'CORTEX_LEFT', 1);
rightdata = cifti_struct_dense_extract_surface_data(cifti_struct, 'CORTEX_RIGHT', 1);
leftdata = leftdata(:, 1)';
rightdata = rightdata(:, 1)';

%%
mappingfile = which('allSub_fsaverage_to_FSL_MNI152_FS4.5.0_RF_ANTs_avgMapping.prop.mat');

maskfile = which('FSL_MNI152_FS4.5.0_cortex_estimate.nii.gz');

[projected, projected_seg] = CBIG_RF_projectfsaverage2Vol_single(leftdata, rightdata, 'linear', mappingfile, maskfile); % , path_to_mapping, path_to_mask)
