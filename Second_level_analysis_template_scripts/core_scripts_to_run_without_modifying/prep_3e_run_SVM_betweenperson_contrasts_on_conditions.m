% THIS SCRIPT RUNS BETWEEN-PERSON CONTRASTS
% Assuming that groups are concatenated into contrast image lists.
% Requires DAT.BETWEENPERSON.group field specifying group membership for
% each image.
% --------------------------------------------------------------------

% USER OPTIONS
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
options_needed = {'dosubjectnorm' 'dozscoreimages' 'dosavesvmstats', 'dobootstrap', 'boot_n', 'maskname'};  % Options we are looking for. Set in a2_set_default_options
options_exist = cellfun(@exist, options_needed); 

option_default_values = {false false true false 1000 which('gray_matter_mask.img')};          % defaults if we cannot find info in a2_set_default_options at all 

plugin_get_options_for_analysis_script

% 
% % Now set in a2_set_default_options
% if ~exist('dosavesvmstats', 'var') || ~exist('dobootstrap', 'var') || ~exist('boot_n', 'var')
%     a2_set_default_options;
% end

% Check for required DAT fields. Skip analysis and print warnings if missing.
% ---------------------------------------------------------------------
% List required fields in DAT, in cell array:
required_fields = {'BETWEENPERSON', 'between_condition_contrastnames', 'between_condition_cons' 'contrastcolors'};

ok_to_run = plugin_check_required_fields(DAT, required_fields); % Checks and prints warnings
if ~ok_to_run
    return
end

spath = which('use_spider.m');
if isempty(spath)
    disp('Warning: spider toolbox not found on path; prediction may break')
end

% myscaling = 'raw';          % 'raw' or 'scaled'

if dobootstrap, svmtime = tic; end

% Get mask
% --------------------------------------------------------------------
if exist('maskname', 'var') && ~isempty(maskname)
    
    disp('Masking data')
    svmmask = fmri_data(maskname, 'noverbose');
    
else
    
    disp('No mask found; using full original image data');

end


% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
% whmontage = 5; 
% plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------


printhdr('Cross-validated SVM to discriminate between-person contrasts');


% --------------------------------------------------------------------
%
% Run between-person SVM based on values in "group" for each condition
% 1st contrast across group labels only!
%
% --------------------------------------------------------------------

k = length(DAT.conditions);

svm_stats_results = cell(1, k);

printstr(DAT.between_condition_contrastnames{1});
printstr(dashes)

if size(DAT.between_condition_cons, 1) > 1
    disp('WARNING!!  SVMS WILL BE RUN ON THE FIRST CONTRAST IN between_condition_cons ONLY');
end

mycontrast = DAT.between_condition_cons(1, :);
wh = find(mycontrast);

for c = 1:k
    
    mygroupnamefield = 'conditions';  % 'conditions' or 'contrasts'
    [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, c);
    outcome_value = group;
    
    if isempty(group)
        fprintf('Group not defined for contrast %s. Skipping.\n', DAT.between_condition_contrastnames{c}); 
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
    
    
%     printstr(DAT.contrastnames{c});
%     printstr(dashes)
%     
%     mycontrast = DAT.between_condition_cons(c, :);
%     wh = find(mycontrast);
    
    % Select data for this contrast
    % --------------------------------------------------------------------
    
    cat_obj = DATA_OBJ{c};
    
%     switch myscaling
%         case 'raw'
%             printstr('Raw (unscaled) images used in between-person SVM');
%             cat_obj = DATA_OBJ{c};
%             
%         case 'scaled'
%             printstr('Scaled images used in between-person SVM');
%             cat_obj = DATA_OBJ{c};
%             
%         otherwise
%             error('myscaling must be ''raw'' or ''scaled''');
%     end
    
    % Norm options:
    % --------------------------------------------------------------------
    % possibly normalize_each_subject_by_l2norm; can help with numerical scaling and inter-subject scaling diffs
    % Sometimes condition differences are very small relative to baseline
    % values and SVM is numerically unstable. If so, re-normalizing each
    % subject can help.
    
    if exist('dosubjectnorm', 'var') && dosubjectnorm
        % cat_obj = normalize_each_subject_by_l2norm(cat_obj, condition_codes);
        disp('Normalizing intensity of all images by L2 norm before SVM.')
        
        cat_obj = normalize_images_by_l2norm(cat_obj);
    end
    
    % Z-score each input image, removing image mean and forcing std to 1.
    % Removes overall effects of image intensity and scale. Can be useful
    % across studies but also removes information. Use judiciously.
    
    if exist('dozscoreimages', 'var') && dozscoreimages
        
        disp('Z-scoring each image before SVM.')
        cat_obj = rescale(cat_obj, 'zscoreimages');
        
    end
    
    % Apply mask
    
    if exist('svmmask', 'var')
        
        disp('Masking data')
        cat_obj = apply_mask(cat_obj, svmmask);
        
    else
        
        disp('No mask found; using full existing image data');
        
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
    figtitle = sprintf('SVM ROC %s', DAT.between_condition_contrastnames{1});
    create_figure(figtitle);
    
    disp(' ');
    printstr(['Results: ' DAT.between_condition_contrastnames{1}]); printstr(dashes);
    
    ROC = roc_plot(stats.dist_from_hyperplane_xval, logical(cat_obj.Y > 0), 'color', DAT.between_condition_contrastcolors{1}, 'Optimal balanced error rate');
    
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
        
    if exist('svmmask', 'var')
        
        svm_stats_results{c}.mask = svmmask;
        svm_stats_results{c}.maskname = maskname;
        
    end
    
    if dobootstrap, disp('Cumulative run time:'), toc(svmtime); end
     
%     % Plot the SVM map
%     % --------------------------------------------------------------------
%     o2 = removeblobs(o2);
%     o2 = addblobs(o2, region(stats.weight_obj), 'trans');
%     
%     axes(o2.montage{whmontage}.axis_handles(5));
%     title(DAT.between_condition_contrastnames{c}, 'FontSize', 18)
%     
%     printstr(DAT.between_condition_contrastnames{c}); printstr(dashes);
% 
%     figtitle = sprintf('SVM weight map nothresh %s', DAT.between_condition_contrastnames{c});
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



function cat_obj = normalize_each_subject_by_l2norm(cat_obj, condition_codes)
% normalize_each_subject_by_l2norm; can help with numerical scaling and inter-subject scaling diffs
% Sometimes condition differences are very small relative to baseline
% values and SVM is numerically unstable. If so, re-normalizing each
% subject can help.

disp('Normalizing images for each subject by L2 norm of Condition 1 image');

wh = find(condition_codes == 1);

wh2 = find(condition_codes == 2);

% nv: normalization values, to be determined from condition 1 and applied
% to conditions 1 and 2.  This keeps same scaling applied to both
% conditions, for each participant

nv = zeros(size(wh));

for i = 1:length(wh)
    
    nv(i) = norm(cat_obj.dat(:, wh(i)));

    % do normalization
    cat_obj.dat(:, wh(i)) = cat_obj.dat(:, wh(i)) ./ nv(i);
    
    cat_obj.dat(:, wh2(i)) = cat_obj.dat(:, wh2(i)) ./ nv(i);
     
end

end


function cat_obj = normalize_images_by_l2norm(cat_obj, condition_codes)
% normalize_images_by_l2norm; can help with numerical scaling and inter-subject scaling diffs
% Sometimes condition differences are very small relative to baseline
% values and SVM is numerically unstable. If so, re-normalizing each
% subject can help.
%
% This version normalizes each image separately, not each subject/pair

disp('Normalizing images for each image by L2 norm');
cat_obj = rescale(cat_obj, 'l2norm_images');


end
