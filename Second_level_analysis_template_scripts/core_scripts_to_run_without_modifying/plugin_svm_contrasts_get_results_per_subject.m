function [dist_from_hyperplane, Y, svm_dist_pos_neg, svm_dist_pos_neg_matrix, outcome_matrix] = plugin_svm_contrasts_get_results_per_subject(DAT, svm_stats_results, DATA_OBJ)
% [dist_from_hyperplane, Y, svm_dist_pos_neg, svm_dist_pos_neg_matrix, outcome_matrix] = plugin_svm_contrasts_get_results_per_subject(DAT, svm_stats_results, DATA_OBJ)
%
% The purpose of this plugin is to average over replicates of images with the
% same outcome collected on the same individuals.  We want one average
% image for outcome 1 and one average image for outcome -1 per person, and
% we want to test person-wise classification.
%
% c2_SVM_contrasts runs SVMs for sets of images coded as 1 or -1
% within-person, across conditions.  Depending on how contrasts are specified,
% stats results structure from SVM training may involve multiple images coded
% with 1 or -1 per person, in which case the svm_stats_results stats
% structures will contain image-wise classification results, not
% person-wise averaging over images for each person.
% This function calculates an average pattern expression value (distance from hyperplane)
% for each person for images coded as 1 and those coded as -1.
%
% For example, if you are testing a [1 1 1 1 -1 -1 -1 -1] contrast, you
% will end up with 8 images per person in the SVM analysis, 4 for each
% condition. You want to test the average of the first 4 vs. the average of
% the last 4 when you caculate test accuracy.

% This plugin returns a cell array, with one cell per contrast for:
% dist_from_hyperplane{c} = distance from hyperplane for positive (1) and
% negative (-1) conditions, averaged across images within each condition,
% concatenated into a vector of [1:n ; 1:n] for pos and neg. This is the
% format ROC_plot expects.
% Y = same, for true outcomes (1, -1)
% svm_dist_pos_neg = subjects x 2 matrix of distances for pos and neg
% conditions
%
% svm_dist_pos_neg_matrix is a cross-classification matrix of distances (n
% x 2), using the same training folds as in the within-class SVM
% classification.  This assesses transfer of a classifier trained on one
% contrast to images from other contrasts.

%% Getting numbers of images in each condition

nconditions = length(DATA_OBJ);
images_per_condition = cellfun(@(OBJ) size(OBJ.dat, 2), DATA_OBJ);
n = images_per_condition(1);

% starting and ending indices for each condition
n = images_per_condition(1);
en = cumsum(images_per_condition);
st = en - images_per_condition(1) + 1;

if any(diff(images_per_condition')), error('Must have same number of images in each condition in DATA_OBJ'); end

kc = size(DAT.contrasts, 1);

[dist_from_hyperplane, Y, svm_dist_pos_neg] = deal(cell(1, kc));

for c = 1:kc
    
    %     printstr(DAT.contrastnames{c});
    %     printstr(dashes)
    
    % Get SVM stats for this contrast
    stats = svm_stats_results{c};
    
    mycontrast = DAT.contrasts(c, :);
    
    % Get outcome YY, 1 or -1 for each observation
    [YY, wh_pos, wh_neg] = get_Y_outcome(mycontrast, images_per_condition, stats);
    
    % Get SVM distance
    % ---------------------------------------------------------------------
    
    svm_dist_pos = stats.dist_from_hyperplane_xval(YY > 0); % Positively-valued true outcome
    svm_dist_neg = stats.dist_from_hyperplane_xval(YY < 0);
    
    % assume all equal n's, reshape
    svm_dist_pos = reshape(svm_dist_pos, n, sum(wh_pos));
    svm_dist_neg = reshape(svm_dist_neg, n, sum(wh_neg));
    
    % average to get one score per pos/neg contrast value per subject
    svm_dist_pos = mean(svm_dist_pos, 2);
    svm_dist_neg = mean(svm_dist_neg, 2);
    
    svm_dist_pos_neg{c} = [svm_dist_pos svm_dist_neg];
    
    % ROC plot, accuracy,and effect size
    
    Y{c} = YY; %[ones(size(svm_dist_pos)); -ones(size(svm_dist_neg))];
    dist_from_hyperplane{c} = [svm_dist_pos; svm_dist_neg];
    
end

%% Cross-classification results
% apply training weight maps for each contrast to test data from this and
% other contrasts.  diagonals (c == c2) should replicate the above,
% off-diagonals should contain info about cross-classification.

% NEEDS FURTHER TESTING / DEVELOPMENT WHEN CONTRASTS HAVE MULTIPLE POS/NEG
% WEIGHTS! IF ERRORS, THIS IS A LIKELY REASON...

for c = 1:kc
    
    % For each contrast run...
    stats = svm_stats_results{c};
    
    % For each transfer contrast to be tested...
    for c2 = 1:kc
        
        % Get transfer image set
        % stats_test = svm_stats_results{c2};
        mycontrast = DAT.contrasts(c2, :);
        wh = find(mycontrast);
        
        % Get outcome YY, 1 or -1 for each observation
        % Assume num images in transfer stats struct is the same as for training stats
        [YY, wh_pos, wh_neg] = get_Y_outcome(mycontrast, images_per_condition, stats);
        
        % Create combined data object with all input images
        % Same stacking order as when we trained!!
        % --------------------------------------------------------------------
        [test_dat, condition_codes] = cat(DATA_OBJ{wh});
        
        yfit_transfer = NaN * ones(size(YY));
        
        fold_testset = stats.teIdx;  % cell array, one cell per fold
        %w_obj = replace_empty(stats.weight_obj);    % Starting value, weights will be replaced.
        w_obj = stats.weight_obj;    % Starting value, weights will be replaced.
        
        % Get results for each fold
        for f = 1:length(fold_testset)
            
            w = stats.other_output_cv{f, 1};     % weights for this fold
            intc = stats.other_output_cv{f, 3};  % intercept for this fold
            
            % put weights into object, so we can apply even if voxels don't
            % match up (e.g., if training data were masked)
            % predict.m method returns voxel weights in cv output
            % inconsistently, in two different vector spaces, so we have to
            % detect which is right.
            if size(w, 1) == size(w_obj.removed_voxels, 1) 
                % full-length vector
                w_obj.dat = w(~w_obj.removed_voxels);
                
            elseif size(w, 1) == size(w_obj.dat, 1)
                w_obj.dat = w;
            else
                error('Voxel sizes do not match!! Check code and input and debug.');
            end

            teidx = fold_testset{f};             % this requires that the matched (paired) images exist in both training and transfer samples.
            test_wh = find(teidx);
            
            test_fold = get_wh_image(test_dat, test_wh);
            
            yfit_transfer(test_wh) = apply_mask(w_obj, test_fold, 'pattern_expression') + intc;
            
            %yfit_transfer(test_wh) = (w' * test_fold.dat  + intc)';
            
        end
        
        % Now we have a vector of results, and we need to reshape and
        % average within-condition if there are multiple conditions with pos
        % or neg weights in this contrast.
        % ---------------------------------------------------------------------
        
        svm_dist_pos = yfit_transfer(YY > 0); % Positively-valued true outcome
        svm_dist_neg = yfit_transfer(YY < 0);
        
        % assume all equal n's, reshape
        svm_dist_pos = reshape(svm_dist_pos, n, sum(wh_pos));
        svm_dist_neg = reshape(svm_dist_neg, n, sum(wh_neg));
        
        % average to get one score per pos/neg contrast value per subject
        svm_dist_pos = mean(svm_dist_pos, 2);
        svm_dist_neg = mean(svm_dist_neg, 2);
        
        svm_dist_pos_neg_matrix{c, c2} = [svm_dist_pos svm_dist_neg];
        outcome_matrix{c, c2} = YY;
        
    end
    
end


end % function



function [YY, wh_pos, wh_neg] = get_Y_outcome(mycontrast, images_per_condition, stats)

wh = find(mycontrast);

wh_pos = mycontrast(wh) > 0;
wh_neg = mycontrast(wh) < 0;

% starting and ending indices for each condition
en = cumsum(images_per_condition(wh));
st = en - images_per_condition(wh(1)) + 1;

% Get outcome YY, 1 or -1 for each observation
% ---------------------------------------------------------------------
z = false(size(stats.yfit,1), 2);  % images x 2, pos contrast value and neg contrast value

for i = 1:length(wh)
    
    %mycond = wh(i);
    
    if wh_pos(i)
        z(st(i):en(i), 1) = true;
        
    elseif wh_neg(i)
        z(st(i):en(i), 2) = true;
        
    end
    
end

YY = z(:, 1) - z(:, 2);

end


