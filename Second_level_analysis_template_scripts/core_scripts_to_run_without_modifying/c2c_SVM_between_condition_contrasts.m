% THIS SCRIPT RUNS BETWEEN-PERSON CONTRASTS
% Assuming that groups are separated into different conditions
% --------------------------------------------------------------------
% Enter conditions and colors in prep_1_set_conditions_contrasts_colors.m
% e.g.,
% DAT.between_condition_cons = [1 -1 0;
%                               1 0 -1];
% 
% DAT.between_condition_contrastnames = {'Pain vs Nausea' 'Pain vs Itch'};
%           
% DAT.between_condition_contrastcolors = custom_colors ([.2 .2 .8], [.2 .8 .2], size(DAT.between_condition_cons, 1));


myscaling = 'scaled';          % 'raw' or 'scaled'

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

printhdr('Cross-validated SVM to discriminate between-condition contrasts');

% --------------------------------------------------------------------
%
% Run between-groups SVM for each contrast
%
% --------------------------------------------------------------------

kc = size(DAT.between_condition_cons, 1);

for c = 1:kc
    
    if ~isfield(DAT, 'between_condition_cons') 
        printhdr('Enter DAT.between_condition_cons CODED WITH 1, -1 TO RUN BETWEEN-PERSON across condition SVM. SKIPPING.');
    return
    end

    convec = DAT.between_condition_cons(c, :);
    
    % concatenate data
    wh = convec == 1 | convec == -1;
    
    if ~any(wh)
        printhdr('CODE DAT.between_condition_cons WITH 1, -1 TO RUN BETWEEN-PERSON SVM. SKIPPING.');
        continue
    end

        % Select data for this contrast
    % --------------------------------------------------------------------
    
    switch myscaling
        case 'raw'
            cat_obj = cat(DATA_OBJ{wh});
            
        case 'scaled'
            cat_obj = cat(DATA_OBJsc{wh});
            
        otherwise
            error('myscaling must be ''raw'' or ''scaled''');
    end
    
           % Build outcome values for each image
    % --------------------------------------------------------------------
    group = [];
    
    for i = 1:length(convec) % for each contrast value
        if wh(i)
            group = [group; convec(i) * ones(size(DAT.imgs{i}, 1), 1)];
        end
    end
    
% b. Define holdout sets: Leave one subject out
%    Assume that subjects are in same position in each input file
% --------------------------------------------------------------------

% strategy here is to keep training set size proportional to original
% sample proportions.  leave out pairs, 1 person from each group.
holdout_set = xval_select_holdout_set_categoricalcovs(group);

% Transform into integer vector of which holdout set for each
% observation
hs = cat(2, holdout_set{:});
[holdout_set, ~] = find(hs');


    printstr(DAT.between_condition_contrastnames{c});
    printstr(dashes)
    
    
    % a. Format and attach outcomes: 1, -1 for pos/neg contrast values
    % --------------------------------------------------------------------
 
    cat_obj.Y = group;
    
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
    
    figtitle = sprintf('SVM ROC %s', DAT.between_condition_contrastnames{c});
    create_figure(figtitle);
    disp(' ');
    printstr(['Results: ' DAT.between_condition_contrastnames{c}]); printstr(dashes);
    
    ROC = roc_plot(stats.dist_from_hyperplane_xval, logical(cat_obj.Y > 0), 'color', DAT.between_condition_contrastcolors{c}, 'Optimal balanced error rate');
    
    plugin_save_figure;
    close
    
    % Effect size, cross-validated
    dfun2 = @(x, Y) (mean(x(Y > 0)) - mean(x(Y < 0))) ./ sqrt(var(x(Y > 0)) + var(x(Y < 0))); % check this.
    
    d = dfun2(stats.dist_from_hyperplane_xval, stats.Y);
    fprintf('Effect size, cross-val: d = %3.2f\n\n', d);
    
    
    % Plot the SVM map
    % --------------------------------------------------------------------
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(stats.weight_obj), 'trans');
    
    axes(o2.montage{whmontage}.axis_handles(5));
    title(DAT.between_condition_contrastnames{c}, 'FontSize', 18)
    
    printstr(DAT.between_condition_contrastnames{c}); printstr(dashes);

    figtitle = sprintf('SVM weight map nothresh %s', DAT.between_condition_contrastnames{c});
    plugin_save_figure;
        
    o2 = removeblobs(o2);
    
end  % within-person contrast

