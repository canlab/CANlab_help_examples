masterscriptdir = which('Second_level_analysis_template_scripts/0_begin_here_readme');

if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
end


%% SUMMARY

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'b_reload_saved_matfiles'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


%% BUHLE 2014 EMOTION META-ANALYSIS PATTERN AND ROI ANALYSES

printhdr('BUHLE 2014 EMOTION META-ANALYSIS PATTERN AND ROI ANALYSES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'k_emotionmeta_pattern_and_region_analyses'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

