% load brain
%  get filenames
%  load data
%  apply NPS
% --------------------------------------------------------

dofullplot = 1;

clear imgs cimgs
for i = 1:length(DAT.conditions)
    
    %% CONDITION
    
    printhdr(sprintf('Raw data, condition %3.0f, %s', i, DAT.conditions{i}));
    
    % This will vary based on your naming conventions
    % This version assumes that FOLDERS have names of CONDITIONS and images
    % are in each folder
    
    if ~isempty(DAT.subfolders) && ~isempty(DAT.subfolders{1})  % if we have subfolders
        
        str = fullfile(datadir, DAT.subfolders{i}, DAT.functional_wildcard{i});
        
        % Unzip if needed
        try eval(['!gunzip ' str '.gz']), catch, end
        
        disp(['Loading: ' str])
        cimgs{i} = filenames(str, 'absolute');
        
    else
        
        str = fullfile(datadir, DAT.functional_wildcard{i});
        
        % Unzip if needed
        try eval(['!gunzip ' str '.gz']), catch, end
        
        cimgs{i} = filenames(str, 'absolute');
        
    end
    
    %  CHECK that files exist
    if isempty(cimgs{i}), fprintf('Looking in: %s\n', str), error('CANNOT FIND IMAGES. Check path names and wildcards.'); end
    cimgs{i} = cellfun(@check_valid_imagename, cimgs{i}, repmat({1}, size(cimgs{i}, 1), 1), 'UniformOutput', false);
    
    DAT.imgs{i} = char(cimgs{i}{:});
    
    % Load full objects
    % -------------------------------------------------------------------
    % If images are less than 2 mm res, sample in native space:
    %DATA_OBJ{i} = fmri_data(DAT.imgs{i});
    
    % If images are very large/high-res, you may want to sample to the mask space instead:
    DATA_OBJ{i} = fmri_data(DAT.imgs{i}, which('brainmask.nii'), 'sample2mask');
    
    % QUALITY CONTROL METRICS
    printstr('QC metrics');
    printstr(dashes);
    
    [group_metrics individual_metrics values gwcsf gwcsfmean gwcsfl2norm] = qc_metrics_second_level(DATA_OBJ{i});
    
    DAT.gray_white_csf{i} = values;
    drawnow; snapnow
    
    % optional: plot
    % -------------------------------------------------------------------
    
    if dofullplot
        fprintf('%s\nPlot of images: %s\n%s\n', dashes, DAT.functional_wildcard{i}, dashes);
        disp(DATA_OBJ{i}.fullpath)
        
        plot(DATA_OBJ{i}); drawnow; snapnow
        
        hist_han = histogram(DATA_OBJ{i}, 'byimage', 'by_tissue_type');
        drawnow; snapnow
        
    end
    
    % derived measures
    
    DATA_OBJ{i} = remove_empty(DATA_OBJ{i});
    DAT.globalmeans{i} = mean(DATA_OBJ{i}.dat)';
    DAT.globalstd{i} = std(DATA_OBJ{i}.dat)';
    
    drawnow, snapnow
end

%% CSF REMOVAL AND RESCALING
printhdr('CSF REMOVAL AND RESCALING');

% scaling by CSF values
% ----------------------------------------------------------------
% Note: Do not train cross-validated models on these scaled objects because
% they perform operations using group information to transform individual
% image values.

DATA_CAT = cat(DATA_OBJ{:});

clear sz

for i = 1:size(DATA_OBJ, 2), sz(1, i) = size(DATA_OBJ{i}.dat, 2); end
DATA_CAT.images_per_session = sz;
DATA_CAT.removed_images = 0;

%DATA_CAT = preprocess(DATA_CAT, 'remove_csf');
%DATA_CAT = preprocess(DATA_CAT, 'rescale_by_csf');
%DATA_CAT = preprocess(DATA_CAT, 'divide_by_csf_l2norm');

DATA_CAT = rescale(DATA_CAT, 'l2norm_images');     % scaling sensitive to mean and variance.

DATA_CAT = preprocess(DATA_CAT, 'windsorize'); % entire data matrix

DATA_OBJsc = split(DATA_CAT);

if dofullplot
    disp('AFTER WINDSORIZING AND RESCALING BY L2NORM'); %'ADJUSTING FOR WM/CSF');
    
    plot(DATA_CAT); drawnow; snapnow
    
end

clear DATA_CAT


%% SAVE

printhdr('Save results');

savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, 'DAT', 'basedir', 'datadir', 'resultsdir', 'scriptsdir', 'figsavedir');

savefilenamedata = fullfile(resultsdir, 'data_objects.mat');
save(savefilenamedata, 'DATA_OBJ');

savefilenamedata = fullfile(resultsdir, 'data_objects_scaled.mat');
save(savefilenamedata, 'DATA_OBJsc');
