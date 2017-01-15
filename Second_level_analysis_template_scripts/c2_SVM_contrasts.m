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
    % b. Define holdout sets: Leave one subject out
    %    Assume that subjects are in same position in each input file
    % --------------------------------------------------------------------

    outcome_value = zeros(size(condition_codes));
    holdout_set = {};
    
    for i = 1:length(wh)

        n = sum(condition_codes == i);
        holdout_set{i} = [1:n]';
        
        outcome_value(condition_codes == i) = sign(mycontrast(wh(i)));
        
    end
    
    holdout_set = cat(1, holdout_set{:});
    cat_obj.Y = outcome_value;
    
    % Run prediction model
    % --------------------------------------------------------------------

    [cverr, stats, optout] = predict(cat_obj, 'algorithm_name', 'cv_svm', 'nfolds', holdout_set, 'error_type', 'mcr');
    
    % Summarize output and create ROC plot
    % -------------------------------------------------------------------- 
    
    create_figure('ROC');
    printstr(DAT.contrastnames{c}); printstr(dashes);
    
    ROC = roc_plot(stats.dist_from_hyperplane_xval, logical(cat_obj.Y > 0), 'color', DAT.contrastcolors{c}, 'twochoice');
    
    drawnow, snapnow
    figtitle = sprintf('SVM ROC %s', DAT.contrastnames{c});
    savename = fullfile(figsavedir, [figtitle '.png']);
    saveas(gcf, savename);

    % Plot the SVM map
    % --------------------------------------------------------------------
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(stats.weight_obj), 'trans');
        
    axes(o2.montage{whmontage}.axis_handles(5));
    title(DAT.contrastnames{c}, 'FontSize', 18)
    
    printstr(DAT.contrastnames{c}); printstr(dashes);
    drawnow, snapnow
    figtitle = sprintf('SVM weight map nothresh %s', DAT.contrastnames{c});
    savename = fullfile(figsavedir, [figtitle '.png']);
    saveas(gcf, savename);
    
end  % contrast