masterscriptdir = which('Second_level_analysis_template_scripts/0_begin_here_readme');

if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
end

%% COVERAGE

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'b2_show_data_vs_underlay'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% UNIVARIATE CONTRASTS
printhdr('UNIVARIATE CONTRAST MAPS')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'c_univariate_contrast_maps'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


%% RE-TRAIN within-person WHOLE BRAIN SVM
% Contrasts across images identified in DAT.contrasts, if the contrasts have weights of 1 and -1
% Defined in prep_1_set_conditions_contrasts_colors

printhdr('RE-TRAINED within-person WHOLE BRAIN SVM')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'c2_SVM_contrasts'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% RE-TRAIN across-condition WHOLE BRAIN SVM
% Contrasts across conditions identified in DAT.between_condition_cons
% Defined in prep_1_set_conditions_contrasts_colors

printhdr('RE-TRAINED across-condition WHOLE BRAIN SVM')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'c2c_SVM_between_condition_contrasts'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% RE-TRAIN between-person WHOLE BRAIN SVM
% Within contrasts, train on groups coded 1, -1 in DAT.BETWEENPERSON.group,
% defined in prep_1b_prep_behavioral_data

printhdr('RE-TRAINED between-person WHOLE BRAIN SVM')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'c2b_SVM_betweenperson_contrasts'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

