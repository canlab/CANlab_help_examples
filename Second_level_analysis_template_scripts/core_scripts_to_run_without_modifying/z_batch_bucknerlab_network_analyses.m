masterscriptdir = which('Second_level_analysis_template_scripts/0_begin_here_readme');

if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
end


%% SUMMARY

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile('Second_level_analysis_template_scripts', 'b_reload_saved_matfiles'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


%% BUCKNERLAB NETWORK RIVER PLOTS
printhdr('RIVER PLOTS OF NETWORKS')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'g2_bucknerlab_network_riverplots'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% BUCKNERLAB NETWORK BAR PLOTS
printhdr('BAR PLOTS OF NETWORKS')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'f2_bucknerlab_network_barplots'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

