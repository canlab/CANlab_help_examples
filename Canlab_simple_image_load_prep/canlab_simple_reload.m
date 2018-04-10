% Go to main project directory before running. Uses current dir as main
% project dir.

% Set paths and directories
canlab_simple_set_paths;

%% Load DAT structure with setup info
% ------------------------------------------------------------------------

savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
load(savefilename, 'DAT')
% For publish output
disp(basedir)
fprintf('Loaded DAT from results%simage_names_and_setup.mat\n', filesep);

%% Load image data objects
% ------------------------------------------------------------------------

savefilenamedata = fullfile(resultsdir, 'data_objects.mat');
load(savefilenamedata, 'DATA_OBJ');

% For publish output
fprintf('Loaded condition data from results%sDATA_OBJ\n', filesep);

savefilenamedata = fullfile(resultsdir, 'data_objects_scaled.mat');
load(savefilenamedata, 'DATA_OBJsc');

% For publish output
fprintf('Loaded condition data from results%sDATA_OBJsc\n', filesep);

%% Print summary of dataset
% ------------------------------------------------------------------------

printhdr('Summary of dataset');

disp('T_Gray_White_CSF reports T-values for whole-brain activation/deactivation in average gray matter, white matter, CSF')
disp(' ')

Nfun = @(obj) size(obj.dat, 2);
tfun = @(x) [nanmean(double(x)) ./ ste(double(x))]; % t-values for shift away from zero
globalfun = @(x) [nanmean(x) ste(x)];

% Conditions

Conditions = DAT.conditions';
N_images = cellfun(Nfun, DATA_OBJ)';
%Condition_colors = cat(1, DAT.colors{:});

t = cellfun(tfun, DAT.gray_white_csf, 'UniformOutput', false)';
T_Gray_White_CSF = cat(1, t{:});

tabledat = table(Conditions, N_images, T_Gray_White_CSF);
disp(tabledat);