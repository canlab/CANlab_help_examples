
% Step 1: Create a main analysis folder <basedir> and navigate there
% -------------------------------------------------------------------------
% Run: 
a_set_up_new_analysis_folder_and_scripts            % Creates local folders and copies in relevant scripts

% Step 2: Edit these files in you local analysis  folder and save:
% -------------------------------------------------------------------------
study_info.json                                     % File with study/author meta-data, for reports and archive
a_set_up_paths_always_run_first.m                   % Modify to specify your local analysis folder name 
a2_set_default_options.m                            % Options used in various other scripts; change if desired, or not 
prep_1b_prep_behavioral_data.m / prep_1b_example2.m % Optional: Modify one of these to load and attach behavioral data from files (e.g., from Excel)            
			 
prep_1_set_conditions_contrasts_colors.m            % Modify: Specify image file subdirs, wildcards to locate images, condition names and contrasts across conditions
prep_1c_normalize_to_MNI.m                          % Optional script to modify and use only if data are not yet in MNI space; otherwise ignore

prep_0_batch_run_once.m	

% Step 3: Load and prepare contrast images and analyses:
% -------------------------------------------------------------------------
% You only need to run this once if it runs correctly. Relevant info
% is extracted from images and saved in standard variable names for
% reloading and results-on-demand later.

a_set_up_paths_always_run_first.m                   % Always run this first before you run other scripts.
    % Runs: a2_set_default_options
prep_1b_prep_behavioral_data.m / prep_1b_example2.m % Optional: Run these load and attach behavioral data from files (e.g., from Excel)            
prep_1_set_conditions_contrasts_colors.m            % Modify to specify image file subdirectories, wildcards to locate images, condition names
prep_2_load_image_data_and_save.m                   % Load image data into fmri_data objects and save
prep_3_calc_univariate_contrast_maps_and_save.m     % Apply contrasts to fmri_data objects 
prep_3a_run_second_level_regression_and_save.m      % [Optional] if you have entered continuous regressors in prep_1b, run regression
prep_3b_run_SVMs_on_contrasts_and_save.m            % [Optional] run cross-val SVMs on within-person contrasts
prep_3c_run_SVMs_on_contrasts_masked.m              % [Optional] run cross-val SVMs on within-person contrasts, within a mask
prep_3d_run_SVM_betweenperson_contrasts.m           % [Optional] run cross-val SVMs on within-person contrasts, within a mask% [Optional] run cross-val SVMs across conditions, assuming subjects nested within conditions (e.g., if diff conditions are diff subjects)
prep_4_apply_signatures_and_save.m                  % Apply CANlab signature patterns and attach output (values) to DAT
prep_5_apply_shen_parcellation_and_save.m           % [Optional] Extract data from each condition/contrast averaged over each parcel, save file with values
prep_5b_apply_spmanatomy_parcellation_and_save.m    % [Optional] Extract data from each condition/contrast averaged over each parcel, save file with values
prep_6_apply_kragel_emotion_signatures_and_save.m   % [Optional] Apply Kragel emotion signature patterns and attach output (values) to DAT

% An alternative, once you feel comfortable with the setup, is to run a
% batch script with this sequence. 
% All scripts with "publish" in the name print date-stamped HTML reports.

z_batch_publish_image_prep_and_qc.m

% Step 4: Run scripts to generate on-demand results:
% -------------------------------------------------------------------------
% Always "set up paths" and "reload" before you do anything else.  After
% that, these scripts should (theoretically) be runnable in any order to
% generate figures and tables of results. The scripts use simple commands
% and are designed to be guides for you to add your own custom scripts if
% you want to, and to pick and choose for your study.



% This batch script allows you to run a menu of different sets of results
% (contrasts, svm analyses, signature analyses, etc.) in any order:
z_batch_publish_analyses.m

% This batch script runs both the data load batch and all results:
z_batch_publish_everything.m

% These batch scripts are run in "publish" scripsts. You can run them on
% their own, too, but "set up paths" and "reload" first. 

z_batch_load_and_prep.m
z_batch_coverage_and_contrasts.m
z_batch_svm_analysis.m
z_batch_signature_analyses.m
z_batch_bucknerlab_network_analyses.m
z_batch_meta_analysis_mask_analyses.m

