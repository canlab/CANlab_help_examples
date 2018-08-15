
%% load an atlas
% 'atlas' objects are a class of objects specially designed for brain
% atlases. Here is more information on this class (also try >> doc atlas)

help atlas

% The function load_atlas in the CANlab toolbox loads a number of named
% atlases included with the toolbox.  Here is a list of named atlases:

help load_atlas

% Now load the "CANlab combined 2018" atlas:
atlas_obj = load_atlas('canlab2018_2mm');


%% visualize the atlas regions

orthviews(atlas_obj);

o2 = montage(atlas_obj);

%% select regions of interest

% Select all regions with "Thal" in the label:
thal = select_atlas_subset(atlas_obj, {'Thal'})

% Print the labels:
thal.labels

% Select a few thalamus/epithalamus regions of interest:
thal = select_atlas_subset(atlas_obj, {'Thal_Intra', 'Thal_VL', 'Thal_MD', 'Thal_LGN', 'Thal_MGN', 'Thal_Hb'});
thal.labels

% Select all the regions with "Thal" in the label, and collapse them into a single region:
whole_thal = select_atlas_subset(atlas_obj, {'Thal'}, 'flatten');

%% load a dataset to extract data from for an ROI analysis
% The dataset contains data from 33 participants, with brain responses to six levels
% of heat (non-painful and painful).  
% 
% Aspects of this data appear in these papers:
% Wager, T.D., Atlas, L.T., Lindquist, M.A., Roy, M., Choong-Wan, W., Kross, E. (2013). 
% An fMRI-Based Neurologic Signature of Physical Pain. The New England Journal of Medicine. 368:1388-1397
% (Study 2)
%
% Woo, C. -W., Roy, M., Buhle, J. T. & Wager, T. D. (2015). Distinct brain systems 
% mediate the effects of nociceptive input and self-regulation on pain. PLOS Biology. 13(1): 
% e1002036. doi:10.1371/journal.pbio.1002036
%
% Lindquist, Martin A., Anjali Krishnan, Marina López-Solà, Marieke Jepma, Choong-Wan Woo, 
% Leonie Koban, Mathieu Roy, et al. 2015. ?Group-Regularized Individual Prediction: 
% Theory and Application to Pain.? NeuroImage. 
% http://www.sciencedirect.com/science/article/pii/S1053811915009982.
%
% This dataset is shared on figshare.com, under this link:
% https://figshare.com/s/ca23e5974a310c44ca93
%
% Here is a direct link to the dataset file with the fmri_data object:
% https://ndownloader.figshare.com/files/12708989
%
% The key variable is image_obj
% This is an fmri_data object from the CANlab Core Tools repository for neuroimaging data analysis.
% See https://canlab.github.io/
%
% image_obj.dat contains brain data for each image (average across trials)
% image_obj.Y contains pain ratings (one average rating per image)
%
% image_obj.additional_info.subject_id contains integers coding for which
% Load the data file, downloading from figshare if needed
%
% Alternative sample datasets:
% --------------------------------------------
% This dataset will take time to download from figshare if you haven't yet
% downloaded it. An alternative is to use the dataset included with the
% CANlab Core toolbox (though the results are less interesting for this
% example).
% image_obj = load_image_set('emotionreg');
%
% A second example is a CANlab pain dataset shared on Neurovault. Try this
% to load it:
% [files_on_disk, url_on_neurovault, mycollection, myimages] = retrieve_neurovault_collection(504);
% image_obj = fmri_data(files_on_disk);


fmri_data_file = which('bmrk3_6levels_pain_dataset.mat');

if isempty(fmri_data_file)
    
    % attempt to download
    disp('Did not find data locally...downloading data file from figshare.com')
    
    fmri_data_file = websave('bmrk3_6levels_pain_dataset.mat', 'https://ndownloader.figshare.com/files/12708989');
    
end

load(fmri_data_file);

descriptives(image_obj);


%% extract data from each atlas region
% - "r" is a region-class object. see >> help region
% - r(i).dat contains averages over voxels within region i. for n images, it contains an n x 1 vector with average data.
% - r(i).data contains an images x voxels matrix of all data within region i.

r = extract_roi_averages(image_obj, thal);

% r = extract_roi_averages(data_obj, whole_thal);


%% Do a group ROI analysis and make a "violin plot" (or barplot) for each region

roi_averages = cat(2, r.dat);

create_figure('Thalamus regions', 1, 2);

barplot_columns(roi_averages, 'nofig', 'colors', scn_standard_colors(length(r)), 'names', thal.labels, 'noind');
xlabel('Region')
ylabel('ROI activity')

subplot(1, 2, 2)

barplot_columns(roi_averages, 'nofig', 'colors', scn_standard_colors(length(r)), 'names', thal.labels, 'noind', 'noviolin');
xlabel('Region')
ylabel('ROI activity')

% The sensory/nociceptive regions of the thalamus (VL and intralaminar) respond to painful
% stimuli, but not the regions (LGN, MGN) visual/auditory pathways. The
% habenula also responds.







