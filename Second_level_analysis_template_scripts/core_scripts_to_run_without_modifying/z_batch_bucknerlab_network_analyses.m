plugin_find_master_script_directory

%% Summary of dataset

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile('Second_level_analysis_template_scripts', 'b_reload_saved_matfiles'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


%% Bucknerlab network river plots
printhdr('RIVER PLOTS OF NETWORKS')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'g2_bucknerlab_network_riverplots'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% Bucknerlab network wedge plots
printhdr('WEDGE PLOTS OF NETWORKS')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'f2_bucknerlab_network_wedgeplots'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% Bucknerlab network bar plots
printhdr('BAR PLOTS OF NETWORKS')

% scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'f2_bucknerlab_network_barplots'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


