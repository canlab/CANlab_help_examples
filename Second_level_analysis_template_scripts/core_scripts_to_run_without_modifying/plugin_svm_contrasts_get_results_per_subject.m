function [dist_from_hyperplane, Y, svm_dist_pos_neg, svm_dist_pos_neg_matrix] = plugin_svm_contrasts_get_results_per_subject(DAT, svm_stats_results, DATA_OBJ)
% [dist_from_hyperplane, Y, svm_dist_pos_neg, svm_dist_pos_neg_matrix] = plugin_svm_contrasts_get_results_per_subject(DAT, svm_stats_results, DATA_OBJ)
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
%
% This plugin assumes all conditions have same number of images!
%
% It returns a cell array, with one cell per contrast for:
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
%
% % outcome_matrix no longer used in c2_SVM_contrasts...

%% Getting numbers of images in each condition

nconditions = length(DATA_OBJ);
images_per_condition = cellfun(@(OBJ) size(OBJ.dat, 2), DATA_OBJ);

% starting and ending indices for each condition

en = cumsum(images_per_condition);
st = en - images_per_condition(1) + 1;

% used to assume that all n images are the same; not anymore
%n = images_per_condition(1);
% if any(diff(images_per_condition')), error('Must have same number of images in each condition in DATA_OBJ'); end

kc = size(DAT.contrasts, 1);

[dist_from_hyperplane, Y, svm_dist_pos_neg] = deal(cell(1, kc));

for c = 1:kc
    
    %     printstr(DAT.contrastnames{c});
    %     printstr(dashes)
    
    if isempty(svm_stats_results{c})  
        % invalid contrast
        continue
    end
    
    % Get SVM stats for this contrast
    stats = svm_stats_results{c};
    
    mycontrast = DAT.contrasts(c, :);
    
    % Get outcome YY, 1 or -1 for each observation
    [YY, wh_pos, wh_neg] = get_Y_outcome(mycontrast, images_per_condition, stats);
    
    % Get SVM distance
    % ---------------------------------------------------------------------
    
    svm_dist_pos = stats.dist_from_hyperplane_xval(YY > 0); % Positively-valued true outcome
    svm_dist_neg = stats.dist_from_hyperplane_xval(YY < 0);
    
    [svm_dist_pos, svm_dist_neg] = reshape_and_average(svm_dist_pos, svm_dist_neg, mycontrast);
    

    svm_dist_pos_neg{c} = [svm_dist_pos svm_dist_neg];
    
    dist_from_hyperplane{c} = [svm_dist_pos; svm_dist_neg];
    
    % Get true outcome values to save in average-condition list, matching dist_from_hyperplane
    % just rebuild
    YYout = [ones(size(svm_dist_pos)); -ones(size(svm_dist_neg))];
    
    % This does not work under some conditions
%     YYout = reshape(YY, 2*n, sum(wh_pos));  % assume pos and neg conditions equally balanced
%     YYout = mean(YYout, 2);                 % average to reduce redundant replicates
%     if ~all(YYout == 1 | YYout == -1), error('Outcomes for images considered replicates are not identical. Debug.'); end
    
    Y{c} = YYout; %[ones(size(svm_dist_pos)); -ones(size(svm_dist_neg))];
    
    
end

%% Cross-classification results
% apply training weight maps for each contrast to test data from this and
% other contrasts.  diagonals (c == c2) should replicate the above,
% off-diagonals should contain info about cross-classification.

% NEEDS FURTHER TESTING WHEN CONTRASTS HAVE MULTIPLE POS/NEG
% WEIGHTS! IF ERRORS, THIS IS A LIKELY REASON...  revised 9/10/17 by Tor Wager

% This takes time, so do it once here.
% Also helps to match up images if training and test contrasts are different sets
% For flexibility in matching across contrasts, we need to index test images in list of all images in the dataset

[all_test_dat, all_condition_codes] = cat(DATA_OBJ{:});

% Need to leave out SUBJECTS belonging to each test fold, 
% even with mix-and-match between training/xval and transfer contrasts
% So need to make some assumptions about subject IDs. This works as long as
% data are set up in the standard way in 2nd level scripts, and contrasts
% are within-person.
subject_indices = get_subject_ids(all_condition_codes);

for c = 1:kc
    
    if isempty(svm_stats_results{c})
        % invalid contrast
        continue
    end
    
    % For each contrast run...
    stats = svm_stats_results{c}; 
        
    w_obj = stats.weight_obj;    % Starting placeholder, weights will be replaced.
      
    % For flexibility in matching across contrasts, we need to index test images in 
    % list of all images in the dataset
    % Get eligible images for this cross-validation and outcomes in full image list
    mycontrast = DAT.contrasts(c, :);
    [eligible_images, Y_this_stats_obj] = get_eligible_images_and_outcomes(mycontrast, all_condition_codes);

    % Get test SUBJECTS for each fold  
    [fold_testset, fold_testsubjects] = get_test_subjects_by_fold(stats, subject_indices, eligible_images);

    % For each transfer contrast to be tested...
    for c2 = 1:kc
        
        if isempty(svm_stats_results{c2})
            % invalid contrast
            continue
        end
        
        % Get transfer image set
        % stats_test = svm_stats_results{c2};
        mytransfercontrast = DAT.contrasts(c2, :);
        
        % Get outcome YY, 1 or -1 for each observation
        [eligible_images_transfer, Y_transfer] = get_eligible_images_and_outcomes(mytransfercontrast, all_condition_codes);
        
        Y_transfer = Y_transfer(eligible_images_transfer);
        eligible_subjects_transfer = subject_indices(eligible_images_transfer);
                
        yfit_transfer = NaN * ones(size(Y_transfer));
        
        % Eligible test data
        test_dat = get_wh_image(all_test_dat, find(eligible_images_transfer));
         
        % Get results for each fold
        for f = 1:length(fold_testset)
            
            w_obj_this_fold = w_obj;             % make a copy because if some fold weights==0, it will mess up index in main w_obj
            w = stats.other_output_cv{f, 1};     % weights for this fold, cross-validated (from subjects not used in test)
            intc = stats.other_output_cv{f, 3};  % intercept for this fold
            
            % Define weight object w_obj with training weights out-of-sample for this test fold
            % Assume images (often subjects) in each training and transfer contrast are paired sets.  
            % put weights into object, so we can apply even if voxels don't
            % match up (e.g., if training data were masked)
            % predict.m method returns voxel weights in cv output
            % inconsistently, in two different vector spaces, so we have to
            % detect which is right.
            if size(w, 1) == size(w_obj_this_fold.removed_voxels, 1)
                % w is full-length vector
                w_obj_this_fold.dat = w(~w_obj_this_fold.removed_voxels);
                
            elseif size(w, 1) == size(w_obj_this_fold.dat, 1)
                % w is size of dat after removing empty voxels
                w_obj_this_fold.dat = w;
                
            else
                % voxels have not been removed yet so remove_empty is all 0s
                voxels_with_valid_data = ~all(w_obj_this_fold.dat' == 0 | isnan(w_obj_this_fold.dat'), 1)';
                
                if size(w, 1) == sum(voxels_with_valid_data)
                    
                    w_obj_this_fold.dat(voxels_with_valid_data) = w;

                else
                    disp('Voxel sizes do not match!! Check code and input and debug.');
                    keyboard
                end
                
            end
            
            % Identify test images
%             teidx = fold_testset{f};             % this requires that the matched (paired) images exist in both training and transfer samples.
%             test_wh = find(teidx);
                  
            test_wh = ismember(eligible_subjects_transfer, fold_testsubjects{f}); % index into list of subjects in test_dat
            
            test_fold = get_wh_image(test_dat, test_wh); % fmri_data object with test data
            
            w_obj = replace_empty(w_obj); % may speed up computation?
            
            %yfit_transfer(test_wh) = apply_mask(w_obj_this_fold, test_fold, 'pattern_expression') + intc;
            yfit_transfer(test_wh) = apply_mask(test_fold, w_obj_this_fold, 'pattern_expression') + intc;
            
            %yfit_transfer(test_wh) = (w' * test_fold.dat  + intc)';
            
        end
        
        % Now we have a vector of results, and we need to reshape and
        % average within-condition if there are multiple conditions with pos
        % or neg weights in this contrast.
        % ---------------------------------------------------------------------
        
        svm_dist_pos = yfit_transfer(Y_transfer > 0); % Positively-valued true outcome
        svm_dist_neg = yfit_transfer(Y_transfer < 0);
        
        [svm_dist_pos, svm_dist_neg] = reshape_and_average(svm_dist_pos, svm_dist_neg, mytransfercontrast);
        
%         % assume all equal n's, reshape
%         wh_pos = mytransfercontrast > 0;
%         wh_neg = mytransfercontrast < 0;
% 
%         svm_dist_pos = reshape(svm_dist_pos, n, sum(wh_pos));
%         svm_dist_neg = reshape(svm_dist_neg, n, sum(wh_neg));
%         
%         % average to get one score per pos/neg contrast value per subject
%         svm_dist_pos = mean(svm_dist_pos, 2);
%         svm_dist_neg = mean(svm_dist_neg, 2);
        
        svm_dist_pos_neg_matrix{c, c2} = [svm_dist_pos svm_dist_neg];
        
        % true outcomes: one value per subject for pos and neg outcomes stacked
        % check that all images considered replicates have same outcome value
        
        % if sum(wh_pos) ~= sum(wh_neg), error('There must be equal numbers of pos and neg contrasts weights, or edit script to increase flexibility.'); end
        
        % Y_transfer_out = reshape(Y_transfer, 2*n, sum(wh_pos)); % assume pos and neg conditions equally balanced
%         if any(diff(Y_transfer_out', 1))
%             error('Ourcomes for images considered replicates are not identical. Debug.');
%         end
        % Y_transfer_out = mean(Y_transfer_out, 2);
        
        % outcome_matrix no longer used in c2_SVM_contrasts...
        % outcome_matrix{c, c2} = [ones(size(svm_dist_pos)) -ones(size(svm_dist_neg))]; %Y_transfer_out;
        
    end % transfer contrast
    
end % crossval contrast


end % function


% RUN FOR WHOLE IMAGE LIST, FOR TRANSFER ANALYSIS

function subject_indices = get_subject_ids(all_condition_codes)
% Get list of subject IDs
% Assuming subjects are ordered 1:n within each condition
subject_indices = zeros(size(all_condition_codes));

for i = unique(all_condition_codes)'
    
    wh = all_condition_codes == i;
    indxnums = (1:sum(wh))';
    
    subject_indices(wh) = indxnums;
    
end

end

% RUN FOR EACH STATS STRUCT / CROSS-VALIDATED ANALYSIS,  FOR TRANSFER ANALYSIS

function [fold_testset, fold_testsubjects] = get_test_subjects_by_fold(stats, subject_indices, eligible_images)

fold_testset = stats.teIdx;  % cell array, one cell per fold. Eligible test images for each fold. This is indexed wrt eligible images for this contrast only.

eligible_subjects = subject_indices(eligible_images);
fold_testsubjects = cell(1, length(fold_testset));
for i = 1:length(fold_testset)
    
    fold_testsubjects{i} = unique(eligible_subjects(fold_testset{i}));      % replicated across conditions, so do unique.
    
end

end

    
    
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

%%
function [eligible_images, Y_this_stats_obj] = get_eligible_images_and_outcomes(mycontrast, all_condition_codes)

wh = find(mycontrast);

eligible_images = false(size(all_condition_codes)); % eligible: included in teIdx list for this stats obj
Y_this_stats_obj = zeros(size(all_condition_codes));

for i = 1:length(wh)  % loop through conditions in this stats object
    
    indx = all_condition_codes == wh(i);    % images in this condition
    eligible_images(indx) = true;
    
    if  mycontrast(wh(i)) > 0
        Y_this_stats_obj(indx) = 1;
    elseif mycontrast(wh(i)) < 0
        Y_this_stats_obj(indx) = -1;
    end
    
end

end



function [svm_dist_pos, svm_dist_neg] = reshape_and_average(svm_dist_pos, svm_dist_neg, mycontrast)

% k is number of pos and neg contrast weights - average over k values
% per subject to get one score per pos/neg contrast value per subject
% n is number of images (rows) in matrix,
% if there are multiple contrast weights with pos and/or neg values
kpos = sum(mycontrast > 0);
kneg = sum(mycontrast < 0);
npos = length(svm_dist_pos) ./ kpos;
nneg = length(svm_dist_neg) ./ kneg;

% reshape so that we can average
%     svm_dist_pos = reshape(svm_dist_pos, n, sum(wh_pos));
%     svm_dist_neg = reshape(svm_dist_neg, n, sum(wh_neg));
svm_dist_pos = reshape(svm_dist_pos, npos, kpos);
svm_dist_neg = reshape(svm_dist_neg, nneg, kneg);

% average to get one score per pos/neg contrast value per subject
svm_dist_pos = mean(svm_dist_pos, 2);
svm_dist_neg = mean(svm_dist_neg, 2);

end

