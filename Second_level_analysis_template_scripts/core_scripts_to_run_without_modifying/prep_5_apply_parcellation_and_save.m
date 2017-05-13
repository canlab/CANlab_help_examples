% THIS SCRIPT extracts region averages and local pattern expression in each
% parcel of the Shen 2013 atlas
%
% - extracts local parcel means and all local pattern expression for all signatures. 
% - Preps file Parcellation_data.mat saved in "results" folder.  
% - Allow us to compare local pattern expression across parcels and compare 
%   local patterns within parcels.

% Get parcels
% --------------------------------------------------------------------
tic
disp('Loading parcels');

atlas_name = which('shen_2mm_268_parcellation.nii');

if ~exist(atlas_name, 'file')
    error('Add parcellation atlas to your Matlab path.');
end

parcel_obj = fmri_data(atlas_name);

PARCELS.Shen = [];
PARCELS.Shen.parcel_obj = parcel_obj;
PARCELS.Shen.regions = region(parcel_obj, 'unique_mask_values');

toc

%% Get mean activation for each parcel
% --------------------------------------------------------------------
tic
printhdr('Extracting parcel mean values');

PARCELS.Shen.conditions = DAT.conditions;

k = length(DAT.conditions);

for i = 1:k
    
    % Extract mean values
    
    parcel_means = apply_parcellation(DATA_OBJ{i}, parcel_obj);
    
    PARCELS.Shen.means.dat{i} = parcel_means;
    
    % Do a t-test on each parcel
    [h, p, ci, stat] = ttest(double(parcel_means));
    
    PARCELS.Shen.means.group_t{i} = stat.tstat;
    PARCELS.Shen.means.group_p{i} = p;
    
end

% FDR-correct across all conditions and parcels

all_p = cat(2, PARCELS.Shen.means.group_p{:});
PARCELS.Shen.means.fdr_p_thresh = FDR(all_p, .05);

for i = 1:k
    
    PARCELS.Shen.means.fdr_sig{i} = PARCELS.Shen.means.group_p{i} < PARCELS.Shen.means.fdr_p_thresh;
    
end

toc

%% Get pattern response for each parcel
% --------------------------------------------------------------------

tic
printhdr('Extracting parcel local signature patterns');

[signature_obj, signames] = load_image_set('npsplus');

for mysig = 1:length(signames)
    
    sig_obj = get_wh_image(signature_obj, mysig);
    
    signame = signames{mysig};
    signame = strrep(signame, '-', '_');
    signame = strrep(signame, ' ', '_');
    
    printstr(signame)
    
    for i = 1:k
        
        % Extract mean values
        
        local_pattern = apply_parcellation(DATA_OBJ{i}, parcel_obj, 'pattern_expression', nps);
        
        PARCELS.Shen.(signame).dat{i} = local_pattern;
        
        % Do a t-test on each parcel
        [h, p, ci, stat] = ttest(double(local_pattern));
        
        PARCELS.Shen.(signame).group_t{i} = stat.tstat;
        PARCELS.Shen.(signame).group_p{i} = p;
        
    end
    
    % FDR-correct across all conditions and parcels
    
    all_p = cat(2, PARCELS.Shen.(signame).group_p{:});
    PARCELS.Shen.(signame).fdr_p_thresh = FDR(all_p, .05);
    
    for i = 1:k
        
        PARCELS.Shen.(signame).fdr_sig{i} = PARCELS.Shen.(signame).group_p{i} < PARCELS.Shen.(signame).fdr_p_thresh;
        
    end
    
    toc
    
end  % signature

%% Format into statistic_image objects for display, etc.
% ADD these to PARCEL structure
%
% display with, e.g., orthviews(PARCELS.Shen.(signame).t_statistic_obj{3})

%parcel_obj = PARCELS.Shen.parcel_obj;

printhdr('Reconstructing parcel-wise t-statistic objects');

for mysig = 1:length(signames)
    
    signame = signames{mysig};
    signame = strrep(signame, '-', '_');
    signame = strrep(signame, ' ', '_');
    
    printstr(signame)
    
    PARCELS.Shen.(signame) = plugin_get_parcelwise_statistic_images(parcel_obj, PARCELS.Shen.(signame) );
    
end




%% Save

savefilenamedata = fullfile(resultsdir, 'Parcellation_data.mat');
save(savefilenamedata, 'PARCELS');
printhdr('Saved parcels');
