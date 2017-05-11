% QUICK START - STEPS TO SET UP A NEW ANALYSIS ON A DATASET
% ------------------------------------------------------------------------

% Copy TEMPLATE scripts into STUDY FOLDER/scripts for your new study.
cd('STUDY FOLDER/scripts')

% Don't copy all the scripts -- just those you want to edit
% You must copy the batch scripts that load your study-specific file, e.g.,
% those that run a_set_up_paths_always_run_first
%
% COPY OVER these at a minimum:
% a_set_up_paths_always_run_first
% b1_behavioral_analysis
% prep_0_batch_run_once
% prep_1_set_conditions_contrasts_colors
% z_batch_load_and_prep
% z_batch_publish_analyses
% z_batch_publish_image_prep_and_qc

edit a_set_up_paths_always_run_first
edit prep_1_set_conditions_contrasts_colors

% when ready:
z_batch_load_and_prep % run('z_batch_load_and_prep.m')

% OR, to save plots and output in .html format, run: 
z_batch_publish_image_prep_and_qc

% If there are problems, you can run the individual scripts and debug:
a_set_up_paths_always_run_first
prep_1_set_conditions_contrasts_colors
prep_2_load_image_data_and_save

% When complete, run: 
z_batch_publish_analyses

% WHAT THESE TEMPLATE SCRIPTS ARE AND WHAT THEY DO
% ------------------------------------------------------------------------

% This is a set of scripts that is designed to facilitate second-level analysis
% across beta (COPE), or contrast images from a group of participants.
% It's particularly helpful for signature-based
% analysis of group data, usually starting with beta images (one image per
% subject per condition) produced by first-level GLM analyses. 
%
% Also, these scripts include "batch" scripts that run analyses and save
% HTML files with results and images, storing a time-stamped record of your
% analysis. 
%
% The philosophy is to have scripts with standardized variable names and
% minimal editing required to adapt them to a new dataset.
%
% In principle, you should *only need to edit two scripts* to customize the 
% analysis for a new dataset:
% a_set_up_paths_always_run_first.m
% prep_1_set_conditions_contrasts_colors.m
%
% Then the rest should run correctly, for most datasets
%
% You do not have to copy over all the scripts from the master
% "Second_level_analysis_template_scripts" folder to use them. You can run
% the scripts directly from the master copy - the standard versions of most 
% scripts will run without editing.
% But do not edit/customize the master scripts!  
% If you choose, you can copy any of them to your individual project directory 
% and customize them, and run those customized versions instead of the
% standard versions.
%
% FEATURES
% ------------------------------------------------------------------------
% - Time-stamped HTML printouts of all figures and results for archival/reference purposes
% - Short, modular scripts are easy to customize and extend
% - Common naming and data storage conventions across all analyses increase readability and organization
% - Separate process for loading/preparing datasets/contrasts and running analyses, to make it easier to re-run analyses quickly
% - Loading and visualization of all image sets in fmri_data for quality checks
% - Extraction of global gray, white, and CSF components
% - Quality plots and warning messages based on CSF components' relationship with gray matter and other measures
% - Regression-based rescaling of data to remove CSF components
% - Easily customizable specification of contrasts and colors
% - Voxel-wise maps for each contrast
% - SVM classifier maps for each contrast
% - Between-person contrasts and between-condition contrasts if different
%       conditions include different subjects
% - Extraction of the NPS and subregions
% - Plots and stats on NPS responses by condition and for each contrast
% - Extraction, plots, and stats on other signatures (these require access to the private CANlab masks repository): 
%   Vicarious pain (VPS), Negative emotion (PINES), Rejection, autonomic signatures, fibromyalgia, cerebral contributions to pain (SIIPS1)
% - Extraction, plots, and stats on Buckner Lab resting-state component maps
% - Polar plots and "river plots" for relationships between image sets/contrasts and resting-state maps/signatures
% - You can load and integrate text summaries and interpretation into your
%   HTML report file.

% SETTING UP A NEW ANALYSIS FOR A NEW DATASET
% ------------------------------------------------------------------------
% - Make sure you have a master folder, MASTER_FOLDER_NAME
% - Make a "scripts" subdirectory
% - copy the template scripts (including this one) into the "scripts" subdirectory
% - Edit the two scripts named above to customize
% - Then:
%   To prep the analysis and save standard folder names and data files (using
%   the canlab fmri_data object format), run:
%
%   a_set_up_paths_always_run_first.m
%   prep_1_set_conditions_contrasts_colors.m
%   prep_2_load_image_data_and_save.m
%   prep_3_calc_univariate_contrast_maps_and_save.m
%   prep_4_apply_signatures_and_save
%
%   OR
%   Run the script "prep_0_batch_run_once.m", which runs the above.
%   You should only need to run the "prep" scripts once. This saves files
%   that are re-loaded later and used in analyses.
%
% Once you have your analysis running right with no errors, run the
% "z_batch..." scripts to save a record of your analysis in
% ".../results/published_output"
%
% RUNNING AN ANALYSIS
% ------------------------------------------------------------------------
%
% - First, always run "a_set_up_paths_always_run_first.m", so that your
% paths and folder names will be set.
% - Then, run "b_reload_saved_matfiles.m", which will load the data files.
% - After that, you can run any of the analysis scripts.
% 
% - You can also run "z_batch_publish_analyses.m", which runs a whole list
% of analysis scripts and saves the results in an html file (as well as
% individual figures) in the "results" subfolder.
%
% MORE ABOUT WHAT THE SCRIPTS DO
% ------------------------------------------------------------------------
% - in "prep_" scripts: 
%   image names, conditions, contrasts, colors, global gray/white/CSF
%   values are saved automatically in a DAT structure
% 
% - Extracted fmri_data objects are saved in DATA_OBJ variables
% - Contrasts are estimated and saved in DATA_OBJ_CON variables
%
% - Files with these variables are saved automatically when you
%   run the prep scripts.  
%
%       meta-data are saved in image_names_and_setup.mat
%       image data are saved in data_objects.mat
%
%   They are loaded automatically when you run
%   "b_reload_saved_matfiles.m"
% 
% - when all scripts are working properly, run z_batch_publish_analyses.m
%   to create html report.  customize by editing z_batch_list_to_publish.m
%
% - saved in results folder:
%   figures
%   html report with figures and stats, in "published_output"


