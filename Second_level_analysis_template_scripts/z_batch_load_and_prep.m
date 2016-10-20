
% Edit these two before running
% -------------------------------------------------------
a_set_up_paths_always_run_first

prep_1_set_conditions_contrasts_colors

% These should not need editing, 
% can run template scripts directly
% -------------------------------------------------------
%% INDIVIDUAL CONDITION PLOTS

printhdr('INDIVIDUAL CONDITION PLOTS')

prep_2_load_image_data_and_save

%% CONTRAST PLOTS

printhdr('CONTRAST PLOTS')
prep_3_calc_univariate_contrast_maps_and_save

% You can also run z_batch_publish_image_prep_and_qc to run these and
% create an .html file with the output.