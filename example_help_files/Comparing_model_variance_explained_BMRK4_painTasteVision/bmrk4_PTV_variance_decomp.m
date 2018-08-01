%% Script to get the variance decomposition for bmrk4 based on overall aversion pattern and modality-specific patterns

clear all
close all
clc

load bmrk4_pain_specific_PTV_overall.mat
load bmrk4_taste_specific_PTV_overall.mat
load bmrk4_vision_specific_PTV_overall.mat

% PTV = pain, taste, vision (observed pain). Run in 3 separate sessions within the same 
% participants, on different days.  Data partially published in
% Krishnan et al. 2016 eLife; taste data to be used in forthcoming
% manuscript.

% In each file, X is a cell array of length n subjects (26 subjects). Each
% cell contains a design matrix (X) for the subject.
% X contains singe trial brain responses from two brain 'signature' models, 
% cross-validated (from fmri_data.predict.m) The two signatures (columns in X) were 
% a model trained on a single modality only, or a model trained to generalize
% across modalities.  All brain responses are from out-of-sample (new subjects, from cross-validation),
% so it's fair to compare the predictive accuracy of these models in explaining subjective reports.

% X_col_names contains names for the two predictors in each matrix.
%  {'modality_specific'}    {'modality_independent'}

% Y_pain = ratings for pain session. Y_taste = ratings for taste session.
% Y_vision, same for vision session.


diaryname = fullfile(pwd, ['PainTasteVision_GLMs_' date '_output.txt']);
diary(diaryname)

%% Multi-level multiple regression.

% Use {'modality_specific'}    {'modality_independent'} brain models to
% predict subjective ratings for each modality.  We want to compare the
% variances explained by the modality-spec model vs. the general model of
% negative affective brain responses. 

% Pain Data
XX_pain_all = X_pain_all;
YY_pain_all = Y_pain;

% Mean-center X and Y
XX_pain_all = cellfun(@(x) scale(x, 1), XX_pain_all, 'UniformOutput', false);
YY_pain_all = cellfun(@(x) scale(x, 1), YY_pain_all, 'UniformOutput', false);

% Create interaction
% XX_pain_all = cellfun(@(x) [x x(:, 1).*x(:, 2)], XX_pain_all, 'UniformOutput', false);

% Label columns
% names = [{'Intercept'} X_col_names {'Interaction'}];
names = [{'Intercept'} X_col_names];

mycolors = {[1 .5 0], [.5 .2 .5]};   % orange=specific, purple=common, shared=blend of these 
mycolors{3} = (mycolors{1} + mycolors{2}) ./ 2;
mycolors{4} = [.3 .3 .3];           % gray = residual

z = '-------------------------------------';
fprintf('PAIN\n%s\n', z);

% Compute glmfit_multilevel
stats_pain = glmfit_multilevel(YY_pain_all, XX_pain_all, [], 'verbose', 'weighted', 'names', names);

% Variance decomposition
pain_vardecomp = glmfit_multilevel_varexplained(XX_pain_all,YY_pain_all,stats_pain.beta', 'colors', mycolors);

saveas(gcf, fullfile('Figs_orangePain_greenTaste_blueVision_purpleCommonAffect', 'Pain_var_decomp.png')); 

%% Taste Data
XX_taste_all = X_taste_all;
YY_taste_all = Y_taste;

% Mean-center X and Y
XX_taste_all = cellfun(@(x) scale(x, 1), XX_taste_all, 'UniformOutput', false);
YY_taste_all = cellfun(@(x) scale(x, 1), YY_taste_all, 'UniformOutput', false);

% Create interaction
%XX_taste_all = cellfun(@(x) [x x(:, 1).*x(:, 2)], XX_taste_all, 'UniformOutput', false);

% Label columns
%names = [{'Intercept'} X_col_names {'Interaction'}];

names = [{'Intercept'} X_col_names];

mycolors = {[0 .8 0], [.5 .2 .5]};   % green=specific taste, purple=common, shared=blend of these 
mycolors{3} = (mycolors{1} + mycolors{2}) ./ 2;
mycolors{4} = [.3 .3 .3];           % gray = residual

z = '-------------------------------------';
fprintf('TASTE\n%s\n', z);

% Compute glmfit_multilevel
stats_taste = glmfit_multilevel(YY_taste_all, XX_taste_all, [], 'verbose', 'weighted', 'names', names);

% Variance decomposition
taste_vardecomp = glmfit_multilevel_varexplained(XX_taste_all,YY_taste_all,stats_taste.beta', 'colors', mycolors);

saveas(gcf, fullfile('Figs_orangePain_greenTaste_blueVision_purpleCommonAffect', 'Taste_var_decomp.png')); 

%% Vision Data
XX_vision_all = X_vision_all;
YY_vision_all = Y_vision;

% Mean-center X and Y
XX_vision_all = cellfun(@(x) scale(x, 1), XX_vision_all, 'UniformOutput', false);
YY_vision_all = cellfun(@(x) scale(x, 1), YY_vision_all, 'UniformOutput', false);

% Create interaction
%XX_vision_all = cellfun(@(x) [x x(:, 1).*x(:, 2)], XX_vision_all, 'UniformOutput', false);

% Label columns
% names = [{'Intercept'} X_col_names {'Interaction'}];
names = [{'Intercept'} X_col_names];

mycolors = {[0 0 1], [.5 .2 .5]};   % blue=specific vision, purple=common, shared=blend of these 
mycolors{3} = (mycolors{1} + mycolors{2}) ./ 2;
mycolors{4} = [.3 .3 .3];           % gray = residual


z = '-------------------------------------';
fprintf('VISION\n%s\n', z);

% Compute glmfit_multilevel
stats_vision = glmfit_multilevel(YY_vision_all, XX_vision_all, [], 'verbose', 'weighted', 'names', names);

% Variance decomposition
vision_vardecomp = glmfit_multilevel_varexplained(XX_vision_all,YY_vision_all,stats_vision.beta', 'colors', mycolors);

saveas(gcf, fullfile('Figs_orangePain_greenTaste_blueVision_purpleCommonAffect', 'Vision_var_decomp.png')); 


diary off

