% test_dat = load_image_set('npsplus', 'noverbose');
%  image_obj = get_wh_image(test_dat, 1);

% test_dat = load_image_set('emotionreg', 'noverbose');
%  image_obj = mean(test_dat);
 
test_dat = load_image_set('pain_pdm');
image_obj = test_dat.get_wh_image(1);

% Note: You need the Neurosynth Feature Set 1 file
% It can be found on Dropbox here. You need to add it to your matlab path
% before you run this script.
% https://www.dropbox.com/s/rgfymakk6whr06o/Yarkoni_2013_Neurosynth_featureset1.mat?dl=0
%
% If you have access to the CANLab data reposity google drive folder, the file is also here:
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

% Example for cPDM:
%     testr_low      words_low      testr_high      words_high   
%     _________    _____________    __________    _______________
% 
%     -0.24189     'objects'         0.39314      'pain'         
%     -0.24171     'object'          0.37668      'sensation'    
%     -0.23679     'recognition'     0.36646      'painful'      
%     -0.23183     'memory'          0.36146      'stimulation'  
%     -0.20987     'intention'       0.34066      'heat'         
%     -0.19942     'judgment'          0.339      'noxious'      
%     -0.19696     'mental'          0.32824      'somatosensory'
%     -0.18262     'familiar'        0.29334      'sensory'      
%      -0.1684     'grasping'         0.2716      'foot'         
%     -0.16751     'semantic'        0.26118      'muscle'  
    
%     testr_low       words_low       testr_high     words_high 
%     _________    _______________    __________    ____________
% 
%     -0.23326     'stimulation'        0.2495      'monitoring'
%     -0.19523     'frequency'         0.24703      'control'   
%     -0.17128     'noise'             0.24036      'memory'    
%     -0.16888     'male'              0.23539      'working'   
%     -0.15396     'adaptation'        0.22153      'demand'    
%     -0.15345     'female'            0.22031      'demands'   
%     -0.15209     'somatosensory'     0.21877      'executive' 
%     -0.15023     'images'            0.21601      'correct'   
%     -0.14991     'animal'            0.21213      'knowledge' 
%     -0.13918     'sensory'           0.19795      'conflict' 


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

