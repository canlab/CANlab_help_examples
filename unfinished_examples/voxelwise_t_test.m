[image_obj, networknames, imagenames] = load_image_set('emotionreg');
imagenames
t = ttest(image_obj);
orthviews(t)
t = threshold(t, .05, 'fdr');
orthviews(t)
montage(t)
create_figure('montage'); montage(t)

