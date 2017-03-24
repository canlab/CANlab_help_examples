% Run this script once to prep data files, save them, calculate contrast
% image objects, and get ready to run analyses.
%
% Before running, you need to customize two scripts for your analysis:
% a_set_up_paths_always_run_first.m
% prep_1_set_conditions_contrasts_colors.m

a_set_up_paths_always_run_first
prep_1_set_conditions_contrasts_colors
prep1b_prep_behavioral_data
prep_2_load_image_data_and_save
prep_3_calc_univariate_contrast_maps_and_save
prep_4_apply_signatures_and_save