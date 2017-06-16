
%% Load stats
savefilenamedata = fullfile(resultsdir, 'svm_stats_results_contrasts.mat');

if ~exist(savefilenamedata, 'file')
    disp('Run prep_3b_run_SVMs_on_contrasts_and_save with dosavesvmstats = true option to get SVM results.'); 
    disp('No saved results file.  Skipping this analysis.')
    return
end

fprintf('\nLoading SVM results and maps from %s\n\n', savefilenamedata);
load(savefilenamedata, 'svm_stats_results');

%% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
whmontage = 5; 
plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------

printhdr('Cross-validated SVM to discriminate within-person contrasts');

%% Average images collected on the same person within each SVM class, for testing
% --------------------------------------------------------------------

[dist_from_hyperplane, Y, svm_dist_pos_neg] = plugin_svm_contrasts_get_results_per_subject(DAT, svm_stats_results, DATA_OBJ);

%% Check that we have paired images and skip if not. See below for details
% --------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

ispaired = false(1, kc);

for i = 1:kc
    ispaired(i) = sum(Y{i} > 0) == sum(Y{i} < 0);
end

if ~all(ispaired)
    disp('This script should only be run on paired, within-person contrasts');
    disp('Check images and results. Skipping this analysis.');
    return
end


%% Define effect size functions and between/within ROC type
% --------------------------------------------------------------------
% Define paired and uppaired functions here for reference
% This script uses the paired option because it runs within-person
% contrasts

% ROC plot is different for paired samples and unpaired. Paired samples
% must be in specific order, 1:n for condition 1 and 1:n for condition 2.
% If samples are paired, this is set up by default in these scripts.
% But some contrasts entered by the user may be unbalanced, i.e., different
% numbers of images in each condition, unpaired. Other SVM scripts are set up
% to handle this condition explicitly and run the unpaired version.  

% Effect size, cross-validated, paired samples
dfun_paired = @(x, Y) mean(x(Y > 0) - x(Y < 0)) ./ std(x(Y > 0) - x(Y < 0));

% Effect size, cross-validated, unpaired sampled
dfun_unpaired = @(x, Y) (mean(x(Y > 0)) - mean(x(Y < 0))) ./ sqrt(var(x(Y > 0)) + var(x(Y < 0))); % check this.

rocpairstring = 'twochoice';  % 'twochoice' or 'unpaired'


%% Cross-validated accuracy and ROC plots for each contrast
% --------------------------------------------------------------------

for c = 1:kc
    
    printstr(DAT.contrastnames{c});
    printstr(dashes)
    
    % ROC plot
    % --------------------------------------------------------------------
    
    figtitle = sprintf('SVM ROC healthy %s', DAT.contrastnames{c});
    create_figure(figtitle);
    
    ROC = roc_plot(dist_from_hyperplane{c}, logical(Y{c} > 0), 'color', DAT.contrastcolors{c}, rocpairstring);
    
    d_paired = dfun_paired(dist_from_hyperplane{c}, Y{c});
    fprintf('Effect size, cross-val: Forced choice: d = %3.2f\n\n', d_paired);
    
    plugin_save_figure
    

    % Plot the SVM map
    % --------------------------------------------------------------------
    % Get the stats results for this contrast, with weight map
    stats = svm_stats_results{c};
    
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(stats.weight_obj), 'trans');
        
    axes(o2.montage{whmontage}.axis_handles(5));
    title(DAT.contrastnames{c}, 'FontSize', 18)
    
    printstr(DAT.contrastnames{c}); printstr(dashes);
    
    figtitle = sprintf('SVM weight map nothresh %s', DAT.contrastnames{c});
    plugin_save_figure;
    
    % Remove title in case fig is re-printed in html
    axes(o2.montage{whmontage}.axis_handles(5));
    title(' ', 'FontSize', 18)
    
    o2 = removeblobs(o2);
    
    axes(o2.montage{whmontage}.axis_handles(5));
    title('Intentionally Blank', 'FontSize', 18); % For published reports
    
end  % within-person contrast

