masterscriptdir = which('Second_level_analysis_template_scripts/0_begin_here_readme');

if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
end


%% SIGNATURE RIVER PLOTS
printhdr('RIVER PLOTS OF SIGNATURES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'g_signature_riverplots'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


%% NETWORK POLAR PLOTS
printhdr('BAR PLOTS OF NETWORKS AND SIGNATURES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'f3_signature_similarity_barplots'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


%% NPS
printhdr('NPS RESPONSES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'd_plot_NPS_responses'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.


scriptname = which(fullfile('Second_level_analysis_template_scripts', 'd2_plot_nps_subregions_bars'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

% %% SIIPS
% % This is redundant with plots by signature below, but is included as an example
% 
% printhdr('SIIPS RESPONSES')
% 
% scriptname = which(fullfile('Second_level_analysis_template_scripts', 'd_plot_SIIPS_responses'));
% run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% VIOLIN PLOTS BY SIGNATURE 

printhdr('VIOLIN PLOTS BY SIGNATURE')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'e_plot_signature_responses'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% GROUP DIFFERENCES

printhdr('GROUP DIFFERENCES IN NPS RESPONSES')

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'h_group_differences'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

%% GLOBAL SIGNAL AND ALTERNATE SCALING

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'd2_nps_correlations_with_global_signal'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.

scriptname = which(fullfile('Second_level_analysis_template_scripts', 'd3_compare_NPS_SIIPS_scaling_similarity_metrics'));
run(scriptname); % Run from master script, not local script. This script should not need to be edited for individual studies.



% %% GROUP ANCOVA
% 
% printhdr('GROUP ANCOVA WITH STIM INTENSITY')
% 
% i_ancova_stimintensity_nps


