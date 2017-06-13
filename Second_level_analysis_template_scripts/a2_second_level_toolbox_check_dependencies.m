[matlabversion, matlabdate] = version;

if datetime(matlabdate) < datetime('01-July-2016')
    disp('Matlab is older than 2016b. Some functions may not work.')
    disp('jsondecode is newer than this version.');
end

% Check paths to toolboxes
% -----------------------------------------------------------------------

disp(' ')
disp('Checking required toolboxes and adding paths with subfolders');
disp(' ')

% -----------------------------------------------------------------------
% CANlab Core toolbox
% -----------------------------------------------------------------------

checkfile = which(['CanlabCore' filesep '@fmri_data' filesep 'fmri_data.m']); 
toolboxdir = fileparts(fileparts(checkfile));

if ~exist(toolboxdir, 'dir')
    
    disp('Cannot find CANlabCore toolbox');
    disp('You need the CANlab CanlabCore Github repository on your path, with subfolders, to run these scripts.')

else
     disp('Found CANlabCore toolbox');
    g = genpath(toolboxdir);
    addpath(g);
end

mainrepodir = fileparts(fileparts(toolboxdir));

% -----------------------------------------------------------------------
% CANlab Second-level analysis scripts
% -----------------------------------------------------------------------

checkfile = which(['Second_level_analysis_template_scripts' filesep '0_begin_here_readme']);
toolboxdir = fileparts(checkfile);

if ~exist(toolboxdir, 'dir')  % Try to find and add it
    toolboxdir = fullfile(mainrepodir, 'CANlab_help_examples', 'Second_level_analysis_template_scripts');
end

if ~exist(toolboxdir, 'dir')
    
    disp('Cannot find second-level analysis scripts');
    disp('You should have the CANlab_help_examples Github repository on your path, with subfolders.')
    disp('Cannot find Second_level_analysis_template_scripts folder with master scripts.');
    
else
    disp('Found second-level analysis scripts');
    g = genpath(toolboxdir);
    addpath(g);
end

% -----------------------------------------------------------------------
% MasksPrivate for signature-based analyes (private repository)
% -----------------------------------------------------------------------

checkfile = which(['Masks_Private' filesep 'apply_all_signatures.m']);
toolboxdir = fileparts(checkfile);

if ~exist(toolboxdir, 'dir')  % Try to find and add it
    toolboxdir = fullfile(mainrepodir, 'Masks_Private');
end

if ~exist(toolboxdir, 'dir')
    
    disp('Cannot find Masks_Private repository');
    
    disp('You need the CANlab Masks_Private Github repository on your path, with subfolders, to run signature extraction.')
    disp('Without this, the prep_4_..m script and signature analysis scripts will not work.' );
    
else
    disp('Found Masks_Private repository');
    g = genpath(toolboxdir);
    addpath(g);
end

try
    disp(' ')
    disp('Attempting to load signatures:');
    
    testset = load_image_set('npsplus');
    disp('Loaded signature images successfully');
    disp(' ')
catch
    disp('Signatures did not load.');
    disp(' ')
end

% -----------------------------------------------------------------------
% Spider toolbox for SVM
% -----------------------------------------------------------------------

spath = which('use_spider.m');
if isempty(spath)
    
    disp('Warning: spider toolbox not found on path; SVM analyses will not run.')
    
else
    disp('Found spider toolbox');
end
   
% -----------------------------------------------------------------------
% Other dependencies
% -----------------------------------------------------------------------

if ~exist('jsondecode', 'builtin')
    disp('jsondecode is a built-in Matlab file that is missing. Json info file reading will not work.');
end

disp('If paths have been updated by running this script, consider running strip_git_dirs and savepath');


