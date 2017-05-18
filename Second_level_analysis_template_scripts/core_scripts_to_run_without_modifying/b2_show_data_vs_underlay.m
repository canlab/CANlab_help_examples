
% Create compact overlay and add gray/CSF and mean data

figtitle = 'slices showing coverage';
create_figure(figtitle);
axis off

o2 = canlab_results_fmridisplay([], 'multirow', 2);

o2 = addblobs(o2, region(fmri_data(which('gray_matter_mask_sparse.img'))), 'outline', 'color', 'r', 'wh_montage', [1:2]);
o2 = addblobs(o2, region(fmri_data(which('canonical_ventricles.img'))), 'outline', 'color', 'g', 'wh_montage', [1:2]);

o2 = addblobs(o2, region(mean(DATA_OBJ{1})), 'trans', 'wh_montage', [3:4]);

% Add titles
wh_axis = 6;
axes(o2.montage{2}.axis_handles(wh_axis));
title('Red = gray matter, green = CSF space');

axes(o2.montage{4}.axis_handles(wh_axis));
title('Image coverage: Mean of first condition');


plugin_save_figure

close % to save memory, etc., as we are printing figs
clear o2

