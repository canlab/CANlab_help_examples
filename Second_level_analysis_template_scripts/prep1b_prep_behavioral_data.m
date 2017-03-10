behavioral_data_filename = 'paindata_Failla2Wager.xlsx';
behavioral_fname_path = fullfile(datadir, behavioral_data_filename);

if ~exist(behavioral_fname_path, 'file'), fprintf(1, 'CANNOT FIND FILE: %s\n',behavioral_fname_path); end

behavioral_data_table = readtable(behavioral_fname_path,'FileType','spreadsheet');



%% CUSTOM CODE: TRANSFORM INTO between_design_table
%
% you need to arrange the variables in your behavioral data file into a
% table variable called between_design_table.  This contains a matrix of
% behavioral observations to match with your images.
%
% a variable called 'id' contains subject identfiers.  Other variables will
% be used as regressors.  Variables with only two levels should be effects
% coded, with [1 -1] values.a

% This file starts with entries both between- and within-person: Multiple
% entries per subject. 

% First create behavioral_data_table_all with all variables.

id = behavioral_data_table.DataShareID;
whok = behavioral_data_table.Runs == 1;

% Excluded subjects (missing brain data)
exclude_id = [116];
for i = 1:length(exclude_id)
    
    whomit = id == exclude_id(i);
    whok(whomit) = 0;
    
end

id = id(whok);
group = behavioral_data_table.Group(whok);
group = contrast_code(scale(group, 1));     % effects code

[id, ~, wh] = unique(id);

group = group(wh);
behavioral_indiv_diffs = table(id, group);    

clear pain

for i = 1:length(id)
    
    whi = behavioral_data_table.DataShareID == id(i);
    
    paini = behavioral_data_table.PainRating(whi);
    
    pain(i, 1) = nanmean(paini);  % issue if missing not at random; but likely ok here
    
end

behavioral_indiv_diffs.pain = pain;


%% Add pain within group

pain(isnan(pain)) = nanmean(pain); % impute mean

X = behavioral_indiv_diffs.group; 
X(:, end+1) = 1;
pain_within_group = resid(X, pain);

between_subject_design = table(group, pain_within_group);
    
DAT.BEHAVIOR = struct('behavioral_data_table', behavioral_data_table, 'behavioral_indiv_diffs', behavioral_indiv_diffs, 'between_subject_design', between_subject_design);
