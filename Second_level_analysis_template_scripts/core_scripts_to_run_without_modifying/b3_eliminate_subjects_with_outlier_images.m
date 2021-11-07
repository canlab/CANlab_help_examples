% Logic: Identify a set of "good" subjects for which no condition images are marked as outliers 
% If a subject has one condition image that is an outlier, any contrast
% involving that image is also likely to be an outlier.
%
% Use fmri_data.outliers( ) to get outlier status for combined set of
% condition images. (Could be done separately for each condition, but there
% are tradeoffs: Some measures, like those based on global mean and var,
% are likely to perform better with more images and should be similar across conditions.
% If we assume that the conditions are not dramatically different, this
% approach may be preferred. If we assume that conditions are dramatically
% different, calculating outliers within each condition separately may be
% better.

% Assume we have already reloaded using b_reload... so skip this.
% load('data_objects.mat')  % Load DATA_OBJ
% load('image_names_and_setup.mat'); % Load DAT

obj = cat(DATA_OBJ{:});

[est_outliers_uncorr, est_outliers_corr, outlier_tables] = outliers(obj, 'notimeseries');

%% Identify and save subject-wise good and bad subjects

% Get sizes
% assume all subjects appear in all conditions in same order 
% (within-person designs only!)

n = size(obj.dat, 2) ./ length(DAT.conditions);
subjid = repmat((1:n)', length(DAT.conditions), 1);

% 'uncorr' is more liberal in finding outliers, so more aggressive in terms of what we remove.
bad_subjects_uncorr = unique(subjid(est_outliers_uncorr));
not_outliers = ~ismember(subjid, bad_subjects_uncorr);
good_subjects_uncorr = unique(subjid(not_outliers));

% 'corr' is more conservative in finding outliers, so less aggressive 
% We should probably be less aggressive overall, across studies, so we'll
% use this when selecting data
bad_subjects_corr = unique(subjid(est_outliers_corr));
not_outliers = ~ismember(subjid, bad_subjects_corr);
good_subjects_corr = unique(subjid(not_outliers));

% Save in DAT structure
DAT.outliers = struct('bad_subjects_uncorr', bad_subjects_uncorr, 'bad_subjects_corr', bad_subjects_corr, 'good_subjects_uncorr', good_subjects_uncorr, 'good_subjects_corr', good_subjects_corr);

% Save details
DAT.outliers.outlier_tables = outlier_tables;

%% Remove outliers from DATA_OBJ

DATA_OBJ_CLEANED = cell(1, length(DAT.conditions));

for i = 1:length(DAT.conditions)
   
    DATA_OBJ_CLEANED{i} = get_wh_image(DATA_OBJ{i}, DAT.outliers.good_subjects_corr);
    
end
