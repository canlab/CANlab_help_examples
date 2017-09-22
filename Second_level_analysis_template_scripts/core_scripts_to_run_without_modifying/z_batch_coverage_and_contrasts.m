masterscriptdir = which('Second_level_analysis_template_scripts/0_begin_here_readme');

if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
end

%% CHECK DEPENDENCIES AND SET DEFAULT VARIABLES

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'a2_second_level_toolbox_check_dependencies'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

a2_set_default_options

%% LOAD AND SUMMARY

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'b_reload_saved_matfiles'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% COVERAGE

scriptname = which(fullfile('Second_level_analysis_template_scripts','core_scripts_to_run_without_modifying', 'b2_show_data_vs_underlay'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% UNIVARIATE CONTRASTS
printhdr('UNIVARIATE CONTRAST MAPS')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'c_univariate_contrast_maps'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

