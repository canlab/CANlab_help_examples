% THIS SCRIPT RUNS BETWEEN-PERSON (2nd-level) Regression analyses
% for each within-person CONTRAST registered in the analysis
% 
% - To specify analysis options, run a2_set_default_options
% - prep_3a_run_second_level_regression_and_save runs regressions and saves
% results in a standard location and format
% - To get results reports, see c2a_second_level_regression
%
% Analysis options include:
% - dorobust : robust regression or OLS (true/false)
% - myscaling: 'raw' or 'scaled' (image scaling done in prep_2_... data load)
% - design_matrix_type: 'group' or 'custom'
%                       Group: use DAT.BETWEENPERSON.group or DAT.BETWEENPERSON.contrasts{c}.group;
%                       Custom: use all columns of table object DAT.BETWEENPERSON.contrasts{c};
%
% 'group' option 
% Assuming that groups are concatenated in contrast image lists, and
% regressor values of 1 or -1 will specify the group identity for each
% image. Requires DAT.BETWEENPERSON.group field specifying group membership for
% each image.
%
% 'custom' option: 
% Can enter a multi-column design matrix for each contrast
% Design matrix can be different for each contrast
%
% To set up group and custom variables, see prep_1b_prep_behavioral_data

% --------------------------------------------------------------------

% USER OPTIONS
% This is a standard block of code that can be used in multiple scripts.
% Each script will have its own options needed and default values for
% these.
% The code: 
% (1) Checks whether the option variables exist
% (2) Runs a2_set_default_options if any are missing
% (3) Checks again and uses the default options if they are still missing
% (e.g., not specified in an older/incomplete copy of a2_set_default_options)

% Now set in a2_set_default_options
options_needed = {'dorobust', 'myscaling', 'design_matrix_type'};  % Options we are looking for. Set in a2_set_default_options
options_exist = cellfun(@exist, options_needed); 

option_default_values = {false, 'raw', 'group'};          % defaults if we cannot find info in a2_set_default_options at all 

plugin_get_options_for_analysis_script



%% Check for required DAT fields. Skip analysis and print warnings if missing.
% ---------------------------------------------------------------------
% List required fields in DAT, in cell array:
required_fields = {'BETWEENPERSON', 'conditions', 'colors'};

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


printhdr('Second-level univariate regressions on each condition');


% --------------------------------------------------------------------
%
% Run between-person Second-level regression for each contrast
%
% --------------------------------------------------------------------

k = length(DAT.conditions);

regression_stats_results = cell(1, k);

for c = 1:k
    
    % Get design matrix for this contrast
    % --------------------------------------------------------------------
    
    mygroupnamefield = 'X';  % X is design matrix
    
    switch design_matrix_type
        case 'custom'
            
            % Define design matrix X "design_matrix"
            % Use custom matrix for each condition/contrast
            table_obj = DAT.BETWEENPERSON.(mygroupnamefield){c};
            groupnames = table_obj.Properties.VariableNames;
            X = table2array(table_obj);
            
        case 'group'
            
            % Use 'groups' single regressor
            [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, c);
            X = group;
            
            if isempty(group)
                fprintf('Group not defined for contrast %s. Skipping.\n', DAT.contrastnames{c});
                continue
            end
            
        otherwise error('Incorrect option specified for design_matrix_type');
    end
    
    printstr(DAT.conditions{c});
    printstr(dashes)
    
%     mycontrast = DAT.contrasts(c, :);
%     wh = find(mycontrast);
     
    % Select data for this cpndition
    % --------------------------------------------------------------------
    
    switch myscaling
        case 'raw'
            printstr('Raw (unscaled) images used in between-person SVM');
            cat_obj = DATA_OBJ{c};
            
        case 'scaled'
            printstr('Scaled images used in between-person SVM');
            cat_obj = DATA_OBJ{c};
            
        otherwise
            error('myscaling must be ''raw'' or ''scaled''');
    end
    
  
    
    % a. Format and attach outcomes: 1, -1 group variable FOR NOW
    % --------------------------------------------------------------------
    
    % Confirm design_matrix is 1, -1, or mean-centered
    meancentered = ~(abs(mean(X)) > 1000 * eps);
    effectscoded = all(X == 1 | X == -1 | X == 0, 1);
    isconstant = all(X == mean(X, 1), 1);
    vifs = getvif(X);
    
    if any(isconstant)
        disp('An intercept appears to be added manually. Do not include an intercept - it will be added automatically.');
        disp('Skipping this contrast.')
        continue
    end

    % Report
    design_table = table;
    design_table.Mean = mean(X)';
    design_table.Var = var(X)';
    design_table.EffectsCode = effectscoded';
    design_table.VIF = vifs';
    design_table.Properties.RowNames = groupnames';
    disp(design_table)
    disp(' ');
    
    if any(~meancentered & ~effectscoded)
        disp('Warning: some columns are not mean-centered or effects coded. \nIntercept may not be interpretable.\n');
        fprintf('Columns: ')
        fprintf('%d ', find(~meancentered & ~effectscoded));
        fprintf('\n');
    else
        disp('Checked OK: All columns mean-centered or are effects-coded [1 -1 0]');
    end
    
    if any(vifs > 2)
        disp('Some regressors have high variance inflation factors: Parameters might be poorly estimated or uninterpretable.');
    else
        disp('Checked OK: VIFs for all columns are < 2');
    end

    
    cat_obj.X = X;
    
    % Skip if necessary
    % --------------------------------------------------------------------
%     
%     if all(cat_obj.X > 0) || all(cat_obj.X < 0)
%         % Only positive or negative weights - nothing to compare
%         
%         printhdr(' Only positive or negative regressor values - bad design');
%         
%         continue
%     end
    
    % Run voxel-wise regression model
    % --------------------------------------------------------------------
    
    if dorobust
        robuststring = 'robust';
        regresstime = tic;
    else
        robuststring = 'norobust';
    end
    
    % out.t has t maps for all regressors, intercept is last
    regression_stats = regress(cat_obj, .05, 'unc', robuststring, 'analysis_name', DAT.conditions{c}, 'variable_names', groupnames);
    

    % Make sure variable types are right data formats
    regression_stats.design_table = design_table;
    regression_stats.t = enforce_variable_types(regression_stats.t);
    regression_stats.b = enforce_variable_types(regression_stats.b);
    regression_stats.df = enforce_variable_types(regression_stats.df);
    regression_stats.sigma = enforce_variable_types(regression_stats.sigma);

    % add regressor names and other meta-data
    regression_stats.condition = DAT.conditions{c};
%     regression_stats.contrast = DAT.contrasts(c, :);
    
    % add names for analyses and variables: 
    regression_stats.analysis_name = DAT.conditions{c};
    regression_stats.variable_names = [groupnames {'Intercept'}];
    
    % prints output automatically - name axis
    for kk = 1:length(regression_stats.variable_names)
        spm_orthviews_name_axis(regression_stats.variable_names{kk}, kk);
    end
    
    % Save stats objects for results later
    % --------------------------------------------------------------------

    regression_stats_results{c} = regression_stats;
        
    if dorobust, disp('Cumulative run time:'), toc(regresstime); end
    
    
end  % between-person contrast

% Save
% --------------------------------------------------------------------
savefilenamedata = fullfile(resultsdir, 'regression_stats_and_maps_on_conditions.mat');

save(savefilenamedata, 'regression_stats_results', '-v7.3');
printhdr('Saved regression_stats_results for contrasts');
fprintf('Filename: %s\n', savefilenamedata);




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
