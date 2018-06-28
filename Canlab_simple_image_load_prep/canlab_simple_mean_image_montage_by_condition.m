function o2 = canlab_simple_mean_image_montage_by_condition(DATA_OBJ, image_set_names)
% o2 = canlab_simple_mean_image_montage_by_condition(DATA_OBJ, image_set_names)
%
% DATA_OBJ = cell array of fmri_data objects
% image_set_names = cell array of names for each image set (e.g., DAT.conditions)
%
% e.g.
% canlab_simple_mean_image_montage_by_condition(DATA_OBJ, DAT.conditions)

k = length(DATA_OBJ);

o2 = canlab_results_fmridisplay([], 'multirow', k);

for i = 1:k
    
    wh_montage_start = i * 2 - 1;
    o2 = addblobs(o2, region(mean(DATA_OBJ{i})), 'wh_montage', wh_montage_start:wh_montage_start+1);
    
    myhan = o2.montage{wh_montage_start + 1}.axis_handles(5);
    title(myhan, image_set_names{i});
    
end


end % function