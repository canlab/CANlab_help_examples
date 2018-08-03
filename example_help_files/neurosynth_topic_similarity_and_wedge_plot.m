% test_dat = load_image_set('npsplus', 'noverbose');
%  image_obj = get_wh_image(test_dat, 1);

test_dat = load_image_set('emotionreg', 'noverbose');
 image_obj = mean(test_dat);


% If data file is not found:
% cd('/Users/tor/Google_Drive/CanlabDataRepository/Neuroimaging_Autolabeler')
% g =genpath(pwd); addpath(g); savepath

%% Run neurosynth similarity

[image_by_feature_correlations, top_feature_tables] = neurosynth_feature_labels( image_obj, 'images_are_replicates', false, 'noverbose');

% Example for NPS: 
%     testr_low      words_low      testr_high      words_high   
%     _________    _____________    __________    _______________
% 
%     -0.22531     'object'         0.27001       'pain'         
%      -0.2179     'recognition'    0.26484       'stimulation'  
%     -0.21431     'objects'        0.26199       'heat'         
%     -0.21123     'visual'         0.25992       'noxious'      
%     -0.20244     'reading'        0.25942       'painful'      
%     -0.20204     'perceptual'     0.24892       'sensation'    
%     -0.19627     'words'           0.2354       'nociceptive'  
%     -0.19202     'read'           0.23043       'somatosensory'
%     -0.18744     'semantic'       0.22025       'temperature'  
%     -0.18732     'memory'         0.20817       'sensory'      

%% Aggregate results for plot

lowwords = [top_feature_tables{1}.words_low(:)]';
disp(lowwords)

highwords = [top_feature_tables{1}.words_high(:)]';
disp(highwords)

r_low = top_feature_tables{1}.testr_low;
r_high = top_feature_tables{1}.testr_high;

r_to_plot = [r_high; r_low];
textlabels = [ highwords lowwords];


%%

create_figure('wedge_plot');

%hh = tor_wedge_plot(r_to_plot, textlabels, 'outer_circle_radius', .3, 'colors', {[1 .7 0] [.4 0 .8]}, 'nofigure');

hh = tor_wedge_plot(r_to_plot, textlabels, 'outer_circle_radius', .3, 'colors', {[1 .7 0] [.4 0 .8]}, 'bicolor', 'nofigure');

