%
%
% Format: The prep_6 script extracts signature responses and saves them.
% These fields contain data tables:
% DAT.SIGNATURES.(signaturename).(data scaling).(similarity metric).by_condition
% DAT.SIGNATURES.(signaturename).(data scaling).(similarity metric).contrasts
%
% signaturenames is any of those from load_image_set('kragelemotion')
% (data scaling) is 'raw' or 'scaled', using DATA_OBJ or DATA_OBJsc
% (similarity metric) is 'dotproduct' or 'cosine_sim'
% 
% Each of by_condition and contrasts contains a data table whose columns
% are conditions or contrasts, with variable names based on DAT.conditions
% or DAT.contrastnames, but with spaces replaced with underscores.




%% All Signatures
k = length(DAT.conditions);

printhdr('Extracting Emotion-Category Models, adding to DAT')

% Dot product metric
DAT.EMO_CAT_SIG_conditions.raw.dotproduct = apply_all_signatures(DATA_OBJ, 'conditionnames', DAT.conditions,'image_set','kragelemotion');
DAT.EMO_CAT_SIG_contrasts.raw.dotproduct = apply_all_signatures(DATA_OBJ_CON, 'conditionnames', DAT.contrastnames,'image_set','kragelemotion');

% Cosine similarity
DAT.EMO_CAT_SIG_conditions.raw.cosine_sim = apply_all_signatures(DATA_OBJ, 'conditionnames', DAT.conditions, 'similarity_metric', 'cosine_similarity','image_set','kragelemotion');
DAT.EMO_CAT_SIG_contrasts.raw.cosine_sim = apply_all_signatures(DATA_OBJ_CON, 'conditionnames', DAT.contrastnames, 'similarity_metric', 'cosine_similarity','image_set','kragelemotion');

% Scaled images.  
% apply_all_signatures will do scaling as well, but we did this in image
% loading, so use those here

% Dot product metric
DAT.EMO_CAT_SIG_conditions.scaled.dotproduct = apply_all_signatures(DATA_OBJsc, 'conditionnames', DAT.conditions,'image_set','kragelemotion');
DAT.EMO_CAT_SIG_contrasts.scaled.dotproduct = apply_all_signatures(DATA_OBJ_CONsc, 'conditionnames', DAT.contrastnames,'image_set','kragelemotion');

% Cosine similarity
DAT.EMO_CAT_SIG_conditions.scaled.cosine_sim = apply_all_signatures(DATA_OBJsc, 'conditionnames', DAT.conditions, 'similarity_metric', 'cosine_similarity','image_set','kragelemotion');
DAT.EMO_CAT_SIG_contrasts.scaled.cosine_sim = apply_all_signatures(DATA_OBJ_CONsc, 'conditionnames', DAT.contrastnames, 'similarity_metric', 'cosine_similarity','image_set','kragelemotion');



%% Save

printhdr('Save results');

savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, 'DAT', '-append');


