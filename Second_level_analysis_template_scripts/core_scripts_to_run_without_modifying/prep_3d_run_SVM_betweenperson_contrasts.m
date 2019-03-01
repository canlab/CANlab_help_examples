% THIS SCRIPT RUNS BETWEEN-PERSON CONTRASTS
% Assuming that groups are concatenated into contrast image lists.
% Requires DAT.BETWEENPERSON.group field specifying group membership for
% each image.
% --------------------------------------------------------------------

% USER OPTIONS

% Now set in a2_set_default_options
if ~exist('dosavesvmstats', 'var') || ~exist('dobootstrap', 'var') || ~exist('boot_n', 'var')
    a2_set_default_options;
end

% Check for required DAT fields. Skip analysis and print warnings if missing.
% ---------------------------------------------------------------------
% List required fields in DAT, in cell array:
required_fields = {'BETWEENPERSON', 'contrastnames', 'contrasts' 'contrastcolors'};

ok_to_run = plugin_check_required_fields(DAT, required_fields); % Checks and prints warnings
if ~ok_to_run
    return
end

spath = which('use_spider.m');
if isempty(spath)
    disp('Warning: spider toolbox not found on path; prediction may break')
end

myscaling = 'raw';          % 'raw' or 'scaled'

if dobootstrap, svmtime = tic; end

% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
% whmontage = 5; 
% plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------


printhdr('Cross-validated SVM to discriminate between-person contrasts');


% --------------------------------------------------------------------
%
% Run between-person SVM for each contrast
%
% --------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

svm_stats_results = cell(1, kc);

for c = 1:kc
    
    mygroupnamefield = 'contrasts';  % 'conditions' or 'contrasts'
    [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, c);
    outcome_value = group;
    
    if isempty(group)
        fprintf('Group not defined for contrast %s. Skipping.\n', DAT.contrastnames{c}); 
        continue
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
    
    
    printstr(DAT.contrastnames{c});
    printstr(dashes)
    
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    % Select data for this contrast
    % --------------------------------------------------------------------
    
    switch myscaling
        case 'raw'
            printstr('Raw (unscaled) images used in between-person SVM');
            cat_obj = DATA_OBJ_CON{c};
            
        case 'scaled'
            printstr('Scaled images used in between-person SVM');
            cat_obj = DATA_OBJ_CON{c};
            
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
    
    % [cverr, stats, optout] = predict(cat_obj, 'algorithm_name', 'cv_svm', 'nfolds', holdout_set, 'error_type', 'mcr');
    
        % Run prediction model
    % --------------------------------------------------------------------
    if dobootstrap
        [cverr, stats, optout] = predict(cat_obj, 'algorithm_name', 'cv_svm', 'nfolds', holdout_set, 'bootsamples', boot_n, 'error_type', 'mcr', parallelstr);
        % Threshold, if possible - can re-threshold later with threshold() method
        stats.weight_obj = threshold(stats.weight_obj, .05, 'unc'); 
        
    else
        [cverr, stats, optout] = predict(cat_obj, 'algorithm_name', 'cv_svm', 'nfolds', holdout_set, 'error_type', 'mcr', parallelstr);
    end
    
    % Summarize output and create ROC plot
    % --------------------------------------------------------------------
    figtitle = sprintf('SVM ROC %s', DAT.contrastnames{c});
    create_figure(figtitle);
    
    disp(' ');
    printstr(['Results: ' DAT.contrastnames{c}]); printstr(dashes);
    
    ROC = roc_plot(stats.dist_from_hyperplane_xval, logical(cat_obj.Y > 0), 'color', DAT.contrastcolors{c}, 'Optimal balanced error rate');
    
    plugin_save_figure;
    close
    
    % Effect size, cross-validated
    dfun2 = @(x, Y) (mean(x(Y > 0)) - mean(x(Y < 0))) ./ sqrt(var(x(Y > 0)) + var(x(Y < 0))); % check this.
    
    d = dfun2(stats.dist_from_hyperplane_xval, stats.Y);
    fprintf('Effect size, cross-val: d = %3.2f\n\n', d);
    
    % Save stats objects for results later
    % --------------------------------------------------------------------
    
    stats.weight_obj = enforce_variable_types(stats.weight_obj);
    svm_stats_results{c} = stats;
        
    if dobootstrap, disp('Cumulative run time:'), toc(svmtime); end
    
    
%     % Plot the SVM map
%     % --------------------------------------------------------------------
%     o2 = removeblobs(o2);
%     o2 = addblobs(o2, region(stats.weight_obj), 'trans');
%     
%     axes(o2.montage{whmontage}.axis_handles(5));
%     title(DAT.contrastnames{c}, 'FontSize', 18)
%     
%     printstr(DAT.contrastnames{c}); printstr(dashes);
% 
%     figtitle = sprintf('SVM weight map nothresh %s', DAT.contrastnames{c});
%     plugin_save_figure;
%        
%     o2 = removeblobs(o2);
    
end  % between-person contrast

% Save
% --------------------------------------------------------------------
if dosavesvmstats
    
    savefilenamedata = fullfile(resultsdir, 'svm_stats_results_betweenperson_contrasts.mat');

    save(savefilenamedata, 'svm_stats_results', '-v7.3');
    printhdr('Saved svm_stats_results for contrasts');
    
end



function [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, i)

group = []; groupnames = []; groupcolors = [];

if isfield(DAT, 'BETWEENPERSON') && ...
        isfield(DAT.BETWEENPERSON, mygroupnamefield) && ...
        iscell(DAT.BETWEENPERSON.(mygroupnamefield)) && ...
        length(DAT.BETWEENPERSON.(mygroupnamefield)) >= i && ...
        ~isempty(DAT.BETWEENPERSON.(mygroupnamefield){i})
    
    group = DAT.BETWEENPERSON.(mygroupnamefield){i};
    
elseif isfield(DAT, 'BETWEENPERSON') && ...
        isfield(DAT.BETWEENPERSON, 'group') && ...
        ~isempty(DAT.BETWEENPERSON.group)
    
    group = DAT.BETWEENPERSON.group;

end

if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'groupnames')
    groupnames = DAT.BETWEENPERSON.groupnames;
elseif istable(group)
    groupnames = group.Properties.VariableNames(1);
else
    groupnames = {'Group-Pos' 'Group-neg'};
end

if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'groupcolors')
    groupcolors = DAT.BETWEENPERSON.groupcolors;
else
    groupcolors = seaborn_colors(2);
end

if istable(group), group = table2array(group); end

end
