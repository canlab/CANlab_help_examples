% This script allows us to test within-person contrasts.
% We can include image sets with different
% numbers of images, as occurs with between-person designs, as
% long as the contrast weights are zero for all elements with
% different numbers of images.

% Now set in a2_set_default_options
if ~exist('omit_histograms', 'var')
    a2_set_default_options;
end

% omit_histograms = true;

% Create contrast images
% ------------------------------------------------------------------------
if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end

k = length(DAT.conditions);

% Get sizes
clear sz
for i = 1:k, sz(i, :) = size(DATA_OBJ{i}.dat); end
sz = sz(:, 2);

for i = 1:k
    DATA_OBJ{i} = replace_empty(DATA_OBJ{i});
end


for c = 1:size(DAT.contrasts, 1)
    
    % Initialize : shell object, keep same space/volume info
    wh = find(DAT.contrasts(c, :));
    
    my_size = sz(wh(1));  
    
    % Check sizes and make sure they are the same
    if ~all(sz(wh) == sz(wh(1)))
        fprintf('Not all image set sizes are the same for contrast %3.0f\n', c);
    end
    
    DATA_OBJ_CON{c} = DATA_OBJ{wh(1)};
    [DATA_OBJ_CON{c}.image_names DATA_OBJ_CON{c}.fullpath] = deal([]);
    
    
    DATA_OBJ_CON{c}.dat = zeros(size(DATA_OBJ{wh(1)}.dat));
    
    for i = 1:k
        
        % add data * contrast weight
        condat = DATA_OBJ{i}.dat .* DAT.contrasts(c, i);
        
        if DAT.contrasts(c, i) == 0
            % Skip.  This allows us to include image sets with different
            % numbers of images, as occurs with between-person designs, as
            % long as the contrast weights are zero for all elements with
            % different numbers of images.
            continue
        end
        
        if size(condat, 2) ~= my_size
            fprintf('Condition %3.0f : number of images does not match. Check DATA_OBJ images and contrasts.', i);
            error('exiting.')
        end
        
        DATA_OBJ_CON{c}.dat = DATA_OBJ_CON{c}.dat + DATA_OBJ{i}.dat .* DAT.contrasts(c, i);
        
    end
    
    DATA_OBJ_CON{c} = remove_empty(DATA_OBJ_CON{c});
    DATA_OBJ_CON{c}.image_names = DAT.contrastnames;
    DATA_OBJ_CON{c}.source_notes = DAT.contrastnames;
    
    % Enforce variable types in objects to save space
    DATA_OBJ_CON{c} = enforce_variable_types(DATA_OBJ_CON{c}); 
    
    % QUALITY CONTROL METRICS
    % ------------------------------------------------------------------------
    
    fprintf('%s\nQC plots for contrast: %s\n%s\n', dashes, DAT.contrastnames{c}, dashes);
    
    [group_metrics individual_metrics gwcsf gwcsfmean] = qc_metrics_second_level(DATA_OBJ_CON{c});
    drawnow; snapnow
    
    if ~omit_histograms
        
        figure;
        hist_han = histogram(DATA_OBJ_CON{c}, 'byimage', 'by_tissue_type');
        drawnow; snapnow
        close, close
        
    end
    
end

%% Same, for CSF-adjusted images
% -------------------------------------------------------------------------

for i = 1:k
    DATA_OBJsc{i} = replace_empty(DATA_OBJsc{i});
end

for c = 1:size(DAT.contrasts, 1)

    % Initialize : shell object, keep same space/volume info
    wh = find(DAT.contrasts(c, :));
    
    my_size = sz(wh(1));  
    
    % Check sizes and make sure they are the same
    if ~all(sz(wh) == sz(wh(1)))
        fprintf('Not all image set sizes are the same for contrast %3.0f\n', c);
    end
    
    DATA_OBJ_CONsc{c} = DATA_OBJsc{wh(1)};
    [DATA_OBJ_CONsc{c}.image_names DATA_OBJ_CONsc{c}.fullpath] = deal([]);
    DATA_OBJ_CONsc{c}.dat = zeros(size(DATA_OBJsc{wh(1)}.dat));
    
    
    for i = 1:k
        
        % add data * contrast weight
        condat = DATA_OBJsc{i}.dat .* DAT.contrasts(c, i);
        
        if DAT.contrasts(c, i) == 0
            % Skip.  This allows us to include image sets with different
            % numbers of images, as occurs with between-person designs, as
            % long as the contrast weights are zero for all elements with
            % different numbers of images.
            continue
        end
        
        if size(condat, 2) ~= my_size
            fprintf('Condition %3.0f : number of images does not match. Check DATA_OBJ images and contrasts.', i);
            error('exiting.')
        end
        
        % add data * contrast weight
        DATA_OBJ_CONsc{c}.dat = DATA_OBJ_CONsc{c}.dat + condat;
        
    end
    
    DATA_OBJ_CONsc{c} = remove_empty(DATA_OBJ_CONsc{c});
    DATA_OBJ_CONsc{c}.image_names = DAT.contrastnames;
    DATA_OBJ_CONsc{c}.source_notes = DAT.contrastnames;
    
    % Enforce variable types in objects to save space
    DATA_OBJ_CONsc{c} = enforce_variable_types(DATA_OBJ_CONsc{c}); 
    
    % QUALITY CONTROL METRICS
    % ------------------------------------------------------------------------
    
    fprintf('%s\nQC plots for CSF-scaled data, contrast: %s\n%s\n', dashes, DAT.contrastnames{c}, dashes);
    
    [group_metrics individual_metrics gwcsf gwcsfmean] = qc_metrics_second_level(DATA_OBJ_CONsc{c});
    drawnow; snapnow
    
    if ~omit_histograms
        
        figure
        hist_han = histogram(DATA_OBJ_CONsc{c}, 'byimage', 'by_tissue_type');
        drawnow; snapnow
        close, close
        
    end
    
end

%% Save results
% ------------------------------------------------------------------------

savefilenamedata = fullfile(resultsdir, 'contrast_data_objects.mat');   % both scaled and unscaled
save(savefilenamedata, 'DATA_OBJ_CON*', '-v7.3');                       % Note: 6/7/17 Tor switched to -v7.3 format by default 

% For publish output
disp(basedir)
fprintf('Saved results%sDATA_OBJ_CON\n', filesep);

%% Get contrasts in global gray, white, CSF values
% ------------------------------------------------------------------------

DAT.gray_white_csf_contrasts = {};

for c = 1:size(DAT.contrasts, 1)
    
    wh = find(DAT.contrasts(c, :));
    
    DAT.gray_white_csf_contrasts{c} = zeros(size(DAT.gray_white_csf{wh(1)}));
    
    for i = 1:k
        
        if DAT.contrasts(c, i) == 0
            % Skip.  This allows us to include image sets with different
            % numbers of images, as occurs with between-person designs, as
            % long as the contrast weights are zero for all elements with
            % different numbers of images.
            continue
        end
        
        % add data * contrast weight
        DAT.gray_white_csf_contrasts{c} = DAT.gray_white_csf_contrasts{c} + DAT.gray_white_csf{i} .* DAT.contrasts(c, i);
        
    end
    
end

%% Save results
% ------------------------------------------------------------------------
savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, '-append', 'DAT');
disp('added contrast gray/white/csf to DAT in image_names_and_setup.mat');
