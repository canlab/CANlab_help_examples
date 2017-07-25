
parcellation_name = 'Shen';

%atlas_name = which('shen_2mm_268_parcellation.nii');


%% LOAD PARCELLATION FILE

savefilenamedata = fullfile(resultsdir, ['Parcellation_data_' parcellation_name '.mat']);

load(savefilenamedata, parcellation_name);
printhdr(sprintf('Loaded parcels: %s', parcellation_name));

% Store in parcel_struct variable and clear the named var, so code below is
% generic to any parcellation
eval(['parcel_struct = ' parcellation_name ';']);
eval(['clear ' parcellation_name]);

%% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
whmontage = 5; 
plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage, or creates o2 fmridisplay object


%% DISPLAY PARCELS

r = region(parcel_struct.parcel_obj, 'unique_mask_values');

[all_colors, leftmatched, rightmatched, midline, leftunmatched, rightunmatched] = match_colors_left_right(r, @(n) custom_colors([1 0 .5], [.5 0 1], length(r)));

o2 = removeblobs(o2);

for i = 1:length(r)
    
o2 = addblobs(o2, r(i), 'color', all_colors{i});

end

drawnow
