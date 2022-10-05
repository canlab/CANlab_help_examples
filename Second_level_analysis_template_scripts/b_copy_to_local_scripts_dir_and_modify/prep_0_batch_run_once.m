% Run this script once to prep data files, save them, calculate contrast
% image objects, and get ready to run analyses.
%
% Before running, you need to customize two scripts for your analysis:
% a_set_up_paths_always_run_first.m
% prep_1_set_conditions_contrasts_colors.m
%
% If you have behavioral data and between-subject contrasts, you should
% customize prep_1b_prep_behavioral_data.m and put in your run path.
%
% You do not have to copy over all the scripts from the master
% "Second_level_analysis_template_scripts" folder to use them.
% The standard versions of most scripts will run without editing.
% But if you choose, you can copy any of them to your individual project directory 
% and customize them, and run those customized versions instead of the
% standard versions.

% Scripts that you must copy over and edit:
a_set_up_paths_always_run_first
prep_1_set_conditions_contrasts_colors

% Other scripts you can copy over and edit if you want to:
prep_1b_prep_behavioral_data
prep_2_load_image_data_and_save
prep_3_calc_univariate_contrast_maps_and_save
prep_4_apply_signatures_and_save