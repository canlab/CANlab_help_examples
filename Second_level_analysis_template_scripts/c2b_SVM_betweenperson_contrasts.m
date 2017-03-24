myscaling = 'raw';          % 'raw' or 'scaled'

% Initialize display if needed
if ~exist('o2', 'var') || ~isa(o2, 'fmridisplay')
    create_figure('fmridisplay'); axis off
    o2 = canlab_results_fmridisplay([], 'noverbose');
    whmontage = 5;
end

printhdr('Cross-validated SVM to discriminate between-person contrasts');

% b. Define holdout sets: Leave one subject out
%    Assume that subjects are in same position in each input file
% --------------------------------------------------------------------

group = DAT.BETWEENPERSON.group;

if ~all(group ~= 1 | group ~= -1)
    printhdr('CODE DAT.BETWEENPERSON.group WITH 1, -1 TO RUN BETWEEN-PERSON SVM. SKIPPING.');
    return
end

outcome_value = group;

% strategy here is to keep training set size proportional to original
% sample proportions.  leave out pairs, 1 person from each group.
holdout_set = xval_select_holdout_set_categoricalcovs(group);

% Transform into integer vector of which holdout set for each
% observation
hs = cat(2, holdout_set{:});
[holdout_set, ~] = find(hs');

% --------------------------------------------------------------------
%
% Run between-groups SVM for each contrast
%
% --------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

for c = 1:kc
    
    printstr(DAT.contrastnames{c});
    printstr(dashes)
    
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    % Select data for this contrast
    % --------------------------------------------------------------------
    
    switch myscaling
        case 'raw'
            cat_obj = DATA_OBJ_CON{c};
            
        case 'scaled'
            cat_objsc = DATA_OBJ_CON{c};
            
        otherwise
            error('myscaling must be ''raw'' or ''scaled''');
    end
    
    
    
    % a. Format and attach outcomes: 1, -1 for pos/neg contrast values
    % --------------------------------------------------------------------
 
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
    
    ROC = roc_plot(stats.dist_from_hyperplane_xval, logical(cat_obj.Y > 0), 'color', DAT.contrastcolors{c}, 'Optimal balanced error rate');
    
    drawnow, snapnow
    figtitle = sprintf('SVM ROC %s', DAT.contrastnames{c});
    savename = fullfile(figsavedir, [figtitle '.png']);
    saveas(gcf, savename);
    
    % Effect size, cross-validated
    dfun2 = @(x, Y) (mean(x(Y > 0)) - mean(x(Y < 0))) ./ sqrt(var(x(Y > 0)) + var(x(Y < 0))); % check this.
    
    d = dfun2(stats.dist_from_hyperplane_xval, stats.Y);
    fprintf('Effect size, cross-val: d = %3.2f\n\n', d);
    
    
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
    
    o2 = removeblobs(o2);
    
end  % within-person contrast

