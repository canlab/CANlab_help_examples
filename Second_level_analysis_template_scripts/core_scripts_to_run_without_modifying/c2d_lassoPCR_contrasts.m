% THIS SCRIPT RUNS lassoPCR models for WITHIN-PERSON CONTRASTS it will
% exclude data which have values of 0 and contrasts that are binary (1/-1)
% Specified in DAT.contrasts
% --------------------------------------------------------------------


% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
whmontage = 5; 
plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------

printhdr('Cross-validated lassoPCR to predict contrast values');

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

    plugin_get_holdout_sets_lasso;
    
    cat_obj.Y = outcome_value;
    
    % Skip if necessary
    % --------------------------------------------------------------------
    
    if all(cat_obj.Y > 0) || all(cat_obj.Y < 0)
        % Only positive or negative weights - nothing to compare
        
        printhdr(' Only positive or negative weights - nothing to compare');
        
        continue    
    end
    
    %remove values that are 0
    
    remove=cat_obj.Y==0;
    cat_obj.Y=cat_obj.Y(~remove);
    cat_obj.dat=cat_obj.dat(:,~remove);
    
    % Run prediction model
    % --------------------------------------------------------------------

    [cverr, stats, optout] = predict(cat_obj, 'algorithm_name', 'cv_lassopcr', 'nfolds', holdout_set);
    
    
    
    %Run permuted prediction
    %---------------------------------------------------------------------
    for it=1:100
        random_inds=randperm(length(cat_obj.Y));
        temp_dat=cat_obj;
        temp_dat.Y=temp_dat.Y(random_inds);
        [~, stats_null(it)] = predict(temp_dat, 'algorithm_name', 'cv_lassopcr', 'nfolds', holdout_set);
    it/100
    end
    clear temp_dat;
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
        
    ROC = roc_plot(stats.yfit, logical(cat_obj.Y > 0), 'color', DAT.contrastcolors{c}, rocpairstring);
    
    d = dfun2(stats.yfit, stats.Y);
    fprintf('Effect size, cross-val: d = %3.2f\n\n', d);
    fprintf('Correelation between observed and predicted outcomes, cross-val: r = %3.2f\n\n', corr(stats.yfit, stats.Y));

    figtitle = sprintf('lassoPCR ROC %s', DAT.contrastnames{c});
    plugin_save_figure
    

    % Plot the weight map
    % --------------------------------------------------------------------
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(stats.weight_obj), 'trans');
        
    axes(o2.montage{whmontage}.axis_handles(5));
    title(DAT.contrastnames{c}, 'FontSize', 18)
    
    printstr(DAT.contrastnames{c}); printstr(dashes);
    
    figtitle = sprintf('lassoPCR weight map nothresh %s', DAT.contrastnames{c});
    plugin_save_figure;
    
    % Remove title in case fig is re-printed in html
    axes(o2.montage{whmontage}.axis_handles(5));
    title(' ', 'FontSize', 18)
    
    o2 = removeblobs(o2);
    
end  % within-person contrast

