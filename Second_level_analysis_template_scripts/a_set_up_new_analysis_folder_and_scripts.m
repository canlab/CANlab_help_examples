% This script sets up directory structure for new second-level analysis and
% copies in scripts from master 2nd-level script dir.

% Some scripts should be copied in and modified.  Others can be run
% directly from the master scripts folder.

% Go to your new analysis folder and run this from within it.
% Note: type a_set_up<tab key> from command line. Do not drag and drop from
% master folder (or it will set up scripts in master folder)

% -----------------------------------------------------------------------
% Check for master scripts and get dir
% -----------------------------------------------------------------------

masterscriptdir = fileparts(which('Second_level_analysis_template_scripts/0_begin_here_readme'));

if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
end

% -----------------------------------------------------------------------
% Make folder structure
% -----------------------------------------------------------------------

basedir = pwd;

datadir = fullfile(basedir, 'data');
resultsdir = fullfile(basedir, 'results');
scriptsdir = fullfile(basedir, 'scripts');
figsavedir = fullfile(resultsdir, 'figures');

addpath(scriptsdir)

if ~exist(datadir, 'dir'), mkdir(datadir); end
if ~exist(resultsdir, 'dir'), mkdir(resultsdir); end
if ~exist(scriptsdir, 'dir'), mkdir(scriptsdir); end
if ~exist(figsavedir, 'dir'), mkdir(figsavedir); end

% -----------------------------------------------------------------------
% Copy scripts in
% -----------------------------------------------------------------------

checkfile = fullfile(scriptsdir, 'a_set_up_paths_always_run_first');
if exist(checkfile, 'file')
    
    error('Scripts already exist in destination scripts folder. Delete if you want to re-copy from master.');
    
end

% Copy template scripts
% -----------------------------------------------------------------------
sourcedir = fullfile(masterscriptdir, 'b_copy_to_local_scripts_dir_and_modify', '*');
[SUCCESS,MESSAGE,MESSAGEID] = copyfile(sourcedir, scriptsdir);

% sourcedir = fullfile(masterscriptdir, 'c_copy_to_local_scripts_dir_run_without_modifying', '*');
% [SUCCESS,MESSAGE,MESSAGEID] = copyfile(sourcedir, scriptsdir);


checkfile = fullfile(basedir, 'study_info.json');
if exist(checkfile, 'file')
    
    disp('study_info.json file already exists. Skipping copy-in.');
    
else
    
    sourcedir = fullfile(masterscriptdir, 'a_copy_to_main_study_folder_and_modify', 'study_info.json');
    [SUCCESS,MESSAGE,MESSAGEID] = copyfile(sourcedir, basedir);
    
end

dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);

printhdr('Done setting up new analysis folder');
