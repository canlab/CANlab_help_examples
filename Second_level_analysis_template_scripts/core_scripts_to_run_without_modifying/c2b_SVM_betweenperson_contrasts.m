% THIS SCRIPT RUNS BETWEEN-PERSON CONTRASTS
% Assuming that groups are concatenated into contrast image lists.
% Requires DAT.BETWEENPERSON.group field specifying group membership for
% each image.
% --------------------------------------------------------------------

spath = which('use_spider.m');
if isempty(spath)
    disp('Warning: spider toolbox not found on path; prediction may break')
end

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

printhdr('Cross-validated SVM to discriminate between-person contrasts');


% if ~isfield(DAT, 'BETWEENPERSON') || ~isfield(DAT.BETWEENPERSON, 'group')
%         printhdr('Enter DAT.BETWEENPERSON.group CODED WITH 1, -1 TO RUN BETWEEN-PERSON SVM. SKIPPING.');
%     return
% end
% 
% group = DAT.BETWEENPERSON.group;
% 
% if ~all(group ~= 1 | group ~= -1)
%         printhdr('Code DAT.BETWEENPERSON.group WITH 1, -1 TO RUN BETWEEN-PERSON SVM. SKIPPING.');
%     return
% end
% 
% outcome_value = group;

% --------------------------------------------------------------------
%
% Run between-groups SVM for each contrast
%
% --------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

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
    
    [cverr, stats, optout] = predict(cat_obj, 'algorithm_name', 'cv_svm', 'nfolds', holdout_set, 'error_type', 'mcr');
    
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
    
    
    % Plot the SVM map
    % --------------------------------------------------------------------
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(stats.weight_obj), 'trans');
    
    axes(o2.montage{whmontage}.axis_handles(5));
    title(DAT.contrastnames{c}, 'FontSize', 18)
    
    printstr(DAT.contrastnames{c}); printstr(dashes);

    figtitle = sprintf('SVM weight map nothresh %s', DAT.contrastnames{c});
    plugin_save_figure;
       
    o2 = removeblobs(o2);
    
end  % within-person contrast





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
