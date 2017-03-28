behavioral_data_filename = 'sedation_scores_for_tor.xlsx';
behavioral_fname_path = fullfile(datadir, behavioral_data_filename);

if ~exist(behavioral_fname_path, 'file'), fprintf(1, 'CANNOT FIND FILE: %s\n',behavioral_fname_path); end

behavioral_data_table = readtable(behavioral_fname_path,'FileType','spreadsheet');




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

% Save everything
DAT.BETWEENPERSON.behavioral_data_table = behavioral_data_table;

DAT.BETWEENPERSON.conditions = cell(1, length(DAT.conditions));
[DAT.BETWEENPERSON.conditions{:}] = deal(table());  % empty tables

DAT.BETWEENPERSON.contrasts = cell(1, length(DAT.contrastnames));
[DAT.BETWEENPERSON.contrasts{:}] = deal(table());  % empty tables



%% CUSTOM CODE: TRANSFORM INTO between_design_table
%
% Create a table for each condition/contrast with the between-person design, or leave empty.
%
% a variable called 'id' contains subject identfiers.  Other variables will
% be used as regressors.  Variables with only two levels should be effects
% coded, with [1 -1] values.

% Vars of interest
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
% -------------------------------------------------------------------------
group = behavioral_data_table.ORDER;
[~, nms, group] = string2indicator(group);

DAT.BETWEENPERSON.group = contrast_code(group  - 1.5);
DAT.BETWEENPERSON.group_descrip = '-1 is first group name, 1 is 2nd';
DAT.BETWEENPERSON.groupnames = nms;
DAT.BETWEENPERSON.groupcolors = {[.7 .3 .5] [.3 .5 .7]};
