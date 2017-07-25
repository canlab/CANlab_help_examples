
% Edit these two before running
% -------------------------------------------------------
a_set_up_paths_always_run_first

a2_set_default_options

prep_1_set_conditions_contrasts_colors

printhdr('BEHAVIORAL DATA - BETWEEN-PERSON DESIGN')

try
    prep1b_prep_behavioral_data
catch
    disp('prep1b_prep_behavioral_data.m did not run correctly. Either configure and test this or omit this script.');
end

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

%% SVMs with optional bootstrapping

printhdr('CONTRAST SUPPORT VECTOR MACHINES')
prep_3b_run_SVMs_on_contrasts_and_save

% You can also run z_batch_publish_image_prep_and_qc to run these and
% create an .html file with the output.

%% SIGNATURE PREP

printhdr('SIGNATURE EXTRACTION')
prep_4_apply_signatures_and_save

%% PARCELLATION PREP

try 
    printhdr('PARCELLATIONS')
    prep_5_apply_shen_parcellation_and_save
    prep_5b_apply_spmanatomy_parcellation_and_save
catch 
    warning('Parcellation image atlas not on path. Images stored on Canlab Drive. Contact Canlab if you want to include this step.')
end

%% EMOTION MAPS

printhdr('EMOTION MAPS')
prep_6_apply_kragel_emotion_signatures_and_save

