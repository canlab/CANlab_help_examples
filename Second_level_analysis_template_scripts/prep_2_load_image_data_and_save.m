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
    
    % optional: load full objects
    DATA_OBJ{i} = fmri_data(DAT.imgs{i});
    
    % optional: plot
    if dofullplot
        fprintf('%s\nPlot of images: %s\n%s\n', dashes, DAT.functional_wildcard{i}, dashes);
        disp(DATA_OBJ{i}.fullpath)
        
        plot(DATA_OBJ{i}); drawnow; snapnow
        
        % QUALITY CONTROL METRICS
        [group_metrics individual_metrics gwcsf gwcsfmean] = qc_metrics_second_level(DATA_OBJ{i}); 
        drawnow; snapnow
        
        hist_han = histogram(DATA_OBJ{i}, 'byimage', 'by_tissue_type');
        drawnow; snapnow
        
    end
    
    % derived measures
    
    %DAT.nps_vals(i) = apply_nps(DATA_OBJ{i});
    
    DATA_OBJ{i} = remove_empty(DATA_OBJ{i}); 
    DAT.globalmeans{i} = mean(DATA_OBJ{i}.dat)'; 
    DAT.globalstd{i} = std(DATA_OBJ{i}.dat)';
    
    % scaled measures
    
    %DATA_OBJsc{i} = rescale(DATA_OBJ{i}, 'centerimages'); 
    
    %DAT.nps_vals_centered(i) = apply_nps(DATA_OBJsc{i});
    
    %DATA_OBJz{i} = rescale(DATA_OBJ{i}, 'zscoreimages'); 
    
    %DAT.nps_vals_zscored(i) = apply_nps(DATA_OBJsc{i});
    
    DAT.gray_white_csf{i} = extract_gray_white_csf(DATA_OBJ{i});
        
    % scaled by WM/CSF values -
    % ----------------------------------------------------------------
    %     DATA_OBJwmsc{i} = DATA_OBJ{i}; % old: change from average WM
    %     wmvals = repmat(DAT.gray_white_csf{i}(:, 2)', size(DATA_OBJ{i}.dat, 1), 1);
    %     DATA_OBJwmsc{i}.dat = (DATA_OBJwmsc{i}.dat - wmvals) ./ wmvals;
      
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

DATA_CAT = preprocess(DATA_CAT, 'windsorize');

for i = 1:size(DATA_OBJ, 2), sz(i) = size(DATA_OBJ{i}.dat, 2); end
DATA_CAT.images_per_session = sz;
DATA_CAT.removed_images = 0;

DATA_CAT = preprocess(DATA_CAT, 'remove_csf');
DATA_CAT = preprocess(DATA_CAT, 'rescale_by_csf');

DATA_OBJsc = split(DATA_CAT);

if dofullplot
    disp('AFTER WINDSORIZING AND ADJUSTING FOR WM/CSF');
    
    plot(DATA_CAT); drawnow; snapnow
    
end
    
clear DATA_CAT
    

    %% CSF REMOVAL AND RESCALING
    printhdr('Save results');


savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, 'DAT', 'basedir', 'datadir', 'resultsdir', 'scriptsdir', 'figsavedir');

savefilenamedata = fullfile(resultsdir, 'data_objects.mat');
save(savefilenamedata, 'DATA_OBJ*');

