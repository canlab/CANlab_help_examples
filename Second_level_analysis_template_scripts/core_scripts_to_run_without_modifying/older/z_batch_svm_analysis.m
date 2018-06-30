masterscriptdir = which('Second_level_analysis_template_scripts/0_begin_here_readme');

if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
end

% CHECK DEPENDENCIES AND SET DEFAULT VARIABLES

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'a2_second_level_toolbox_check_dependencies'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

a2_set_default_options

%% Summary of data and contrasts

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'b_reload_saved_matfiles'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% Within-person, across condition WHOLE BRAIN SVM
% Contrasts across images identified in DAT.contrasts, if the contrasts have weights of 1 and -1
% Defined in prep_1_set_conditions_contrasts_colors

printhdr('Within-person, across condition WHOLE BRAIN SVM')

scriptname = which(fullfile('Second_level_analysis_template_scripts','core_scripts_to_run_without_modifying', 'c2_SVM_contrasts'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% Within-person, across condition masked SVM
% Contrasts across images identified in DAT.contrasts, if the contrasts have weights of 1 and -1
% Defined in prep_1_set_conditions_contrasts_colors

printhdr('Within-person, across condition WHOLE BRAIN SVM')

scriptname = which(fullfile('Second_level_analysis_template_scripts','core_scripts_to_run_without_modifying', 'c2_SVM_contrasts_masked'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


%% Between-person, across-condition WHOLE BRAIN SVM
% Contrasts across conditions identified in DAT.between_condition_cons
% Defined in prep_1_set_conditions_contrasts_colors

printhdr('Between-person, across-condition WHOLE BRAIN SVM')

scriptname = which(fullfile('Second_level_analysis_template_scripts','core_scripts_to_run_without_modifying', 'c2c_SVM_between_condition_contrasts'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% Between-person, within-condition WHOLE BRAIN SVM
% Within contrasts, train on groups coded 1, -1 in DAT.BETWEENPERSON.group,
% defined in prep_1b_prep_behavioral_data

printhdr('Between-person, within-condition WHOLE BRAIN SVM')

scriptname = which(fullfile('Second_level_analysis_template_scripts','core_scripts_to_run_without_modifying', 'c2b_SVM_betweenperson_contrasts'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

