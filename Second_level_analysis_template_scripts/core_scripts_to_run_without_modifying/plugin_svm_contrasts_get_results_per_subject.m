function [dist_from_hyperplane, Y, svm_dist_pos_neg] = plugin_svm_contrasts_get_results_per_subject(DAT, svm_stats_results, DATA_OBJ)
% [dist_from_hyperplane, Y, svm_dist_pos_neg] = plugin_svm_contrasts_get_results_per_subject(DAT, svm_stats_results, DATA_OBJ)
%
% c2_SVM_contrasts runs SVMs for sets of images coded as 1 or -1
% within-person, across conditions.  This may involve multiple images coded
% with 1 or -1 per person, in which case the svm_stats_results stats
% structures will contain image-wise classification results, not
% person-wise averaging over images for each person.
% This function calculates an average pattern expression value (distance from hyperplane) 
% for each person for images coded as 1 and those coded as -1.
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
    
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
     
    % Get SVM stats for this contrast
    stats = svm_stats_results{c};
    
    wh_pos = mycontrast(wh) > 0;
    wh_neg = mycontrast(wh) < 0;
     
    % starting and ending indices for each condition
    en = cumsum(images_per_condition(wh));
    st = en - images_per_condition(wh(1)) + 1;

    z = false(size(stats.yfit,1), 2);  % images x 2, pos contrast value and neg contrast value
    
    for i = 1:length(wh)
        
        %mycond = wh(i);
        
        if wh_pos(i)
        z(st(i):en(i), 1) = true;
        
        elseif wh_neg(i)
        z(st(i):en(i), 2) = true;
   
        end
        
    end

    svm_dist_pos = stats.dist_from_hyperplane_xval(z(:, 1));
    svm_dist_neg = stats.dist_from_hyperplane_xval(z(:, 2));
    
    % assume all equal n's, reshape
    svm_dist_pos = reshape(svm_dist_pos, n, sum(wh_pos));
    svm_dist_neg = reshape(svm_dist_neg, n, sum(wh_neg));
    
    % average to get one score per pos/neg contrast value per subject
    svm_dist_pos = mean(svm_dist_pos, 2);
    svm_dist_neg = mean(svm_dist_neg, 2);

    svm_dist_pos_neg{c} = [svm_dist_pos svm_dist_neg];
    
    % ROC plot, accuracy,and effect size
     
    Y{c} = [ones(size(svm_dist_pos)); -ones(size(svm_dist_neg))];
    dist_from_hyperplane{c} = [svm_dist_pos; svm_dist_neg];
    
end

