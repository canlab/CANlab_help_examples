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
contrasts_entered = ~isempty(DAT.contrasts);
contrasts_estimated = false;

savefilenamedata = fullfile(resultsdir, 'contrast_data_objects.mat');
if exist(savefilenamedata, 'file')
    
    contrasts_estimated = true;
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
% -------------------------------------------------------------
if contrasts_entered
    
    Within_Ss_Contrasts = DAT.contrastnames';

    Contrast_colors = cat(1, DAT.contrastcolors{:});
    Contrast_colors = Contrast_colors(1:length(Within_Ss_Contrasts), :);
    
    Contrast_weights = DAT.contrasts;
    
        
    if contrasts_estimated
        % Print table with values
        
    N_images = cellfun(Nfun, DATA_OBJ_CON)';
    
    t = cellfun(tfun, DAT.gray_white_csf_contrasts, 'UniformOutput', false)';
    T_Gray_White_CSF = cat(1, t{:});
    
    try
        tabledat = table(Within_Ss_Contrasts, N_images, Contrast_weights, Contrast_colors, T_Gray_White_CSF);
        disp(tabledat);
    catch
        disp('WARNING: TABLE OF CONTRASTS WILL NOT DISPLAY. CHECK SETUP VARIABLES AND SIZES TO FIX.')
        disp('These should have the same number of rows, or you likely have errors in your setup:');
        whos Contrasts N_images Contrast_colors T_Gray_White_CSF
        
    end
    
    else
        % Contrasts entered, not estimated
        disp('Contrasts entered, but not estimated yet.  Run prep_3_calc_univariate_contrast_maps_and_save');
    end
    
    % Print table of contrast values; previous table does not print them
    % well if they are long.
    try
        disp(' ')
        disp('Contrast weights (tab-delimited table)');
        print_matrix(DAT.contrasts, DAT.conditions, DAT.contrastnames, '%d');
        disp(' ')
        
    catch
        disp('Could not print matrix of all contrast values.');
    end
    
    
else
    % no contrasts
    disp('No contrasts entered.');
end

% Between-group contrasts
% -------------------------------------------------------------
Btwn_Group_Contrasts = DAT.between_condition_contrastnames';

Contrast_colors = cat(1, DAT.between_condition_contrastcolors{:});
Contrast_colors = Contrast_colors(1:length(Btwn_Group_Contrasts), :);

Contrast_weights = DAT.between_condition_cons;

try
    tabledat = table(Btwn_Group_Contrasts, Contrast_weights, Contrast_colors);
    disp(tabledat);
catch
    disp('WARNING: TABLE OF CONTRASTS WILL NOT DISPLAY. CHECK SETUP VARIABLES AND SIZES TO FIX.')
    disp('These should have the same number of rows, or you likely have errors in your setup:');
    whos Contrasts N_images Contrast_colors T_Gray_White_CSF
    
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

