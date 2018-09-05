plugin_find_master_script_directory;

%% CHECK DEPENDENCIES AND SET DEFAULT VARIABLES

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile(masterscriptdir, 'a2_second_level_toolbox_check_dependencies'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

a2_set_default_options

%% LOAD AND SUMMARY

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile(masterscriptdir, 'core_scripts_to_run_without_modifying', 'b_reload_saved_matfiles'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% COVERAGE

scriptname = which(fullfile(masterscriptdir, 'core_scripts_to_run_without_modifying', 'b2_show_data_vs_underlay'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% UNIVARIATE CONTRASTS
printhdr('UNIVARIATE CONTRAST MAPS')

scriptname = which(fullfile(masterscriptdir, 'core_scripts_to_run_without_modifying', 'c_univariate_contrast_maps'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% UNIVARIATE CONTRASTS - SCALED DATA
printhdr('UNIVARIATE CONTRAST MAPS - SCALED DATA')

scriptname = which(fullfile(masterscriptdir, 'core_scripts_to_run_without_modifying', 'c_univariate_contrast_maps_scaleddata'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% NETWORK AVERAGES AND LATERALIZATION FOR EACH CONTRAST

printhdr('NETWORK AVERAGES AND LATERALIZATION FOR EACH CONTRAST')

scriptname = which(fullfile(masterscriptdir, 'core_scripts_to_run_without_modifying', 'c4_univ_contrast_wedge_plot_and_lateralization_test'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% NETWORK AVERAGES AND LATERALIZATION FOR EACH CONTRAST

printhdr('NETWORK AVERAGES AND LATERALIZATION - SCALED DATA')

scriptname = which(fullfile(masterscriptdir, 'core_scripts_to_run_without_modifying', 'c5_univ_contrast_wedge_plot_and_lateralization_test_scaled_data'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.



