%% HOW TO WRITE FMRI_DATA TO IMAGE FILE ON DISK

% canlabcore fmri data objects can be easily written to standard image file
% formats.  The main function for this is write()

% this walkthrough shows how to do this for 1) a mask image, and 2) a
% statistic image

%% 1) load sample mask
% You will need the Neuroimaging_Pattern_Masks repository installed to find
% these images.

dat = load_image_set('bucknerlab'); % loads 7 masks from Yeo et al.

%% grab one image from those 7

oneimg = dat.get_wh_image(1);

%% write to file
% see help for write() for more options

fname = 'dummy.nii';  % outname file name.  the extension (.nii, .img) determines the format.

write(oneimg, 'fname', fname);  

%% read back in and view to check its correct

orthviews(fmri_data(fname))


%% 2) load sample statistical image

dat = load_image_set('kragelemotion'); % loads 7 masks from Kragel et al.

% grab one image from those 7
oneimg = dat.get_wh_image(1);

%% threshold at an arbitrary threshold.  This will create a statistic_image

% keep values less than -.0005 or greater than .0005
si = threshold(oneimg, [-.0005 .0005], 'raw-outside'); 

% check that it looks fine
orthviews(si); 

%% write to file

fname = 'dummy.nii';  % outname file name.  the extension (.nii, .img) determines the format.

write(si, 'fname', fname, 'thresh') % will write the *thresholded* image

%% read back in and view to check its correct
orthviews(fmri_data(fname))
