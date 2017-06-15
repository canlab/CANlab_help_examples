% load brain
%  get filenames
%  load data
%  apply NPS
% --------------------------------------------------------

% Now set in a2_set_default_options
if ~exist('dofullplot', 'var') || ~exist('omit_histograms', 'var') || ~exist('dozipimages', 'var')
    a2_set_default_options;
end

% dofullplot = true;
% omit_histograms = true;
% dozipimages = false;

clear imgs cimgs

%% Prep and check image names
% -------------------------------------------------------------------

for i = 1:length(DAT.conditions)
    
    % printhdr(sprintf('Raw data, condition %3.0f, %s', i, DAT.conditions{i}));
    
    % This will vary based on your naming conventions
    % This version assumes that FOLDERS have names of CONDITIONS and images
    % are in each folder
    
    if ~isempty(DAT.subfolders) && ~isempty(DAT.subfolders{1})  % if we have subfolders
        
        str = fullfile(datadir, DAT.subfolders{i}, DAT.functional_wildcard{i});
        
        % Unzip if needed - note, Matlab's gunzip() does not remove .gz images, so use eval( ) version.
        try eval(['!gunzip ' str '.gz']), catch, end     % gunzip([str '.gz'])
        
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
    
    filename_string{i} = str;  % used below for zipping images
end


%% Load full objects
% -------------------------------------------------------------------

% Determine whether we want to sample to the mask (2 x 2 x 2 mm) or native
% space, whichever is more space-efficient

test_image = fmri_data(deblank(DAT.imgs{1}(1, :)), 'noverbose');
voxelsize = diag(test_image.volInfo.mat(1:3, 1:3))';
if prod(abs(voxelsize)) < 8
    sample_type_string = 'sample2mask'; 
    disp('Loading images into canonical mask space (2 x 2 x 2 mm)');
else
    sample_type_string = 'native_image_space'; 
    fprintf('Loading images in native space (%3.2f x %3.2f x %3.2f mm)\n', voxelsize);

end

for i = 1:length(DAT.conditions)
    
    printhdr(sprintf('Loading images: condition %3.0f, %s', i, DAT.conditions{i}));
    
    % If images are less than 2 mm res, sample in native space:
    %DATA_OBJ{i} = fmri_data(DAT.imgs{i});
    
    % If images are very large/high-res, you may want to sample to the mask space instead:
    DATA_OBJ{i} = fmri_data(DAT.imgs{i}, which('brainmask.nii'), sample_type_string, 'noverbose');
    
    % make sure we are using right variable types (space-saving)
    % this is new and could be a source of errors - beta testing!
    DATA_OBJ{i} = enforce_variable_types(DATA_OBJ{i});
     
    if dozipimages
        % zip original files to save space (we are done using them now).
        try eval(['!gzip ' filename_string{i}]), catch, end
    end
    
    % QUALITY CONTROL METRICS
    % -------------------------------------------------------------------

    printstr('QC metrics');
    printstr(dashes);
    
    [group_metrics individual_metrics values gwcsf gwcsfmean gwcsfl2norm] = qc_metrics_second_level(DATA_OBJ{i});
    
    DAT.quality_metrics_by_condition{i} = group_metrics;
    
    disp('Saving quality control metrics in DAT.quality_metrics_by_condition');
    disp('Saving gray, white, CSF means in DAT.gray_white_csf');
    
    DAT.gray_white_csf{i} = values;
    drawnow; snapnow
    
    % optional: plot
    % -------------------------------------------------------------------
    
    if dofullplot
        fprintf('%s\nPlot of images: %s\n%s\n', dashes, DAT.functional_wildcard{i}, dashes);
        disp(DATA_OBJ{i}.fullpath)
        
        plot(DATA_OBJ{i}); drawnow; snapnow
        
        if ~omit_histograms
            
            hist_han = histogram(DATA_OBJ{i}, 'byimage', 'by_tissue_type');
            drawnow; snapnow
            
        end
        
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

% Enforce variable types in objects to save space
for i = 1:length(DATA_OBJsc), DATA_OBJsc{i} = enforce_variable_types(DATA_OBJsc{i}); end

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
save(savefilenamedata, 'DATA_OBJ', '-v7.3');                 % Note: 6/7/17 Tor switched to -v7.3 format by default

savefilenamedata = fullfile(resultsdir, 'data_objects_scaled.mat');
save(savefilenamedata, 'DATA_OBJsc', '-v7.3');
