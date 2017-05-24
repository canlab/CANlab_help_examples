% THIS SCRIPT RUNS SVMs for WITHIN-PERSON CONTRASTS
% Specified in DAT.contrasts
% --------------------------------------------------------------------

spath = which('use_spider.m');
if isempty(spath)
    disp('Warning: spider toolbox not found on path; prediction may break')
end

% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
whmontage = 5; 
plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------

printhdr('Cross-validated SVM to discriminate contrasts');

% create_figure('SVM weight map'); axis off
% o2 = canlab_results_fmridisplay;

kc = size(DAT.contrasts, 1);

for c = 1:kc
    
    printstr(DAT.contrastnames{c});
    printstr(dashes)
    
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    % Create combined data object with all input images
    % --------------------------------------------------------------------
    [cat_obj, condition_codes] = cat(DATA_OBJ{wh});
    
    % a. Format and attach outcomes: 1, -1 for pos/neg contrast values
    % b. Define holdout sets: Define based on plugin script
    %    Assume that subjects are in same position in each input file
    % --------------------------------------------------------------------

    plugin_get_holdout_sets;
    
    cat_obj.Y = outcome_value;
    
    % Skip if necessary
    % --------------------------------------------------------------------
    
    if all(cat_obj.Y > 0) || all(cat_obj.Y < 0)
        % Only positive or negative weights - nothing to compare
        
        printhdr(' Only positive or negative weights - nothing to compare');
        
        continue    
    end
    
    % Run prediction model
    % --------------------------------------------------------------------

    [cverr, stats, optout] = predict(cat_obj, 'algorithm_name', 'cv_svm', 'nfolds', holdout_set, 'error_type', 'mcr');
    

    % Summarize output and create ROC plot
    % -------------------------------------------------------------------- 
    
    create_figure('ROC');
    disp(' ');
    printstr(['Results: ' DAT.contrastnames{c}]); printstr(dashes);
    
    % ROC plot is different for paired samples and unpaired. Paired samples
    % must be in specific order, 1:n for condition 1 and 1:n for condition 2.
    % If samples are paired, this is set up by default in these scripts.
    % But some contrasts entered by the user may be unbalanced, so check
    % for this here and run paired or unpaired as appropriate.
    
    ispaired = sum(cat_obj.Y > 0) == sum(cat_obj.Y < 0);
    
    if ispaired
        rocpairstring = 'twochoice';
        
        % Effect size, cross-validated, paired samples
        dfun2 = @(x, Y) mean(x(Y > 0) - x(Y < 0)) ./ std(x(Y > 0) - x(Y < 0));
        
    else
        rocpairstring = 'unpaired';
        
        % Effect size, cross-validated, unpaired sampled
        dfun2 = @(x, Y) (mean(x(Y > 0)) - mean(x(Y < 0))) ./ sqrt(var(x(Y > 0)) + var(x(Y < 0))); % check this.
        
    end
        
    ROC = roc_plot(stats.dist_from_hyperplane_xval, logical(cat_obj.Y > 0), 'color', DAT.contrastcolors{c}, rocpairstring);
    
    d = dfun2(stats.dist_from_hyperplane_xval, stats.Y);
    fprintf('Effect size, cross-val: d = %3.2f\n\n', d);
    
    figtitle = sprintf('SVM ROC %s', DAT.contrastnames{c});
    plugin_save_figure
    

    % Plot the SVM map
    % --------------------------------------------------------------------
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
    
end  % within-person contrast

