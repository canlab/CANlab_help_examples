
% Create compact overlay and add gray/CSF and mean data

figtitle = 'slices showing coverage';
create_figure(figtitle);
axis off

o2 = canlab_results_fmridisplay([], 'multirow', 2);

o2 = addblobs(o2, region(fmri_data(which('gray_matter_mask_sparse.img'))), 'outline', 'color', 'r', 'wh_montage', [1:2]);
o2 = addblobs(o2, region(fmri_data(which('canonical_ventricles.img'))), 'outline', 'color', 'g', 'wh_montage', [1:2]);

o2 = addblobs(o2, region(mean(DATA_OBJ{1})), 'trans', 'wh_montage', [3:4]);

savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

drawnow, snapnow

clear o2

