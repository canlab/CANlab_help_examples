behavioral_data_filename = 'Physical_Behavioural_Outcomes_short.xlsx';
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
% fMRIWeight_Mean         % Pressure, in kg/cm^2MAYBE
% fMRIWeightVAS_Mean      % VAS ratings pressure, 0-10??
% fMRItemp_Mean           % temperature - Degrees C below baseline?
% fMRItempVAS_Mean        % VAS ratings, cold pain
% GenderID                % Sex, Fem = 2???

id = behavioral_data_table.ImageID;

between_subject_design = table(id);

between_subject_design.pressure = behavioral_data_table.fMRIWeight_Mean;
between_subject_design.pressurepain = behavioral_data_table.fMRIWeightVAS_Mean;

between_subject_design.coldtemp = behavioral_data_table.fMRItemp_Mean;
between_subject_design.coldpain = behavioral_data_table.fMRItempVAS_Mean;

between_subject_design.patientvscontrol = contrast_code(scale(behavioral_data_table.Patient1_Control0, 1));

between_subject_design.femalevsmale = contrast_code(scale(behavioral_data_table.GenderID, 1));   % Fem = 1, Male = -1

DAT.BETWEENPERSON.between_subject_design = between_subject_design;

% Single group variable, optional, for convenience
% These fields are mandatory, but they can be empty
% -------------------------------------------------------------------------
DAT.BETWEENPERSON.group = between_subject_design.patientvscontrol;
DAT.BETWEENPERSON.groupnames = {'Patients' 'Controls'};
DAT.BETWEENPERSON.groupcolors = {[.7 .3 .5] [.3 .5 .7]};
