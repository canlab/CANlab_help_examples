% THIS SCRIPT RUNS SVMs for WITHIN-PERSON CONTRASTS
% Specified in DAT.contrasts
% --------------------------------------------------------------------

% Initialize slice display if needed, or clear existing display
% --------------------------------------------------------------------

if ~exist('o2', 'var') || ~isa(o2, 'fmridisplay')
    create_figure('fmridisplay'); axis off
    o2 = canlab_results_fmridisplay([], 'noverbose');
    whmontage = 5; % for title
else
    o2 = removeblobs(o2);
    axes(o2.montage{whmontage}.axis_handles(5));
    title(' ');
end

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
    
    ROC = roc_plot(stats.dist_from_hyperplane_xval, logical(cat_obj.Y > 0), 'color', DAT.contrastcolors{c}, 'twochoice');
    
    figtitle = sprintf('SVM ROC %s', DAT.contrastnames{c});
    savename = fullfile(figsavedir, [figtitle '.png']);
    saveas(gcf, savename);
    drawnow, snapnow
    
    % Effect size, cross-validated, paired samples
    dfun2 = @(x, Y) mean(x(Y > 0) - x(Y < 0)) ./ std(x(Y > 0) - x(Y < 0));
    d = dfun2(stats.dist_from_hyperplane_xval, stats.Y);
    fprintf('Effect size, cross-val: d = %3.2f\n\n', d);
    

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

