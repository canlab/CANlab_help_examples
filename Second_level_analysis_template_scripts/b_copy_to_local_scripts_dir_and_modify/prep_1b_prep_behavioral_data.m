%% About this script
%
% Optional: Run these load and attach behavioral data from files (e.g., from Excel)            
%
% This script is an example script only.  You should modify it to fit your
% needs, which will depend on which types of behavioral/non-imaging data
% you have and what variables you want to store and analyze. The basics are
% desribed here:
%
% - Store behavioral data tables in any ad hoc format in DAT.BEHAVIOR.
% This can be a useful reference if you want to change/add custom analyses
% relating brain to behavior. You can create custom scripts that pull data 
% from .BEHAVIOR and use it in analyses.
%
% - Store a between-person grouping variable (e.g., patient vs. control,
% etc.) in DAT.BETWEENPERSON.group. This should be coded with values of 1
% and -1. Also add fields (see below) for names and colors associated with
% each group, and a description of what the 1/-1 codes mean.
% Some analyses consider this variable and run between-group contrasts
% and/or control for them in analyses of the entire sample (e.g.,
% "signature response" analyses).  
% SVM analyses can also be run that use the .group variable. See:
% prep_3d_run_SVM_betweenperson_contrasts and 
% c2b_SVM_betweenperson_contrasts  
%
% - If you have no binary group variable,  it is OK to leave the .group
% field empty. 
%
% - If you have continuous variable(s) instead of a binary group variable,
% you can enter a continuous variable in .group (for now!) -- this script
% uses that continuous variable:  (it may cause problems with other scripts
% that assume binary .group data, and may be changed in future versions):
% prep_3a_run_second_level_regression_and_save
%
% - Instead of a single .group variable to be tested with all
% conditions/contrasts, you can also enter different variables for each
% condition and/or contrast.  This is useful if you want to correlate each
% contrast with a different behavioral variable (maybe, e.g., for each contrast,
% reaction time differences for the same contrast). 
% If so, enter DAT.BETWEENPERSON.conditions and/or
% DAT.BETWEENPERSON.contrasts.  These should be cell arrays with one cell
% per condition or contrast.  Each cell contains a matlab "table" object
% with the data and possibly subject IDs (see below).
% 
% - You can run this script as part of a workflow (prep_1...
% prep_2...prep_3 etc)
% You can also run the script AFTER you've prepped all the imaging data, just
% to add behavioral data to the existing DAT structure.  If so, make sure
% you RELOAD the existing DAT structure with b_reload_saved_matfiles.m
% before you run this script.  Otherwise, if you create a new DAT
% structure, important information saved during the data prep (prep_2...,
% prep_3...) process will be missing, and you will need to re-run the whole
% prep sequence.

%% READ behavioral data from file. These data will be put into standard structure compatible with analyses

<<<EDIT A COPY OF THIS IN YOUR LOCAL SCRIPTS DIRECTORY AND DELETE THIS LINE>>>

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

%% Check DAT, print warnings, save DAT structure

if ~isfield(DAT, 'conditions') 
    printhdr('Incomplete DAT structure');
    disp('The DAT field is incomplete. Run prep_1_set_conditions_contrasts_colors before running prep_1b...')
end
    
if isfield(DAT, 'SIG_conditions') && isfield(DAT, 'gray_white_csf')
    % Looks complete, we already have data, no warnings 
else
    printhdr('DAT structure ready for data prep');
    disp('DAT field does not have info from prep_2, prep_3, or prep_4 sequences');
    disp('prep_2/3/4 scripts should be run before generating results.');
end

printhdr('Save results');

savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, 'DAT', '-append');

