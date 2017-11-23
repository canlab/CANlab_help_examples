% THIS SCRIPT DISPLAYS BETWEEN-PERSON CONTRASTS as: 
% 1) The effect of DAT.BETWEENPERSON.group  
%      = 'Group'
%      - effect of the regressor with group membership 1 or -1 (e.g. order effect)
% 2) Average activation 
%      = 'Intercept'
%      - here: mean activation controlling for order effect 

% Assuming that groups are concatenated into contrast image lists.
% Requires DAT.BETWEENPERSON.group field specifying group membership for
% each image.

% --------------------------------------------
% Marta 2017 (based on existing scripts) 
% --------------------------------------------

%% LOAD REGRESSION RESULTS 
savefilenamedata = fullfile(resultsdir, 'regression_stats_and_maps.mat');

if ~exist(savefilenamedata, 'file')
    disp('Run prep_3a_run_second_level_regression_and_save.m to get regression results.'); 
    disp('No saved results file.  Skipping this analysis.')
    return
end

fprintf('\nLoading regression results and maps from %s\n\n', savefilenamedata);
load(savefilenamedata, 'regression_stats_results');


%% UNIVARIATE CONTRASTS WHOLE BRAIN

ncontrasts = size (regression_stats_results, 2);

for c=1:ncontrasts
    analysisname = regression_stats_results{c}.analysis_name;
    names = regression_stats_results{c}.variable_names;
    t = regression_stats_results{c}.t;
    disp(analysisname)
    disp(names)
    
    %% REGRESSOR & INTERCEPT: Orthviews at 0.01 uncorrected
    % ----------------------------------------------    
    t = threshold(t, .01, 'unc');  % two-tailed
    orthviews(t);
    
    % Put names on figure:
    % First image is Order effect, second is Group average (Intercept)
    nimages = size(t.dat, 2); 
    fprintf ('\n Displayed at 0.01 uncorr: %s\n\n', analysisname);
    for i = 1:nimages
        spm_orthviews_name_axis(names{i}, i);
        title({analysisname; names{i}}, 'FontSize', 18);
    end
    
    figtitle = sprintf('Regression results 01_unc %s', analysisname);
    plugin_save_figure;

    %% REGRESSOR & INTERCEPT: Orthviews at 0.05 FDR-corrected
    % ----------------------------------------------
    t = threshold(t, .05, 'fdr');
    orthviews(t) ;
    
    nimages = size(t.dat, 2); 
    fprintf ('\n Displayed at 0.05 FDR: %s\n\n', analysisname);
    for i = 1:nimages
        spm_orthviews_name_axis(names{i}, i);
        title({analysisname; names{i}}, 'FontSize', 18);
    end
    
    figtitle = sprintf('Regression results 05_FDR %s',analysisname);
    plugin_save_figure;
    
    clear figure 
    
    % ----------------------------------------------
    % Initialize fmridisplay slice display if needed, or clear existing display
    % Specify which montage to add title to. This is fixed for a given slice display
    whmontage = 5;
    plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

    %% INTERCEPT: slice display at 0.01 uncorrected
    % ----------------------------------------------  
    printstr(dashes);
    fprintf ('\n INTERCEPT at 0.01 uncorr: %s\n\n', analysisname);
    t = threshold(t, .01, 'unc');  % two-tailed
    t2=select_one_image(t, 2);
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(t2), 'splitcolor', {[0 0 1] [0 1 1] [1 .5 0] [1 1 0]});
    
    % to display at multiple thresholds 
    % o2 = removeblobs(o2);
    % o2 = multi_threshold (t2, 'o2', o2, 'thresh', [.005 .01 .05], 'sizethresh', [1 1 1]);
        % axes(o2.montage{whmontage}.axis_handles(5));

    title({analysisname; names{2}; 'unc .01'}, 'FontSize', 16);
    figtitle = sprintf('Regression slices intercept 01_unc %s',analysisname);
    plugin_save_figure;
    
    %% INTERCEPT: slice display at 0.05 FDR
    % ----------------------------------------------  
    printstr(dashes);
    fprintf ('\n INTERCEPT at 0.05 FDR: %s\n\n', analysisname);
    t = threshold(t, .05, 'fdr');
    t2=select_one_image(t, 2);
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(t2), 'splitcolor', {[0 0 1] [0 1 1] [1 .5 0] [1 1 0]});

    title({analysisname; names{2}; 'FDR .05'}, 'FontSize', 16);
    figtitle = sprintf('Regression slices intercept 05_fdr %s',analysisname);
    plugin_save_figure;
end
%%

