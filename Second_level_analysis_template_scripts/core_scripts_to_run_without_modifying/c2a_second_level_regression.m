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

for c = 1:ncontrasts
    
    %%
    analysisname = regression_stats_results{c}.analysis_name;
    names = regression_stats_results{c}.variable_names;
    t = regression_stats_results{c}.t;
    
    printhdr(analysisname)
    disp('Regressors: ')
    disp(names)
    
    if isfield(regression_stats_results{c}, 'design_table')
        disp(regression_stats_results{c}.design_table);
    end
    
    num_effects = size(t.dat, 2); % number of image effects
    
    % create figure
    o2 = canlab_results_fmridisplay([], 'multirow', num_effects);
    
    % REGRESSOR & INTERCEPT: Orthviews at 0.01 uncorrected
    % ----------------------------------------------    
    
    for j = 1:num_effects
        
        fprintf ('\n Displayed at 0.01 uncorr: %s\nEffect:%s\n', analysisname, names{j});
        
        tj = get_wh_image(t, j);
        tj = threshold(tj, .01, 'unc');  % two-tailed
    
        o2 = addblobs(o2, region(tj), 'wh_montages', (2*j)-1:2*j);
        o2 = title_montage(o2, 2*j, [analysisname ' ' names{j}]);

    end
    
    figtitle = sprintf('Regression results 01_unc %s', analysisname);
    set(gcf, 'Tag', figtitle);
    plugin_save_figure;

    
    for j = 1:num_effects
        
        tj = get_wh_image(t, j);
        tj = threshold(tj, .01, 'unc', 'k', 20);
        
        printhdr(sprintf('Regression %s 01_unc_k20 %s', names{j}, analysisname));
        
        wedge_plot_by_atlas(tj, 'atlases', {'buckner' 'bg' 'thalamus'});
        
        figtitle = sprintf('Regression wedge %s 01_unc_k20 %s', names{j}, analysisname);
        set(gcf, 'Tag', figtitle);
        plugin_save_figure;
        
        table(region(tj));
        
        disp(dashes)
        disp(' ');
        
    end

    
    % REGRESSOR & INTERCEPT: Orthviews at 0.05 FDR-corrected
    % ----------------------------------------------
   
    o2 = removeblobs(o2);
    
    for j = 1:num_effects
        
        fprintf ('\n Displayed at FDR q < 0.05: %s\nEffect:%s\n', analysisname, names{j});
        
        tj = get_wh_image(t, j);
        tj = threshold(tj, .05, 'fdr');  % two-tailed
    
        o2 = addblobs(o2, region(tj), 'wh_montages', (2*j)-1:2*j);
        o2 = title_montage(o2, 2*j, [analysisname ' ' names{j}]);

    end
    
    figtitle = sprintf('Regression results 05_FDR %s', analysisname);
    set(gcf, 'Tag', figtitle);
    plugin_save_figure;
    
    for j = 1:num_effects
        
        tj = get_wh_image(t, j);
        tj = threshold(tj, .05, 'fdr');
        
        printhdr(sprintf('Regression %s 05_FDR %s', names{j}, analysisname));
        
        wedge_plot_by_atlas(tj, 'atlases', {'buckner' 'bg' 'thalamus'});
        
        figtitle = sprintf('Regression wedge %s 05_FDR %s', names{j}, analysisname);
        set(gcf, 'Tag', figtitle);
        plugin_save_figure;
        
        table(region(tj));
        
        disp(dashes)
        disp(' ');
        
    end
    
end % c contrasts

