% This script works with the CANlab batch scripts to add meta-data to
% DATA_OBJ and DATA_OBJsc image data in data_objects.mat and
% data_objects_scaled.mat, and contrast_data_objects.mat

% define basedir and resultsdir first, e.g.:
% basedir = ('/Users/f003vz1/Dropbox (Dartmouth College)/A4_PUBLISHED_KeepHandy/Wager_publications_2022/2022_Ceko_MPA1_MPA2_PainMem_B_AVERSIVE');
% resultsdir = fullfile(basedir, 'results');

% define source notes string first, e.g., 
% source_notes_str = 'Wehrum S, Klucken T, Kagerer S, Walter B, Hermann A, Vaitl D, Stark R. 2013. Gender commonalities and differences in the neural processing of visual sexual stimuli. J Sex Med. 10(5):1328–1342. https://doi.org/10.1111/jsm.12096.';

load(fullfile(resultsdir, 'data_objects.mat'), 'DATA_OBJ')

nconds = length(DAT.conditions);

% Add tables to metadata_table in CONDITION object
% ----------------------------------------------------------------------
for i = 1:nconds

    t = get_condition_table(DAT, i);

    % Add metadata table
    DATA_OBJ{i}.metadata_table = t;

    % Add source notes
    DATA_OBJ{i}.source_notes = source_notes_str;

    % Add warnings and meta-info

    if isempty(DATA_OBJ{i}.additional_info)
        DATA_OBJ{i}.additional_info = struct('warnings', [], 'qc', []);
    end

    DATA_OBJ{i}.additional_info.qc = DAT.quality_metrics_by_condition{i};
    DATA_OBJ{i}.additional_info.warnings = DAT.quality_metrics_by_condition{i}.warnings';

end

save(fullfile(resultsdir, 'data_objects.mat'), '-append', 'DATA_OBJ')


%% Add tables to metadata_table in CONDITIONSC object
% ----------------------------------------------------------------------
clear DATA_OBJ
load(fullfile(resultsdir, 'data_objects_scaled.mat'), 'DATA_OBJsc')

for i = 1:nconds

    t = get_condition_table(DAT, i);

    % Add metadata table
    DATA_OBJsc{i}.metadata_table = t;

    % Add source notes
    DATA_OBJsc{i}.source_notes = source_notes_str;
  
    % Add warnings and meta-info

    if isempty(DATA_OBJsc{i}.additional_info)
        DATA_OBJsc{i}.additional_info = struct('warnings', [], 'qc', []);
    end

    DATA_OBJsc{i}.additional_info.qc = DAT.quality_metrics_by_condition{i};
    DATA_OBJsc{i}.additional_info.warnings = DAT.quality_metrics_by_condition{i}.warnings';

end

save(fullfile(resultsdir, 'data_objects_scaled.mat'), '-append', 'DATA_OBJsc')

%% Add tables to metadata_table in CONTRAST object
% ----------------------------------------------------------------------
clear DATA_OBJsc
load(fullfile(resultsdir, 'contrast_data_objects.mat'), 'DATA_OBJ_CON', 'DATA_OBJ_CONsc')

ncontrasts = length(DAT.contrastnames);

for i = 1:ncontrasts

    t = get_contrast_table(DAT, i);

    % Add metadata table
    DATA_OBJ_CON{i}.metadata_table = t;
    DATA_OBJ_CONsc{i}.metadata_table = t;

    % Add source notes
    DATA_OBJ_CON{i}.source_notes = source_notes_str;
    DATA_OBJ_CONsc{i}.source_notes = source_notes_str;
  
end

save(fullfile(resultsdir, 'contrast_data_objects.mat'), '-append', 'DATA_OBJ_CON', 'DATA_OBJ_CONsc')

disp('Successfully added .metadata_table fields to data objects in results')

%% SUBFUNCTIONS

function t = get_condition_table(DAT, i)

% number of images in each condition cell
nrows = @(x) size(x, 1);
nimgs = cellfun(nrows, DAT.imgs); 

t = table(repmat(DAT.conditions(i), nimgs(i), 1), 'VariableNames', {'condition'});

% Add mean gray, white, CSF for each image

gm = DAT.gray_white_csf{i}(:, 1);
wm = DAT.gray_white_csf{i}(:, 2);
csf = DAT.gray_white_csf{i}(:, 3);

t = addvars(t, gm, wm, csf, 'NewVariableNames', {'gm' 'wm' 'csf'});

t = addvars(t, DAT.globalstd{i}, 'NewVariableNames', {'globalstd'});

% Add image names

t = addvars(t, cellstr(DAT.imgs{i}), 'NewVariableNames', {'imagenames'});


end




function t = get_contrast_table(DAT, i)

% number of images in each condition cell
nrows = @(x) size(x, 1);
nimgs = cellfun(nrows, DAT.imgs); 

t = table(repmat(DAT.contrastnames(i), nimgs(i), 1), 'VariableNames', {'contrast'});

t = addvars(t, repmat(DAT.contrasts(i, :), nimgs(i), 1), 'NewVariableNames', {'contrastweights'});

% Add mean gray, white, CSF for each image

gm = DAT.gray_white_csf_contrasts{i}(:, 1);
wm = DAT.gray_white_csf_contrasts{i}(:, 2);
csf = DAT.gray_white_csf_contrasts{i}(:, 3);

t = addvars(t, gm, wm, csf, 'NewVariableNames', {'gm' 'wm' 'csf'});

end


