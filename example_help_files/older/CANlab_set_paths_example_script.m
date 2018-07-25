% You will need to modify the path names 
% below based on where your files are located. 

% Add CANlab tools
% ----------------------------------------------------------------
cd('/Users/tor/Documents/Code_Repositories')
g = genpath(pwd); addpath(g);

% Add SPM
% ----------------------------------------------------------------
extpath = '/Users/tor/Documents/matlab_code_external/';
spm12dir = fullfile(extpath, 'spm12');

addpath(spm12dir)
addpath(fullfile(spm12dir, 'canonical'))
addpath(fullfile(spm12dir, 'matlabbatch'))
addpath(fullfile(spm12dir, '@nifti'))

% Add other toolboxes
% ----------------------------------------------------------------
% The tools below are written by others, 
% but are used in some of the CANlab code.  

cd(fullfile(extpath, 'matlab_bgl'));    % Graph theory toolbox
g = genpath(pwd); addpath(g);

addpath(fullfile(extpath, 'geom2d'))    % 2-D shape drawing
addpath(fullfile(extpath, 'machine_learning', 'lasso_rocha')) % LASSO regression
addpath(fullfile(extpath, 'spider'))    % Various machine learning

% Remove subversion-related paths we do not need
% ----------------------------------------------------------------
% These are functions in the CANlab Core tools

strip_git_dirs;     % for Github
strip_svn_dirs;     % for Subversion

% save
% ----------------------------------------------------------------

savepath