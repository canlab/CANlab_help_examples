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

% QUICK START - STEPS TO SET UP A NEW ANALYSIS ON A DATASET
% ------------------------------------------------------------------------

% Copy TEMPLATE scripts into STUDY FOLDER/scripts for your new study.
cd('STUDY FOLDER/scripts')

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


