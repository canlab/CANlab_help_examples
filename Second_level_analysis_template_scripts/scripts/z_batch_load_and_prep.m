
% Edit these two before running
% -------------------------------------------------------
a_set_up_paths_always_run_first

prep_1_set_conditions_contrasts_colors

printhdr('BEHAVIORAL DATA - BETWEEN-PERSON DESIGN')

prep1b_prep_behavioral_data

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

%% SIGNATURE PREP

printhdr('SIGNATURE EXTRACTION')
prep_4_apply_signatures_and_save
