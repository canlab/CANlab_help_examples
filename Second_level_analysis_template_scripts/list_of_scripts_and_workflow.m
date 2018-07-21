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
%
% Think of them as a menu of items that you may want to run.  Batch scripts
% (below) run collections of these scripts and group them into published
% HTML reports.

a_set_up_paths_always_run_first.m                   % Always run this first before you run other scripts.
b_reload_saved_matfiles.m                           % Run this to reload saved and prepped files [Do not modify]

b1_behavioral_analysis.m                            % Optional: Modify/customize for your study. The default script is an example only. 

% For all the scripts below, you can run them "out of the box" without
% customizing them for your study, as long as your prep_* scripts have run
% correctly and you have reloaded data with a_set_up_paths_always_run_first + b_reload_saved_matfiles

b2_show_data_vs_underlay.m                          % Show first condition image over canonical brain to check registration and coverage. 
c2_SVM_contrasts.m                                  % Show SVM results (from prep_3b_run_SVMs_on_contrasts_and_save) 
c2_SVM_contrasts_masked.m                           % Show SVM results (from prep_3b_run_SVMs_on_contrasts_masked) 
c2a_second_level_regression.m                       % Show regression results (from prep_3a_run_second_level_regression_and_save)
c2b_SVM_betweenperson_contrasts.m                   % Show SVM results (from prep_3d_run_SVM_betweenperson_contrasts)
c2c_SVM_between_condition_contrasts.m               % Show SVM results (run-on-demand, no prep script yet)
c2d_lassoPCR_contrasts.m                            % Multivariate cross-validated regression results (for, e.g., linear contrasts across multiple conditions)

c_univariate_contrast_maps.m                        % Show voxel-wise maps for all contrasts, FDR-corrected and uncorrected; tables
c3_univariate_contrast_maps_scaleddata.m            % Show voxel-wise contrast maps for scaled/cleaned data

c4_univ_contrast_wedge_plot_and_lateralization_test.m   % Test contrasts and lateralization across 16 large-scale rsFMRI networks with L/R divisions
c5_univ_contrast_wedge_plot_and_lateralization_test_scaled_data.m 

d1_pain_signature_responses_dotproduct.m            % Test and report extracted "signature" responses (from prep_4_apply_signatures_and_save)
d2_pain_signature_responses.m                       % Test and report extracted "signature" responses with cosine_similarity metric (from prep_4_apply_signatures_and_save)
d3_plot_nps_subregions.m                            % Test and report Neurologic Pain Signature subregions (from prep_4_apply_signatures_and_save)
d3_plot_nps_subregions_bars.m
d4_compare_NPS_SIIPS_scaling_similarity_metrics.m   % Test and report extracted "signature" responses with multiple similarity metrics (from prep_4_apply_signatures_and_save)
d5_emotion_signature_responses.m                    
d6_empathy_signature_responses.m
d7_autonomic_signature_responses.m
d8_fibromyalgia_signature_responses.m
d9_nps_correlations_with_global_signal.m            % Test and report NPS correlations with extracted global gray/white/CSF averages
d10_signature_riverplots.m                          % "River plots" show relationships between each condition (and contrast) and a set of "signatures"
d11_signature_similarity_barplots.m                 % Bar plots showing relationships between each condition (and contrast) and a set of "signatures"
d12_kragel_emotion_signature_responses.m 
d13_kragel_emotion_riverplots.m
d14_kragel_emotion_signature_similarity_barplots.m

f2_bucknerlab_network_barplots.m                    % Contrasts analyzed according to 7 Buckner Lab cortical networks from Yeo et al. 2011             
f2_bucknerlab_network_wedgeplots.m
g2_bucknerlab_network_riverplots.m

h2_group_differences_emosignatures.m                % Group differences in signatures, using "Group" variable in DAT. See prep_1b_prep_behavioral_data.m
h3_kragel_patterns_group_differences.m
h_group_differences.m

j1_display_parcels.m
k2_neurosynth_cogcontrol_pattern_and_region_analyses.m
k_emotionmeta_pattern_and_region_analyses.m         % For contrasts, pattern of interest and region-of-interest analyses defined based on Silvers, Buhle et al. emotion regulation meta-analysis

% Step 5: Run batch scripts that publish date-stamped HTML reports
% -------------------------------------------------------------------------
% These run and save reports in the "published_output" subfolder in your analysis directory
% This allows for archiving and records of the analysis history.

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

