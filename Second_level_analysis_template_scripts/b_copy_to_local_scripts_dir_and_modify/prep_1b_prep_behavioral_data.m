%% READ behavioral data from file. These data will be put into standard structure compatible with analyses

behavioral_data_filename = 'sedation_scores_for_tor.xlsx';
behavioral_fname_path = fullfile(datadir, behavioral_data_filename);

if ~exist(behavioral_fname_path, 'file'), fprintf(1, 'CANNOT FIND FILE: %s\n',behavioral_fname_path); end

behavioral_data_table = readtable(behavioral_fname_path,'FileType','spreadsheet');

% Add to DAT for record, and flexible use later
DAT.BEHAVIOR.behavioral_data_table = behavioral_data_table;

%% INITIALIZE GROUP VARIABLE

% Single group variable, optional, for convenience
% These fields are mandatory, but they can be empty
% If group variable and between-person variables vary by
% condition/contrast, leave these empty
% -------------------------------------------------------------------------
DAT.BETWEENPERSON.group = [];
DAT.BETWEENPERSON.groupnames = {};
DAT.BETWEENPERSON.groupcolors = {};


%% INITIALIZE CONDITION/CONTRAST-SPECIFIC BETWEEN-PERSON DATA TABLES

% Cell array with table of group (between-person) variables for each
% condition, and for each contrast.
% If variables are entered:
% 1. they will be controlled for in analyses of the
% overall condition/contrast effects.
% 2. Analyses relating conditions/contrasts to these variables will be
% performed.
% If no variables are entered (empty elements), only
% within-person/whole-group effects will be analyzed.

% Initialize empty variables
DAT.BETWEENPERSON = [];

% Between-person variables influencing each condition
% Table of [n images in condition x q variables]
% names in table can be any valid name.

DAT.BETWEENPERSON.conditions = cell(1, length(DAT.conditions));
[DAT.BETWEENPERSON.conditions{:}] = deal(table());  % empty tables

% Between-person variables influencing each condition
% Table of [n images in contrast x q variables]
% names in table can be any valid name.

DAT.BETWEENPERSON.contrasts = cell(1, length(DAT.contrastnames));
[DAT.BETWEENPERSON.contrasts{:}] = deal(table());  % empty tables



%% CUSTOM CODE: TRANSFORM INTO between_design_table
%
% Create a table for each condition/contrast with the between-person design, or leave empty.
%
% a variable called 'id' contains subject identfiers.  Other variables will
% be used as regressors.  Variables with only two levels should be effects
% coded, with [1 -1] values.
%
% 
% e.g., Vars of interest
%
%   12×1 cell array
% 
%     'Subject'
%     'SALINESEDATION'
%     'REMISEDATION'
%     'ORDER'
%     'MSALINEINTENSITY'
%     'MSALINEUNPL'
%     'MREMIINTENSITY'
%     'MREMIUNPL'
%     'SSALINEINTENSITY'
%     'SSALINEUNPL'
%     'SREMIINTENSITY'
%     'SREMIUNPL'
% 
%   6×1 cell array
% 
%     'Sal vs Remi ResistStrong'
%     'Sal vs Remi AntStrong'
%     'AntLinear Sal'
%     'AntLinear Remi'
%     'ResistStrong vs Weak Sal'
%     'ResistStrong vs Weak Remi'

% Enter the behavioral grouping codes (1, -1) for individual differences in each 
% condition or contrast here.  You can enter them separately for
% conditions/contrasts, or skip this code block and just enter a single
% variable in DAT.BETWEENPERSON.group below, which will be used for all
% conditions and contrasts.
%
% Contrast numbers below refer to the contrasts you entered and named in the prep_1_
% script.  The numbers refer to the rows of the contrast matrix you entered.
%
% Often, you will want to use the same behavioral variable for multiple
% contrasts.  If  you have different between-person covariates for different
% contrasts, e.g., I-C RT for I-C images and ratings or diagnosis for
% emotion contrasts, you can enter different behavioral variables in the
% different cells.  Ditto for conditions.

id = behavioral_data_table.Subject;

Cov = behavioral_data_table.SSALINEINTENSITY - behavioral_data_table.SREMIINTENSITY;
covname = 'Intensity_Saline_vs_Remi';
mytable = table(id);
mytable.(covname) = Cov;

DAT.BETWEENPERSON.contrasts{1} = mytable;

Cov = behavioral_data_table.SSALINEINTENSITY - behavioral_data_table.SREMIINTENSITY;
covname = 'Intensity_Saline_vs_Remi';
mytable = table(id);
mytable.(covname) = Cov;

DAT.BETWEENPERSON.contrasts{2} = mytable;

Cov = behavioral_data_table.SSALINEINTENSITY - behavioral_data_table.MSALINEINTENSITY;
covname = 'Intensity_Str_vs_Mild_Saline';
mytable = table(id);
mytable.(covname) = Cov;

DAT.BETWEENPERSON.contrasts{3} = mytable;

Cov = behavioral_data_table.SREMIINTENSITY - behavioral_data_table.MREMIINTENSITY;
covname = 'Intensity_Str_vs_Mild_Remi';
mytable = table(id);
mytable.(covname) = Cov;

DAT.BETWEENPERSON.contrasts{4} = mytable;

Cov = behavioral_data_table.SSALINEINTENSITY - behavioral_data_table.MSALINEINTENSITY;
covname = 'Intensity_Str_vs_Mild_Saline';
mytable = table(id);
mytable.(covname) = Cov;

DAT.BETWEENPERSON.contrasts{5} = mytable;

Cov = behavioral_data_table.SREMIINTENSITY - behavioral_data_table.MREMIINTENSITY;
covname = 'Intensity_Str_vs_Mild_Remi';
mytable = table(id);
mytable.(covname) = Cov;

DAT.BETWEENPERSON.contrasts{6} = mytable;

% Single group variable, optional, for convenience
% These fields are mandatory, but they can be empty
%
% Make sure:
% - DAT.BETWEENPERSON.group is a numeric vector,  coded 1, -1
% - If you have string inputs, the function string2indicator can help
% transform them to numbers
% - If you have numeric codes that are not 1, -1 then contrast_code can
% help recode them.
%
% Group can be empty.
% -------------------------------------------------------------------------
group = behavioral_data_table.ORDER;
[~, nms, group] = string2indicator(group);

DAT.BETWEENPERSON.group = contrast_code(group  - 1.5);
DAT.BETWEENPERSON.group_descrip = '-1 is first group name, 1 is 2nd';
DAT.BETWEENPERSON.groupnames = nms;
DAT.BETWEENPERSON.groupcolors = {[.7 .3 .5] [.3 .5 .7]};

%% Save if DAT field looks complete

if isfield(DAT, 'SIG_conditions') && isfield(DAT, 'gray_white_csf')
    % Looks complete, save
    
    printhdr('Save results');
    
    savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
    save(savefilename, 'DAT', '-append');
    
else
    printhdr('DAT FIELD DOES NOT LOOK COMPLETE. Are you sure you want to save? Skipping...');
end
