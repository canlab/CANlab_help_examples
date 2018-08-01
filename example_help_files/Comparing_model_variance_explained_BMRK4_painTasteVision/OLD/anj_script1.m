load('/Users/tor/Dropbox/A_A_CURRENT_DRAFTS_TO_REVIEW/Anjali_BMRK4_painTasteVision_extracted_pexp/bmrk4_pain_specific_PTV_overall.mat')

XX = X_pain_all;
YY = Y_pain;
names = [{'Intercept'} X_col_names {'Interaction'}];

% mean-center and create interaction
XX = cellfun(@(x) scale(x, 1), XX, 'UniformOutput', false);
XX = cellfun(@(x) [x x(:, 1).*x(:, 2)], XX, 'UniformOutput', false);

stats = glmfit_multilevel(YY, XX, [], 'verbose', 'weighted', 'names', names);
