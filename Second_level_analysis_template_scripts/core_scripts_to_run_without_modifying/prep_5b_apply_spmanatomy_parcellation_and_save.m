% THIS SCRIPT extracts region averages and local pattern expression in each
% parcel of the Spm Anatomy v22c atlas
%
% - extracts local parcel means and all local pattern expression for all signatures. 
% - Preps file Parcellation_data.mat saved in "results" folder.  
% - Allow us to compare local pattern expression across parcels and compare 
%   local patterns within parcels.
%
% Saves variable named whatever the var "parcellation_name" is set to
% - Need to break files up into one file per parcellation due to memory space 
%


% Get parcels
% --------------------------------------------------------------------
tic
disp('Loading parcels');

atlas_name = which('Anatomy_v22c.nii');
parcellation_name = 'SpmAnat';

if ~exist(atlas_name, 'file')
    error('Add parcellation atlas to your Matlab path.');
end

% SPM anatomy toolbox has some regions without names,  junk parcels.
% This script loads the regions and names for the good ones.
[spm_anatomy_regions, region_names_cell] = canlab_load_spmanatomy_regions; % - NOTE: Need to "undo" origin correction in SPM anatomy toolbox to match the standard SPM MNI template **
parcel_obj = region2fmri_data(spm_anatomy_regions, fmri_data(atlas_name));

%parcel_obj = fmri_data(atlas_name);

% Space-saving
parcel_obj = enforce_variable_types(parcel_obj);

PARCELS.(parcellation_name) = [];
PARCELS.(parcellation_name).parcel_obj = parcel_obj;

% Omit this to save space
% PARCELS.(parcellation_name).regions = region(parcel_obj, 'unique_mask_values');
% 
% % add names
% for i = 1:length(region_names_cell)
%     
%     PARCELS.(parcellation_name).regions(i).shorttitle = region_names_cell{i};
%     
% end

PARCELS.(parcellation_name).parcel_names = region_names_cell;

toc

%% Get mean activation for each parcel
% --------------------------------------------------------------------
tic
printhdr('Extracting parcel mean values');

PARCELS.(parcellation_name).conditions = DAT.conditions;

k = length(DAT.conditions);

for i = 1:k
    
    % Extract mean values
    
    parcel_means = apply_parcellation(DATA_OBJ{i}, parcel_obj);
    
    PARCELS.(parcellation_name).means.dat{i} = parcel_means;
    
    % Do a t-test on each parcel
    [h, p, ci, stat] = ttest(double(parcel_means));
    
    PARCELS.(parcellation_name).means.group_t{i} = stat.tstat;
    PARCELS.(parcellation_name).means.group_p{i} = p;
    
end

% FDR-correct across all conditions and parcels

all_p = cat(2, PARCELS.(parcellation_name).means.group_p{:});
PARCELS.(parcellation_name).means.fdr_p_thresh = FDR(all_p, .05);

for i = 1:k
    
    PARCELS.(parcellation_name).means.fdr_sig{i} = PARCELS.(parcellation_name).means.group_p{i} < PARCELS.(parcellation_name).means.fdr_p_thresh;
    
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
        
        local_pattern = apply_parcellation(DATA_OBJ{i}, parcel_obj, 'pattern_expression', sig_obj);
        
        PARCELS.(parcellation_name).(signame).dat{i} = local_pattern;
        
        % Do a t-test on each parcel
        [h, p, ci, stat] = ttest(double(local_pattern));
        
        PARCELS.(parcellation_name).(signame).group_t{i} = stat.tstat;
        PARCELS.(parcellation_name).(signame).group_p{i} = p;
        
    end
    
    % FDR-correct across all conditions and parcels
    
    all_p = cat(2, PARCELS.(parcellation_name).(signame).group_p{:});
    PARCELS.(parcellation_name).(signame).fdr_p_thresh = FDR(all_p, .05);
    
    for i = 1:k
        
        PARCELS.(parcellation_name).(signame).fdr_sig{i} = PARCELS.(parcellation_name).(signame).group_p{i} < PARCELS.(parcellation_name).(signame).fdr_p_thresh;
        
    end
    
    toc
    
end  % signature

%% Format into statistic_image objects for display, etc.
% ADD these to PARCEL structure
%
% display with, e.g., orthviews(PARCELS.(parcellation_name).(signame).t_statistic_obj{3})

%parcel_obj = PARCELS.(parcellation_name).parcel_obj;

printhdr('Reconstructing parcel-wise t-statistic objects');

for mysig = 1:length(signames)
    
    signame = signames{mysig};
    signame = strrep(signame, '-', '_');
    signame = strrep(signame, ' ', '_');
    
    printstr(signame)
    
    PARCELS.(parcellation_name).(signame) = plugin_get_parcelwise_statistic_images(parcel_obj, PARCELS.(parcellation_name).(signame) );
    
end

%% Save

str = [parcellation_name ' = PARCELS.(parcellation_name);'];
eval(str)

savefilenamedata = fullfile(resultsdir, ['Parcellation_data_' parcellation_name '.mat']);

save(savefilenamedata, parcellation_name, '-v7.3');
printhdr(sprintf('Saved parcels: %s', parcellation_name));

