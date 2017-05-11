%% Load and display JSON file with study info, if we have it

plugin_display_study_info_json;

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

%% Load contrast data objects if they exist
% ------------------------------------------------------------------------

savefilenamedata = fullfile(resultsdir, 'contrast_data_objects.mat');
if exist(savefilenamedata, 'file')
    
    load(savefilenamedata, 'DATA_OBJ_CON*');
    
    % For publish output
    fprintf('Loaded contrast images from results%sDATA_OBJ_CON\n', filesep);
    
else
    disp('No contrast data objects to load.');
end

%% Report on conditions and contrasts

printhdr('Summary of dataset');

disp('T_Gray_White_CSF reports T-values for whole-brain activation/deactivation in average gray matter, white matter, CSF')
disp(' ')

Nfun = @(obj) size(obj.dat, 2);
tfun = @(x) [nanmean(double(x)) ./ ste(double(x))]; % t-values for shift away from zero
globalfun = @(x) [nanmean(x) ste(x)];

% Conditions

Conditions = DAT.conditions';
N_images = cellfun(Nfun, DATA_OBJ)';
Condition_colors = cat(1, DAT.colors{:});

t = cellfun(tfun, DAT.gray_white_csf, 'UniformOutput', false)';
T_Gray_White_CSF = cat(1, t{:});

tabledat = table(Conditions, N_images, Condition_colors, T_Gray_White_CSF);
disp(tabledat);

% Contrasts
Contrasts = DAT.contrastnames';

N_images = cellfun(Nfun, DATA_OBJ_CON)';

t = cellfun(tfun, DAT.gray_white_csf_contrasts, 'UniformOutput', false)';
T_Gray_White_CSF = cat(1, t{:});

Contrast_colors = cat(1, DAT.contrastcolors{:});
Contrast_colors = Contrast_colors(1:length(Contrasts), :);

try
    tabledat = table(Contrasts, N_images, Contrast_colors, T_Gray_White_CSF);
    disp(tabledat);
catch
    disp('WARNING: TABLE OF CONTRASTS WILL NOT DISPLAY. CHECK SETUP VARIABLES AND SIZES TO FIX.')
end

printstr(dashes)


% %% Correlations with some global values (diagnostic of some potential issues)
% 
% rnames = {'Mean' 'STD' 'Gray' 'White' 'CSF'};
% 
% disp('Mean: Mean condition image correlations with mean whole-brain Gray, White, CSF signal');
% disp('STD: Std. deviation across condition image correlations with mean whole-brain Gray, White, CSF signal');
% 
% for i = 1:length(DAT.globalmeans)
%     
%     fprintf('\n%s  Global metrics\n', DAT.conditions{i});
%     
%     selected_vars = [DAT.globalmeans{i} DAT.globalstd{i} DAT.gray_white_csf{i}];
%     
%     r = corr(selected_vars);
%     
%     print_matrix(r, rnames, rnames);
%     
% end
% 

