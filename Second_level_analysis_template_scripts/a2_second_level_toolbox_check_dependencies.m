% Check and set up paths to toolboxes
%
% Example of what you will need on your matlab path:
% -----------------------------------------------------------------------
% cd('/Users/tor/Documents/code_repositories/spm12')
% addpath(pwd);
% 
% cd('/Users/tor/Documents/code_repositories/CanlabCore')
% g = genpath(pwd); addpath(pwd);
% 
% cd('/Users/tor/Documents/code_repositories/CANlab_help_examples')
% g = genpath(pwd); addpath(pwd);
% 
% cd('/Users/tor/Documents/code_repositories/MasksPrivate')
% g = genpath(pwd); addpath(pwd);
% 
% cd('/Users/tor/Google Drive/CanlabDataRepository/ROI_masks_and_parcellations/Parcellation_images_for_studies')
% g = genpath(pwd); addpath(pwd);

dashes = '-------------------------------------------------------------';
fprintf('\n%s\nChecking for toolboxes and functions needed\n%s\n', dashes, dashes);

[matlabversion, matlabdate] = version;

if datetime(matlabdate) < datetime('01-July-2016')
    
    disp('Matlab is older than 2016b. Some functions may not work.')
    disp('Known issues:')
    disp('- Some scripts use function definitions within them, introduced in 2016b')
    disp('- jsondecode is newer than this version.');
    
end

% Check paths to toolboxes
% -----------------------------------------------------------------------

disp(' ')
disp('Checking required toolboxes and adding paths with subfolders');
disp(' - SPM12');
disp(' - CanlabCore object-oriented tools');
disp(' - Canlab Second_level_analysis_template_scripts');
disp(' - Canlab Masks_Private for NPS pain signature');
disp(' - Neuroimaging_Pattern_Masks for other signatures and atlases/parcellations');
disp(' ')

% -----------------------------------------------------------------------
% SPM
% -----------------------------------------------------------------------

checkfile = which(['spm12' filesep 'spm.m']); 
toolboxdir = fileparts(fileparts(checkfile));

if ~exist(toolboxdir, 'dir')
    
    disp('Cannot find SPM12 toolbox');
    disp('You need SPM5/8/12 on your Matlab path')

else
    disp('Found SPM12 toolbox');
    % do not add everything
    %g = genpath(toolboxdir);
    %addpath(g);
end

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

checkfile = which(['Masks_Private' filesep 'apply_nps.m']);
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
    disp('Signatures did not load. Signatures are in the Neuroimaging_Pattern_Masks repository and MasksPrivate repository');
    disp(' ')
end


% -----------------------------------------------------------------------
% Atlases for parcel extraction
% -----------------------------------------------------------------------

checkfile = which(['Neuroimaging_Pattern_Masks' filesep 'Atlases_and_parcellations' filesep '2013_Shen_Constable_NIMG_268_parcellation' filesep 'Shen_atlas_object.mat']);
toolboxdir = fileparts(fileparts(fileparts(checkfile)));

if ~exist(toolboxdir, 'dir')
    
    disp('Cannot find parcellation .nii files');
    disp('You should have the ROI_masks_and_parcellations/Parcellation_images_for_studies folder on your path, with subfolders.')
    disp('These are in the Neuroimaging_Pattern_Masks repository and have .nii/.img files for parcellations shared by multiple groups');
    disp(' ');
    
else
    disp('Found parcellation image files.');
    g = genpath(toolboxdir);
    addpath(g);
end

atlas_name = which('shen_2mm_268_parcellation.nii');
parcellation_name = 'Shen';

if ~exist(atlas_name, 'file')
    error('Add parcellation atlas to your Matlab path.');
end


disp(' ')
disp('Checking other functions we need:');
disp(' - Spider machine learning toolbox for SVM');
disp(' - Matlab internal jsondecode tools');
disp(' ')

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

strip_git_dirs

% disp('If paths have been updated by running this script, consider running strip_git_dirs and savepath');


