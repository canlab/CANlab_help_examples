% NOTES:
% - standard folders and variable names are created by this script
%
% - extracted fmri_data objects are saved in DATA_OBJ variables
%
%   meta-data saved in image_names_and_setup.mat
%   image data saved in data_objects.mat
%
% - you only need to run the prep_ scripts once.  After that, use 
%   canlab_simple_load_objects.m to re-load saved files
% 
% - when all scripts working properly, run canlab_simple_publish_data_plots.m
%   to create html report. 
%
% - saved in results folder:
%   figures
%   html report with figures and stats, in "published_output"

% Add master scripts dir to path
% --------------------------------------------------------

main_repository_dir = fileparts(fileparts(which('a2_second_level_toolbox_check_dependencies.m')));
[status,result] = system(['find ' main_repository_dir ' -name "' 'canlab_simple_set_paths.m' '"']);
canlab_simple_scripts_dir = fileparts(result);
addpath(canlab_simple_scripts_dir)

% Set base directory
% --------------------------------------------------------

% Base directory for whole study/analysis

basedir = pwd;

% Set up paths
% --------------------------------------------------------

cd(basedir)

datadir = fullfile(basedir, 'data');
resultsdir = fullfile(basedir, 'results');
scriptsdir = fullfile(basedir, 'scripts');
figsavedir = fullfile(resultsdir, 'figures');
notesdir = fullfile(resultsdir, 'notes');

addpath(scriptsdir)

if ~exist(datadir, 'dir'), mkdir(datadir); end
if ~exist(resultsdir, 'dir'), mkdir(resultsdir); end
if ~exist(figsavedir, 'dir'), mkdir(figsavedir); end
if ~exist(scriptsdir, 'dir'), mkdir(scriptsdir); end
if ~exist(notesdir, 'dir'), mkdir(notesdir); end

% You may need this, but now should be in CANlab Private repository
% g = genpath('/Users/tor/Documents/matlab_code_external/spider');
% addpath(g)

% Display helper functions: Called by later scripts
% --------------------------------------------------------

dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);
