% THIS SCRIPT RUNS SVMs for WITHIN-PERSON CONTRASTS
% Specified in DAT.contrasts
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
options_needed = {'dosavesvmstats', 'dobootstrap', 'boot_n'};  % Options we are looking for. Set in a2_set_default_options
options_exist = cellfun(@exist, options_needed); 

option_default_values = {true false 1000};          % defaults if we cannot find info in a2_set_default_options at all 

plugin_get_options_for_analysis_script


% Specified in DAT.contrasts
% --------------------------------------------------------------------

spath = which('use_spider.m');
if isempty(spath)
    disp('Warning: spider toolbox not found on path; prediction may break')
end

kc = size(DAT.contrasts, 1);

if dobootstrap, svmtime = tic; end


%% Train all models
% --------------------------------------------------------------------

svm_stats_results = cell(1, kc);

for c = 1:kc
    
    printstr(DAT.contrastnames{c});
    printstr(dashes)
    
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    % Create combined data object with all input images
    % --------------------------------------------------------------------
    [cat_obj, condition_codes] = cat(DATA_OBJ{wh});
    
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

    % a. Format and attach outcomes: 1, -1 for pos/neg contrast values
    % b. Define holdout sets: Define based on plugin script
    %    Assume that subjects are in same position in each input file
    % --------------------------------------------------------------------

    plugin_get_holdout_sets;
    
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
    if dobootstrap
        [cverr, stats, optout] = predict(cat_obj, 'algorithm_name', 'cv_svm', 'nfolds', holdout_set, 'bootsamples', boot_n, 'error_type', 'mcr', parallelstr);
        % Threshold, if possible - can re-threshold later with threshold() method
        stats.weight_obj = threshold(stats.weight_obj, .05, 'unc'); 
        
    else
        [cverr, stats, optout] = predict(cat_obj, 'algorithm_name', 'cv_svm', 'nfolds', holdout_set, 'error_type', 'mcr', parallelstr);
    end
    
    % Save stats objects for results later
    % --------------------------------------------------------------------
    
    stats.weight_obj = enforce_variable_types(stats.weight_obj);
    svm_stats_results{c} = stats;
        
    if dobootstrap, disp('Cumulative run time:'), toc(svmtime); end

end  % Contrasts - run
    
%% Save
if dosavesvmstats
    
    savefilenamedata = fullfile(resultsdir, 'svm_stats_results_contrasts.mat');

    save(savefilenamedata, 'svm_stats_results', '-v7.3');
    printhdr('Saved svm_stats_results for contrasts');
    
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
