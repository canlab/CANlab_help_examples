%% Getting started: add paths

addpath(genpath('/Users/wani/github/canlabrepo/CanlabCore'));

%% Reading images (you don't need this part now)

% basedir = '/Volumes/engram/labdata/current/BMRK3';
% imgs = filenames(fullfile(basedir, 'Imaging/*/Models/Temp/beta_000[1-5].img'));
% mask = fullfile(basedir,'pain_2s_z_val_FDR05_pos.nii');
% % This will read the data only within the mask
% dat = fmri_data(imgs, mask);

%% Load data

load('/Users/clinpsywoo/github/SAS2015_PatRec/data.mat');

% check dat.Y
plot(dat.Y);
set(gcf, 'color', 'w');
set(gca, 'fontsize', 15);
for x = 5:5:145
    line([x,x], [0, 200], 'linestyle', '--', 'color', [.6 .6 .6]); 
end

% check dat.dat
imagesc(dat.dat);
ylabel('voxels');
xlabel('subject x conditions')
colorbar;

%% 1. Run LASSO-PCR

% 10-fold CV with a grid search of the optimal lasso number

for i = 10:10:130
    str = ['Working on ' num2str(i)];
    disp(str);
    [~, tfcv.stats{i/10}] = predict(dat, 'algorithm_name', ...
        'cv_lassopcr', 'nfolds', 8, 'error_type', 'mse', 'lasso_num', i);
end

% check the prediction outcome correlation
for i = 1:numel(tfcv.stats)
    por(i) = tfcv.stats{i}.pred_outcome_r;
end
[a,b] = max(por);

plot(10:10:130, por); hold on; scatter(b*10,a, 120, 'rs', 'filled');
ylabel('prediction-outcome correlation')
xlabel('lasso number')

% visualize the weight map
orthviews(tfcv.stats{12}.weight_obj)

% plot y and yfit
plot_correlation(tfcv.stats{12}.Y, tfcv.stats{12}.yfit);
xlabel('original outcome (y)');
ylabel('predicted outcome (y-fit)');

%% leave-one-subject-out CV
wh_folds = reshape(repmat(1:30,5,1), 150, 1);
[~, loso.stats] = predict(dat, 'algorithm_name', ...
        'cv_lassopcr', 'nfolds', wh_folds, 'error_type', 'mse', ...
        'lasso_num', 120);
    
%% estimate lambda using nested CV
[~, loso.stats] = predict(dat, 'algorithm_name', ...
        'cv_lassopcr', 'nfolds', 8, 'error_type', 'mse', ...
        'EstimateParams');
    

%% 2. Run SVMs

% Prepare data for SVMs
wh_folds = repmat(reshape(repmat(1:30,2,1), 60, 1), 2, 1);

dat_svm = dat;
dat_svm.dat = [dat.dat(:,reshape(repmat(1:5, 30,1)', 150,1) <= 2) ...
    dat.dat(:,reshape(repmat(1:5, 30,1)', 150,1) >= 4)];
dat_svm.Y = [-ones(60,1); ones(60,1)];

% run linear SVMs with leave-one-subject-out CV
[~, svm.stats] = predict(dat_svm, 'algorithm_name', ...
        'cv_svm', 'nfolds', wh_folds, 'error_type', 'mcr');

% cross-validated distance from hyperplane 
svm.stats.dist_from_hyperplane_xval

% visualize the weight map
orthviews(svm.stats.weight_obj);
    
% RBF kernel
[~, svm.stats] = predict(dat_svm, 'algorithm_name', ...
        'cv_svm', 'rbf', 2, 'nfolds', wh_folds, 'error_type', 'mcr');

% Slack variables, C = 3
[~, svm.stats] = predict(dat_svm, 'algorithm_name', ...
        'cv_svm', 'C', 3, 'nfolds', wh_folds, 'error_type', 'mcr');
