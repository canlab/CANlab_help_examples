masterscriptdir = which('Second_level_analysis_template_scripts/0_begin_here_readme');

if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
end


%% SUMMARY

% Load and print summary of study from study_info.json and contrast info
% -------------------------------------------------------------------------
scriptname = which(fullfile('Second_level_analysis_template_scripts', 'b_reload_saved_matfiles'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

% LOAD ALL SUMMARY TEXT FILES AND DISPLAY IN REPORT
% -------------------------------------------------------------------------

myfiles = dir(fullfile(resultsdir, '*summary_text'));

for i = 1:length(myfiles)
    
    mytext = fileread(fullfile(resultsdir, myfiles(i).name));
    printhdr(myfiles(i).name);
    disp(mytext);
    disp(' ');
    
end

%% SIGNATURE RIVER PLOTS
printhdr('RIVER PLOTS OF SIGNATURES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd10_signature_riverplots'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


%% NETWORK POLAR PLOTS
printhdr('BAR PLOTS OF NETWORKS AND SIGNATURES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd11_signature_similarity_barplots'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


%% PAIN SIGNATURES
printhdr('PAIN-RELATED SIGNATURE RESPONSES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd1_pain_signature_responses_dotproduct'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd2_pain_signature_responses'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd3_plot_nps_subregions_bars'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% EMOTION SIGNATURES
printhdr('EMOTION-RELATED SIGNATURE RESPONSES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd5_emotion_signature_responses'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% EMPATHY SIGNATURES
printhdr('EMPATHY-RELATED SIGNATURE RESPONSES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd6_empathy_signature_responses'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% AUTONOMIC SIGNATURES
printhdr('AUTONOMIC-RELATED SIGNATURE RESPONSES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd7_autonomic_signature_responses'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% FIBROMYALGIA SIGNATURES
printhdr('FIBROMYALGIA-RELATED SIGNATURE RESPONSES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd8_fibromyalgia_signature_responses'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.



% Close to save memory when publishing to html
close all

%% GROUP DIFFERENCES

printhdr('GROUP DIFFERENCES IN NPS RESPONSES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'h_group_differences'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% GLOBAL SIGNAL AND ALTERNATE SCALING

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd9_nps_correlations_with_global_signal'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'core_scripts_to_run_without_modifying', 'd4_compare_NPS_SIIPS_scaling_similarity_metrics'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.



% %% GROUP ANCOVA
% 
% printhdr('GROUP ANCOVA WITH STIM INTENSITY')
% 
% i_ancova_stimintensity_nps


