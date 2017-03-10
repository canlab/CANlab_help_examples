%% COVERAGE

b2_show_data_vs_underlay

%% UNIVARIATE CONTRASTS
printhdr('UNIVARIATE CONTRAST MAPS')

c_univariate_contrast_maps

%%% RE-TRAINED WHOLE BRAIN SVM

%printhdr('RE-TRAINED WHOLE BRAIN SVM OMITTED - MISSING RUN 2s')
%c2_SVM_contrasts

%% NPS
printhdr('NPS RESPONSES')

d_apply_nps


%% VIOLIN PLOTS BY SIGNATURE 

printhdr('VIOLIN PLOTS BY SIGNATURE')

e_plot_signature_responses

%% GROUP DIFFERENCES

printhdr('GROUP DIFFERENCES IN NPS RESPONSES')

h_group_differences

%% GLOBAL SIGNAL AND ALTERNATE SCALING

d2_nps_correlations_with_global_signal

d3_compare_NPS_SIIPS_scaling_similarity_metrics

%% NETWORK POLAR PLOTS
printhdr('BAR PLOTS OF NETWORKS AND SIGNATURES')

f2_signature_network_barplots

%% NETWORK RIVER PLOTS
printhdr('RIVER PLOTS OF NETWORKS')

g_signature_network_riverplots
