%% About this script
%
% This script is an example script only.  You should modify it to fit your
% needs, which will depend on which types of behavioral/non-imaging data
% you have and what variables you want to store and analyze.
% 
% This script is an alternate example version from
% prep_1b_prep_behavioral_data.m.  See that script for more instructions.

<<<EDIT A COPY OF THIS IN YOUR LOCAL SCRIPTS DIRECTORY AND DELETE THIS LINE>>>

%% INITIALIZE GROUP VARIABLE

% Initialize empty variables
DAT.BETWEENPERSON = [];

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

% Vars of interest
%
% AN_ for anorexic, HC_ for healthy control

for i = 1:length(DAT.conditions)
    
    
    str_to_match = 'AN_';
    matching_rows = ~cellfun(@isempty, strfind(cellstr(DATA_OBJ{1}.fullpath), str_to_match));
    
    str_to_match = 'HC_';
    matching_rows2 = ~cellfun(@isempty, strfind(cellstr(DATA_OBJ{1}.fullpath), str_to_match));
    
    group = matching_rows - matching_rows2;  % AN - HC
    
    DAT.BETWEENPERSON.conditions{i}.group = group;
    
    % assign contrast weights too
    % this code may change from study to study
    % some group vectors entered twice here, but that's ok
    whcon = DAT.contrasts(:, i) > 0;
    
    if any(whcon)
        DAT.BETWEENPERSON.contrasts{whcon}.group = group;
    end
    
end

DAT.BETWEENPERSON.groupnames = {'Anorexic' 'Control'};
DAT.BETWEENPERSON.groupcolors = {[.8 .3 .3] [.3 .5 .8]};



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

