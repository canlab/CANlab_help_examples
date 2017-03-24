%% COVERAGE

b2_show_data_vs_underlay

%% UNIVARIATE CONTRASTS
printhdr('UNIVARIATE CONTRAST MAPS')

c_univariate_contrast_maps

%% RE-TRAIN within-person WHOLE BRAIN SVM

printhdr('RE-TRAINED within-person WHOLE BRAIN SVM')
c2_SVM_contrasts

%% RE-TRAIN between-person WHOLE BRAIN SVM

printhdr('RE-TRAINED between-person WHOLE BRAIN SVM')
c2b_SVM_betweenperson_contrasts

%% NPS
printhdr('NPS RESPONSES')

d_plot_NPS_responses

d2_plot_nps_subregions_bars

%% NPS
printhdr('SIIPS RESPONSES')

d_plot_SIIPS_responses


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

%% GROUP DIFFERENCES

printhdr('GROUP DIFFERENCES')

h_group_differences

%% GROUP ANCOVA

printhdr('GROUP ANCOVA WITH STIM INTENSITY')

i_ancova_stimintensity_nps


