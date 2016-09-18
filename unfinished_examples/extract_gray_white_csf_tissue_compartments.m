img = which('keuken_2014_enhanced_for_underlay.img');
img = fmri_data(img);
histogram(img, 'by_tissue_type');

%       This uses the extract_gray_white_csf method, which in turn
%       currently uses the images
%       'gray_matter_mask.img' 'canonical_white_matter.img' 'canonical_ventricles.img'
%       These images are based on the SPM8 a priori tissue probability
%       maps, but they have been cleaned up and made symmetrical and/or eroded
%       so that the white and CSF compartments are unlikely to contain very
%       much gray matter.  The gray compartment is currently more
%       inclusive. The potential value of this is that signal in the CSF/white
%       compartments may be removed from images prior to/during analysis