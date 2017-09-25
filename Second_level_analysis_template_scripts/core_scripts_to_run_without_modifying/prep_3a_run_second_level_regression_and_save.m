% THIS SCRIPT RUNS BETWEEN-PERSON CONTRASTS using second-level regression
%
% FOR NOW: Uses "group" variable.
% FUTURE: Extend this to arbitrary covariates (> 1 cov), which have to be
% entered in DAT structure in some standardize place.
%
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

% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
% whmontage = 5; 
% plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------


printhdr('Second-level regressions discriminate between-person contrasts');


% --------------------------------------------------------------------
%
% Run between-person Second-level regression for each contrast
%
% --------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

regression_stats_results = cell(1, kc);

for c = 1:kc
    
    mygroupnamefield = 'contrasts';  % 'conditions' or 'contrasts'
    [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, c);
    outcome_value = group;
    
    if isempty(group)
        fprintf('Group not defined for contrast %s. Skipping.\n', DAT.contrastnames{c}); 
        continue
    end

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
    
  
    
    % a. Format and attach outcomes: 1, -1 group variable FOR NOW
    % --------------------------------------------------------------------
 
    % Confirm outcome_value is 1, -1, or mean-centered
    % *****add this*****
    
    % Check multilinearity, variance in all regressors; error for bad
    % design matrix
    % *****add this*****
    
    cat_obj.X = outcome_value;
    
    % Skip if necessary
    % --------------------------------------------------------------------
    
    if all(cat_obj.X > 0) || all(cat_obj.X < 0)
        % Only positive or negative weights - nothing to compare
        
        printhdr(' Only positive or negative regressor values - bad design');
        
        continue
    end
    
    % Run voxel-wise regression model
    % --------------------------------------------------------------------
    
    if dorobust
        robuststring = 'robust';
        regresstime = tic;
    else
        robuststring = 'norobust';
    end
    
    % out.t has t maps for all regressors, intercept is last
    regression_stats = regress(cat_obj, .05, 'unc', robuststring, 'analysis_name', DAT.contrastnames{c}, 'variable_names', {'Group'});
    
    % Make sure variable types are right data formats
    regression_stats.t = enforce_variable_types(regression_stats.t);
    regression_stats.b = enforce_variable_types(regression_stats.b);
    regression_stats.df = enforce_variable_types(regression_stats.df);
    regression_stats.sigma = enforce_variable_types(regression_stats.sigma);

    % add regressor names and other meta-data
    regression_stats.contrastname = DAT.contrastnames{c};
    regression_stats.contrast = DAT.contrasts(c, :);
    
    
    % ****** do this*****
    
    % Save stats objects for results later
    % --------------------------------------------------------------------

    regression_stats_results{c} = regression_stats;
        
    if dorobust, disp('Cumulative run time:'), toc(regresstime); end
    
    
end  % between-person contrast

% Save
% --------------------------------------------------------------------
savefilenamedata = fullfile(resultsdir, 'regression_stats_and_maps.mat');

save(savefilenamedata, 'regression_stats_results', '-v7.3');
printhdr('Saved regression_stats_results for contrasts');




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
