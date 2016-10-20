% Load DAT structure with setup info
% ------------------------------------------------------------------------

savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
load(savefilename, 'DAT')
% For publish output
disp(basedir)
fprintf('Loaded DAT from results%simage_names_and_setup.mat\n', filesep);

% Load image data objects
% ------------------------------------------------------------------------

savefilenamedata = fullfile(resultsdir, 'data_objects.mat');
load(savefilenamedata, 'DATA_OBJ*');

% For publish output
fprintf('Loaded condition data from results%sDATA_OBJ\n', filesep);

% Load contrast data objects if they exist
% ------------------------------------------------------------------------

savefilenamedata = fullfile(resultsdir, 'contrast_data_objects.mat');
if exist(savefilenamedata, 'file')
    
    load(savefilenamedata, 'DATA_OBJ_CON*');
    
    % For publish output
    fprintf('Loaded contrast images from results%sDATA_OBJ_CON\n', filesep);
    
else
    disp('No contrast data objects to load.');
end


%% Correlations with some global values (diagnostic of some potential issues)

rnames = {'Mean' 'STD' 'Gray' 'White' 'CSF'};

for i = 1:length(DAT.globalmeans)
    
    fprintf('\n%s  Global metrics\n', DAT.conditions{i});
 
    selected_vars = [DAT.globalmeans{i} DAT.globalstd{i} DAT.gray_white_csf{i}];

r = corr(selected_vars);

print_matrix(r, rnames, rnames);

end

% could 'whiten', rescale by some proportion of STD...

% Regress global CSF on global gray matter
% Gray = b*CSF + e
% Gray_resid = Gray - CSF * b * CSF


