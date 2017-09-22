
%% Load stats
savefilenamedata = fullfile(resultsdir, 'svm_stats_results_contrasts.mat');

if ~exist(savefilenamedata, 'file')
    disp('Run prep_3b_run_SVMs_on_contrasts_and_save with dosavesvmstats = true option to get SVM results.'); 
    disp('No saved results file.  Skipping this analysis.')
    return
end

fprintf('\nLoading SVM results and maps from %s\n\n', savefilenamedata);
load(savefilenamedata, 'svm_stats_results');

%% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
whmontage = 5; 
plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------

printhdr('Cross-validated SVM to discriminate within-person contrasts');

%% Average images collected on the same person within each SVM class, for testing
% --------------------------------------------------------------------
% - This plugin function calculates (a) cross-validated distances from the
% SVM hyerplane, and (b) a cross-classification matrix across contrasts
% - It averages images within the same subject and condition (+ or -,
% on/off in the SVM analysis) into one image for testing purposes, so that
% it performs a subject-wise forced choice classification
% - It assumes that the image lists for each condition contain images for subjects 1:n
% in each condition, in the same order.

% The purpose of this plugin is to average over replicates of images with the
% same outcome collected on the same individuals.  We want one average
% image for outcome 1 and one average image for outcome -1 per person, and
% we want to test person-wise classification.
%
% Depending on how contrasts are specified, stats results structure from SVM training
% may involve multiple images coded
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

[dist_from_hyperplane, Y, svm_dist_pos_neg, svm_dist_pos_neg_matrix, outcome_matrix] = plugin_svm_contrasts_get_results_per_subject(DAT, svm_stats_results, DATA_OBJ);

%% Check that we have paired images and skip if not. See below for details
% --------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

ispaired = false(1, kc);

for i = 1:kc
    ispaired(i) = sum(Y{i} > 0) == sum(Y{i} < 0);
end

if ~all(ispaired)
    disp('This script should only be run on paired, within-person contrasts');
    disp('Check images and results. Skipping this analysis.');
    return
end


%% Define effect size functions and between/within ROC type
% --------------------------------------------------------------------
% Define paired and uppaired functions here for reference
% This script uses the paired option because it runs within-person
% contrasts

% ROC plot is different for paired samples and unpaired. Paired samples
% must be in specific order, 1:n for condition 1 and 1:n for condition 2.
% If samples are paired, this is set up by default in these scripts.
% But some contrasts entered by the user may be unbalanced, i.e., different
% numbers of images in each condition, unpaired. Other SVM scripts are set up
% to handle this condition explicitly and run the unpaired version.  

% Effect size, cross-validated, paired samples
dfun_paired = @(x, Y) mean(x(Y > 0) - x(Y < 0)) ./ std(x(Y > 0) - x(Y < 0));

% Effect size, cross-validated, unpaired sampled
dfun_unpaired = @(x, Y) (mean(x(Y > 0)) - mean(x(Y < 0))) ./ sqrt(var(x(Y > 0)) + var(x(Y < 0))); % check this.

rocpairstring = 'twochoice';  % 'twochoice' or 'unpaired'


%% Cross-validated accuracy and ROC plots for each contrast
% --------------------------------------------------------------------

for c = 1:kc
    
    printstr(DAT.contrastnames{c});
    printstr(dashes)
    
    % ROC plot
    % --------------------------------------------------------------------
    
    figtitle = sprintf('SVM ROC %s', DAT.contrastnames{c});
    create_figure(figtitle);
    
    ROC = roc_plot(dist_from_hyperplane{c}, logical(Y{c} > 0), 'color', DAT.contrastcolors{c}, rocpairstring);
    
    d_paired = dfun_paired(dist_from_hyperplane{c}, Y{c});
    fprintf('Effect size, cross-val: Forced choice: d = %3.2f\n\n', d_paired);
    
    plugin_save_figure

    % Plot the SVM map
    % --------------------------------------------------------------------
    % Get the stats results for this contrast, with weight map
    stats = svm_stats_results{c};
    
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(stats.weight_obj), 'trans');
        
    axes(o2.montage{whmontage}.axis_handles(5));
    title(DAT.contrastnames{c}, 'FontSize', 18)
    
    printstr(DAT.contrastnames{c}); printstr(dashes);
    
    figtitle = sprintf('SVM weight map nothresh %s', DAT.contrastnames{c});
    plugin_save_figure;
    
    % Remove title in case fig is re-printed in html
    axes(o2.montage{whmontage}.axis_handles(5));
    title(' ', 'FontSize', 18)
    
    o2 = removeblobs(o2);
    
    axes(o2.montage{whmontage}.axis_handles(5));
    title('Intentionally Blank', 'FontSize', 18); % For published reports
    
end  % within-person contrast

%% Cross-classification matrix
% uses svm_dist_pos_neg_matrix, outcome_matrix from plugin

diff_function = @(x) x(:, 1) - x(:, 2);         % should be positive for correct classification

iscorrect = @(x) sign(diff_function(x)) > 0;

cohens_d_function = @(x) mean(x) ./ std(x);

acc_function = @(corr_idx) 100 * sum(corr_idx) ./ length(corr_idx);

svm_dist_per_subject_and_condition = cellfun(diff_function, svm_dist_pos_neg_matrix, 'UniformOutput', false);

svm_cohens_d_train_transfer = cell2mat(cellfun(cohens_d_function, svm_dist_per_subject_and_condition, 'UniformOutput', false));

accuracy_by_subject_and_condition = cellfun(iscorrect, svm_dist_pos_neg_matrix, 'UniformOutput', false);

accuracy = cellfun(acc_function, accuracy_by_subject_and_condition, 'UniformOutput', false);
accuracy = cell2mat(accuracy);

% Figure
% -------------------------------------------------------------------------
figtitle = sprintf('SVM Cross_classification');
create_figure(figtitle);

pos = get(gcf, 'Position');
pos(3) = pos(3) * 1.7;
set(gcf, 'Position', pos)

printhdr('Cross-validated distance from hyperplane. > 0 is correct classification');

ntransfer = size(svm_dist_per_subject_and_condition, 2);
text_xval = [];
han = {};

for c = 1:kc
   
    dat = svm_dist_per_subject_and_condition(c, :);
    
    xvals = 1 + ntransfer * (c-1) : c * ntransfer;
    
    xvals = xvals + c - 1; % skip a space

    text_xval(c) = mean(xvals);
    mycolors = DAT.contrastcolors;
    
    trainname = DAT.contrastnames{c};
    xtick_text{c} = sprintf('Train %s', trainname);

    mynames = DAT.contrastnames;  % for barplot_columns output
    
    printhdr(sprintf('Train on %s', trainname));
    
    han{c} = barplot_columns(dat, 'nofig', 'noviolin', 'colors', mycolors, 'x', xvals, 'names', mynames);
    set(gca, 'XLim', [.5 xvals(end) + .5]);
    
end

xlabel(' ');
ylabel('Distance from hyperplane');

barhandles = cat(2, han{1}.bar_han{:});
legend(barhandles, DAT.contrastnames)

set(gca, 'XTick', text_xval, 'XTickLabel', xtick_text, 'XTickLabelRotation', 0);

printhdr('Accuracy matrix - training (rows) by test contrasts (columns)');
print_matrix(accuracy, DAT.contrastnames, DAT.contrastnames);

plugin_save_figure;

%% Figure and stats on effect sizes
% -------------------------------------------------------------------------
figtitle = sprintf('SVM Cross-classification effect sizes');
create_figure(figtitle);

% pos = get(gcf, 'Position');
% pos(3) = pos(3) * 1.7;
% set(gcf, 'Position', pos)

printhdr(figtitle);

imagesc(svm_cohens_d_train_transfer)
set(gca, 'YDir', 'reverse', 'YTick', 1:kc,  'YTickLabel', xtick_text(1:kc), 'XTick', 1:kc, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);
title(figtitle);
xlabel('Test condition');
ylabel('Training condition');
colorbar
cm = colormap_tor([1 1 1], [1 0 0]);
colormap(cm)

plugin_save_figure;

print_matrix(svm_cohens_d_train_transfer, DAT.contrastnames, xtick_text(1:kc));

