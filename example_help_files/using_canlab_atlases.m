%% Using_CANLab2023_atlases
% This script demonstrates some of the features of canlab atlases using
% CANLab2023 as an example atlas. CANLab2023 is the most featureful atlas
% at this point and provides a comprehensive account of how to use features
% found with other atlases as well as an illustration of the intent behind
% the various atlas method properites.
% by Bogdan Petre, 2024

%% Overview
% This tutorial provides a summary of the various features packaged with
% a canlab atlas object using canlab2023 as an example. A number of
% examples use the orthview() function and are meant to be interactive, so
% run the necessary segments of this code yourself to explore the plots.
%
% If you are only interested in using canlab2023, and don't care to work
% through the tutorial, here's a brief summary.
%
% CANLab2023 comes in multiple flavors depending on the space, sampling
% resolution and parcellation granularity of interest. These flavors are 
% specified by various suffixes when invoking load_atlas(). For instance,
% load_atlas('canlab2023_coarse_fmriprep20_2mm') has three suffixes that
% specify the particular flavor to load. For a list of options to specify 
% refer to the help docs for load_atlas(). There are several defaults 
% which will be used if none are specified (i.e. if you invoke 
% load_atlas('canlab2023'). They are,
%
% SPACE = MNI152NLin2009cAsym (fmriprep's default as of version 20.3.2 LTS)
%
% Resolution = 2mm
%
% Granularity = coarse
%
% I (BP) believe this is likely to be the most useful and popular version
% of this atlas, so if in doubt use the defaults.
%
% The difference between coarse and fine granularity is mainly a difference
% in subcortical structures. The fine level of granularity is useful as a
% brain map (i.e. something you use to figure out where you are), while 
% the coarse level of granularity is more useful for generating regions of 
% interest for further analysis. The difference comes from the fact that 
% generating ROIs for analysis requires employing a winner-takes-all scheme 
% for parcel labels while in a brain mapping application probablistic 
% labels can be evaluated directly. All regions have probablistic labels*
% The latter can accomodate between subject differences more effectively. 
% For instance, you can't easily distinguish the median raphe (very small) 
% from the paramedian nucleus (surrounds median raphe) in a new subject 
% based on this atlas. That would require accounting for millimeter scale
% intersubject anatomical variability of the brainstem, which is currently 
% beyond the level of what we can trust spatial normalization to reference 
% templates to achieve. While you can't define a median raphe ROI to 
% extract timeseries from a sample of subjects, you can pinpoint an 
% activation focus in the vicinity of median raphe and assign a probability 
% is that it would be median raphe. That is in fact what these probablistic
% labels represent: the likelihood that given some gold standard
% delineation of a region that it would fall within a specified voxel for a
% particular subject given intersubject-variability in the reference
% template space.
%
% There is additional information about these structures in the labels_2,
% labels_3, labels_4, and (for fine atlases) labels_5 fields. You can
% downsample atlas into one of the other labels spaces if desired. See
% "downsampling an atlas" below. The label_descriptions fields have also
% been populated for your convenience.
% 
% Due to licensing restrictions the atlas is generated dynamically when
% invoked and cached locally for reuse. A hash file tracks updates and will
% recompile the atlas as needed. Something to be aware of if it takes some
% time to load the first time around.
%
% Additional usage information is also available in the atlas README.md
% file available here:
% https://github.com/canlab/Neuroimaging_Pattern_Masks/blob/master/Atlases_and_parcellations/2023_CANLab_atlas/README.md
%
% *Note that the Morel (thalamic) and Shen (brainstem) atlases used here
% did not have probabilities associated with them. They were assigned
% probabilities arbitrarily so that they would play better with their
% neighbors. Do not treat them the same as the other probabilities.

%% General instructions
% To run this demo you will need the latest version of CanlabCore and
% Neuroimaging_Pattern_Masks. Make sure you also have spm12 which is a
% dependency of CanlabCore. Finally, due to some licensing restritcions you
% will also need access to an internet connection and write permissions to
% the Neuroimaging_Pattern_Masks directory. Whlie these licensing
% restrictions prevent us from distributing some parts of our atlases
% directly via our own repositories, they do not prevent us from 
% downloading atlas components at runtime. Consequently, there are several 
% scripts in our repos that automate the downloading and assembling of the
% necessary files. You just need internet and write access to the right
% locations to make this possible.

LIB = '/home/bogdan/.matlab';
addpath(genpath([LIB, '/canlab/CanlabCore']));
addpath(genpath([LIB, '/canlab/Neuroimaging_Pattern_Masks']));
addpath([LIB, '/spm/spm12']);


%% Section 1: Loading an atlas
% Load Canlab2023. CANLab2023 is not distributed with our repos because it
% includes regions from Bianciardi's "brainstem navigaton" atlas that we
% are not allowed to distributed. Instead, we assemble CANLab2023 the first
% time you invoke load_atlas('canlab2023') or equivalent (there are 
% multiple versions of this atlas and each requires initial assembly). To
% speed up this process we distribute a version of canlab2023 without the
% license restricted regions, a 'scaffold', to which these regions are
% added. The process should go relativey quickly but varies depending on
% whether or not resampling voxels or downsampling the parcellation is
% required for the version of canlab2023 you request.
%
% If you have not yet downloaded the Bianciardi atlas this command will
% also automatically download that for you. You must agree to Bianciardi's
% usage license, and you will be prompted to do so.

canlab2023_fine_fmriprep20_1mm = load_atlas('canlab2023_fine_1mm');

%% Section 2: visualizing an atlas
%
% The above atlas was loaded with default choices on the template space 
% resolution and parcellation (more on these later). 
% 
% It is straightforward to display, but as a probablistic atlas the 
% default display will include voxels with very low probability of
% belonging to a particular parcel, so let's threshold it before display
% 
% Note: the montage() method is very slow. It will be painful if rendered
% without GPU support. Enable this by invoking 'opengl HARDWARE FULL'. You
% may need to restart matlab. If you don't have the necessary hardware,
% consider substituting orthviews() for montage('full') in everything that 
% follows. Montage invoked with different arguments should produce more
% minimalist plots here and can be run regardless.

canlab2023_fine_fmriprep20_1mm_thr = canlab2023_fine_fmriprep20_1mm.threshold(0.2).remove_empty();
canlab2023_fine_fmriprep20_1mm_thr.montage('full hcp');

%%

% notice how the plotting is both slow (even with hardware acceleration) 
% and regions slightly overlap around their margins. This is related to the
% internal logic of how the montage function is called, namely addblobs()
% is called for each ROI individually. A better and more accurate way to 
% map an atlas is to treat all contiguous regions of the atlas as blobs and
% use the atlas parcel values (i.e. those in the *.dat object property) as
% indices into a colormap. Let's try that to compare. Notice how we need +1
% indices relative to the number of regions in the atlas. This is to
% account for unlabeled areas.

% you could also use cmap=colormap('lines') for matlab native color schemes
cmap_cells = scn_standard_colors(1+num_regions(canlab2023_fine_fmriprep20_1mm_thr));
cmap = cat(1,cmap_cells{:});

o2 = canlab_results_fmridisplay('full hcp');
canlab2023_fine_fmriprep20_1mm_thr.montage(o2, 'indexmap', cmap, 'interp', 'nearest');

%%
% the most expedient way to plot of all is using the orthviews() function
% though
close all;
canlab2023_fine_fmriprep20_1mm.threshold(0.2).orthviews();

%%
% You can identify the location of a region at the crosshairs to interogate
% a label
subset = canlab2023_fine_fmriprep20_1mm.select_regions_near_crosshairs();
subset.orthviews();

%%
% or for a cleaner picture you can try thresholding the image
subset.threshold(0.2).orthviews();

%%
% subregions of the atlas can be selected individually and there are
% multiple ways to do this. The most basic involves selecting a single
% region
close all;
canlab2023_fine_fmriprep20_1mm.select_atlas_subset({'PAG'}).orthviews;

%%
% importantly this shows the entire region anywhere p(PAG) > 0, not the
% area where where p(PAG) > p(other regions). There's not a clean way to do
% this, but one way to quickly plot where PAG is the most probable region
% is by erasing the probability_maps field before extraction and plotting:
canlab2023_fine_fmriprep20_1mm_abr = canlab2023_fine_fmriprep20_1mm;
canlab2023_fine_fmriprep20_1mm_abr.probability_maps = [];
canlab2023_fine_fmriprep20_1mm_abr.select_atlas_subset({'PAG'}).orthviews;

%% Downsampling an atlas
% this atlas has multiple labels fields: labels, labels_2, labels_3,
% labels_4 and labels_5. All entries in labels should be unique since 
% indices correspond to values in the *.dat properties, but subsequent
% labels are not constrained in any way. Ideally they will be nested within
% labels, i.e. f(labels_x) = labels_y is surjective for x<y. This allows
% for the downsample_parcelation method to be used to merge fine grained
% parcellations into coarser parcellations. For instance. The following
% converts the canlab2023 fine scale atlas into the canlab2023 coarse scale
% atlas.

canlab2023_coarse_fmriprep20_1mm = canlab2023_fine_fmriprep20_1mm.downsample_parcellation();
canlab2023_coarse_fmriprep20_1mm_thr = canlab2023_coarse_fmriprep20_1mm.threshold(0.2);

o2 = canlab_results_fmridisplay('full hcp');
canlab2023_coarse_fmriprep20_1mm_thr.montage(o2, 'indexmap', cmap, 'interp', 'nearest');

%%
% This process takes some time because there are many regions in both
% labels and labels_2. It runs faster when downsampling more aggressively
% (e.g. labels_3...5). For convenience the coarse (labels_2) version of this
% atlas is provided under a unique keyword that can be loaded with
% load_atlas. It is generated by downsampling, like in the above
% invocation, the first time it's run, but is also cached to your
% Neuroimaging_Pattern_Masks directory to expedite subsequent invocations
% of load_atlas for the coarse atlas.
% 
% You can check the equivalence by loading the coarse atlas explicitly and 
% comparing. Ignore the comments about the qsiprep atlas that are printed
% during the assembly. They are not relevant to this tutorial

t0 = tic;
canlab2023_coarse_fmriprep20_1mm_b = load_atlas('canlab2023_coarse_fmriprep20_1mm');
t1 = toc(t0);
fprintf('Runtime: %0.2fs\n', t1);

%%
canlab2023_coarse_fmriprep20_1mm_thr_b = canlab2023_coarse_fmriprep20_1mm_b.threshold(0.2);

o2 = canlab_results_fmridisplay('full hcp');
canlab2023_coarse_fmriprep20_1mm_thr_b.montage(o2, 'indexmap', cmap, 'interp', 'nearest');

%%
% if you have not previously loaded this coarse atlases you can check the
% speedup by invoking the command again. For the sake of this tutorial I
% preemptively deleted the atlas befpore running the above so we can
% compare.
t0 = tic;
canlab2023_coarse_fmriprep20_1mm_b = load_atlas('canlab2023_coarse_fmriprep20_1mm');
t1 = toc(t0);
fprintf('Runtime: %0.2fs\n', t1);

%%
% once cached the atlas is only rebuilt if a hashfile detects that there's
% been a change to the atlas. While the compiled atlas cannot be
% distributed, the hash file can and serves as a method of detecting the
% existence of an updated atlas. Anytime someone invokes the creation
% script the hash function for the new atlas is computed and saved to a
% file that's uploaded to github. That way when you pull an update you may
% not get the new atlas but you will get the new hash file and the new
% build scripts, so that way when you next invoke load_atlas it detects the
% update is available based on the mismatch between the hash file and your 
% existing atlas and recompiles the atlas from its source files.
% 
% During highly iterative development cycles you may find yourself 
% recompiling the atlas frequently. Resist the temptation to save a
% separate copy, since it will not be under version control and it will
% likely result in your use of an outdated and buggy atlas down the road.

%%
% Notice if you look at the original and downsampled atlas side by side
% how the labels fields have changed. Every label in the original atlas was
% downsampled and shifted down an integer so that labels_5 became labels_4,
% labels_3 become labels_2 etc. The original labels are lost, meaning
% downsampling is a lossy operation.

%%
% original atlas
disp(canlab2023_fine_fmriprep20_1mm);

%%
% downsampled atlas
disp(canlab2023_coarse_fmriprep20_1mm);

%%
% So far we've downsampled based on the atlas objects properties, but it is
% also possible to specify a categorical vector of labels to use for
% downsampling. For instance, we can adapt the network parcels from
% canlab2018 and apply them to canlab2023 by expoiting the naming
% conventions that are shared for their cortical labels.

canlab2018 = load_atlas('canlab2018');
nets = canlab2018.labels_2;
labels = canlab2023_fine_fmriprep20_1mm.labels;

% iter over canlab2023 labels and find the corresponding network label fro
% canlab2018f
sorted_nets = cell(1,length(labels));
for i = 1:length(labels)
    if contains(labels{i},'Ctx')
        sorted_nets{i} = nets{strcmp(canlab2018.labels,labels{i})};
    else
        sorted_nets{i} = 'subctx';
    end
end

nets = canlab2023_fine_fmriprep20_1mm.downsample_parcellation(sorted_nets);
nets.threshold(0.2).orthviews

%% CANLab2023 labels* fields
% in general labels_X should be a downsampled version of labels_Y but what
% each label represents will vary by atlas. The label fields of the
% CANLab2023 atlas in particular may be worth looking at individually
% though since it may see more general and frequent use than other atlases.

% CANLab2023 is a meta-atalas that combines pracels from multiple other 
% atlases. These atlases are all cited in the *.references field


disp(canlab2023_coarse_fmriprep20_1mm.references);

%%
% if you want to see what region atlas a parcel is associated with check
% the labels_5 field. For example,


disp(canlab2023_fine_fmriprep20_1mm.select_atlas_subset({'PAG'}).labels_5);

%%
% In the case of the coarse atlases the labels indices are decremented by 1
% so you check labels_4 instead,


disp(canlab2023_coarse_fmriprep20_1mm.select_atlas_subset({'PAG'}).labels_4);

%%
% You can rapidly get an overview of the constituent atlases by
% downsampling to the labes_5 field and plotting the resulting parcels.
% Notice how in this case I downsample the atlas by specifying a specific
% labels_y field to downsample to. This is necessary to override the
% default behavior which is to just use labels_2.


atlas_src = canlab2023_fine_fmriprep20_1mm.downsample_parcellation('labels_5');

o2 = canlab_results_fmridisplay('full hcp');
atlas_src.montage(o2, 'indexmap', cmap, 'interp', 'nearest');

%%
% there are two more levels of parcel groupings: labels_3 and labels_4.
% Labels_4 contains glasser et al's coarse parcellation, roughly
% corresponding to the color scheme used in their atlas plots. For
% non-cortical regions the parcellation is somewhat arbitrary but is
% lateralized where sensible (e.g. left and right cerebellular lobules but
% a bilateral vermis) and largely groups subcortical structures according
% to classic gross subdivisions


canlab2023_glasser_metaparcels = canlab2023_fine_fmriprep20_1mm.downsample_parcellation('labels_4');

o2 = canlab_results_fmridisplay('full hcp');
canlab2023_glasser_metaparcels.montage(o2, 'indexmap', cmap, 'interp', 'nearest');

%%
% labels_3 is the least rigorously defined. The idea here was simply to
% have something in between labels_4 and labels_2 that would be
% particularly helpful in cases where the glasser cortical parcellation
% were too granular or where some additional level of parcel
% characterization might be helpful. For instance, the insula is divided
% into putatively granular, dysgranulra and agranular regions. For plotting
% purposes we only select the left hemisphere by looking for labels
% suffixed with '_L'


canlab2023_l3 = canlab2023_fine_fmriprep20_1mm.downsample_parcellation('labels_3');
canlab2023_l3_thr = canlab2023_l3.threshold(0.2);

o2 = canlab_results_fmridisplay('full hcp');
canlab2023_l3_thr.montage(o2, 'indexmap', cmap, 'interp', 'nearest');


%%
% note how labels_3 has become labels_2 after downsampling

canlab2023_insula = canlab2023_l3.select_atlas_subset('insula','labels_2');
canlab2023_insula_L = canlab2023_insula.select_atlas_subset({'_L'});

canlab2023_insula_L.threshold(0.2).montage('regioncenters','saggital');

%%
% Let's also plot them all on the same slice so we can see how they fit
% together more clearly. To do this we will create a mask of the regions,
% find its center, and then replicate some of the code that's run
% internally when invoking montage('regioncenters') to obtain a
% slice-by-slice layout. The main changes I made were to using the 
% indexmap plots of a single region as opposed to invoking addblobs on 
% multiple regions separately. 
% 
% I don't personally understand much of the montage plotting syntax but 
% have found this kind of reverse engineering and trial and error to be an 
% effective (albeit slow) way of producing plots of interest.

rIns = atlas2region(canlab2023_insula.threshold(0.2).select_atlas_subset({'_L'},'flatten'));
mm_center = rIns.mm_center; % offset slightly to better capture agranular insula

o2 = fmridisplay('overlay',which('fmriprep20_template.nii'));
[~, axh] = create_figure('fmridisplay_regioncenters', 1, 3, false, true); 
o2 = montage(o2,'saggital','wh_slice', mm_center, 'onerow', 'existing_axes', axh(1), 'existing_figure');
o2 = montage(o2,'coronal','wh_slice', mm_center, 'onerow', 'existing_axes', axh(2), 'existing_figure');
o2 = montage(o2,'axial','wh_slice', mm_center, 'onerow', 'existing_axes', axh(3), 'existing_figure');
colors = scn_standard_colors(1+num_regions(canlab2023_insula_L));
colors = cat(1,colors{:});
addblobs(o2, canlab2023_insula_L.threshold(0.2), 'indexmap', colors, 'interp', 'nearest');

%%
% Notice that if the parcel names in whatever label field you're working
% with are too obscure for you to understand you can also gain insight into
% their identity by inspecting associated higher order label fields. The
% label_descriptions{} property has also been populated and may provide
% useful information to help orient you.

%% Atlas spaces and resolutions
% Atlases are defined in particular spaces. This information is stored in
% the space_description property of an atlas object and available spaces
% (when known) are indicated in the load_atlas() help. For instance,
% canlab2023 is availble in MNI152NLin6Asym (fsl v6) space or
% MNI152NLin2009cAsym (fmriprep v20.2.3) spaces.

% Thus far we've used the fmriprep20 version but we can request the fsl6
% version instead like so. Notice the explicit specification of an
% 'overlay' (really an underlay)

canlab2023_fsl6 = load_atlas('canlab2023_fine_fsl6_1mm');

o2 = canlab_results_fmridisplay('full hcp','overlay',which('fsl6_hcp_template.nii'));
canlab2023_fsl6.montage(o2, 'indexmap', cmap, 'interp', 'nearest');

%%
% We can compare some parcels from this atlas and the fmriprep20 version by
% overlaying blob outlines instead of patches. Let's use V1 as an example plotting
% the fsl space parcel in green and the fmriprep space parcel in red. We
% don't need to bother with the indexmap here because we're only plotting a
% single region, so we use the default addblobs plots for simplicity.

v1_fsl = canlab2023_fsl6.select_atlas_subset({'Ctx_V1_L'}).threshold(0.2);
v1_fmriprep = canlab2023_fine_fmriprep20_1mm.select_atlas_subset({'Ctx_V1_L'}).threshold(0.2);

mm_center = atlas2region(v1_fmriprep).mm_center;

o2 = fmridisplay('overlay',which('fmriprep20_template.nii'));
[~, axh] = create_figure('fmridisplay_regioncenters', 1, 3, false, true); 
o2 = montage(o2,'saggital','wh_slice', mm_center, 'onerow', 'existing_axes', axh(1), 'existing_figure');
o2 = montage(o2,'coronal','wh_slice', mm_center, 'onerow', 'existing_axes', axh(2), 'existing_figure');
o2 = montage(o2,'axial','wh_slice', mm_center, 'onerow', 'existing_axes', axh(3), 'existing_figure');
colors = scn_standard_colors(2);
addblobs(o2,v1_fmriprep,'color',colors{1},'outline');
addblobs(o2,v1_fsl,'color',colors{2},'outline');

%%
% The difference is small. Using the wrong atlas is unlikely to lead to any 
% major problems with your conclusions but it can lead to all sorts of 
% coding headaches. For instance, sampling 'nan' values outside of your 
% data's mask which then break scripts that expect numerical values, or 
% overlapping parcels when combining regions from different atlases, etc.
% Problems become especially accute when working with atlases that have
% small regions, like brainstem nuclei.

%%
% In addition to template space considerations you should also consider
% your sampling resolution, and several atlases provide the option of one
% or more sampling resolutions. For instance, CANLab2023 has a 1mm and 2mm
% version. These are selected using the 1mm or 2mm suffix (see load_atlas
% help for details) when invoking load_atlas. For instance, here is the 2mm
% canlab2023 fmriprep atlas

canlab2023_fine_fmriprep20_2mm = load_atlas('canlab2023_fine_fmriprep20_2mm');

%%
% you may notice that this is not identical to the 1mm version. In
% particular some regions don't exist here.
labels_1mm = canlab2023_fine_fmriprep20_1mm.labels;
labels_2mm = canlab2023_fine_fmriprep20_2mm.labels;
missing = labels_1mm(~contains(labels_1mm,labels_2mm));
disp(missing)

canlab2023_fine_fmriprep20_1mm.select_atlas_subset(missing).orthviews();

%%
% The thalamic region MV_L is 1mm thick and cannot be represented 
% accurately at the 2mm resolution. Instead it's subsummed by its 
% neighboring parcel. For consistency the MV_R parcel has also been removed
% and had its voxels assigned to its neighbor. This is unusual though. It 
% is more common for resampling error to distort, shrink, or translate data 
% in inaccurate ways that can be managed if handled with care. The 2mm 
% versions of atlases available in our repos have been created specifically 
% with an eye for such care by performing transformations and resampling
% in a single step to minimize the number of interpolations used. A similar
% procedure is used for transforming most brain imaging data from native
% space to template space too, so this follows the field's best practices.

% You can find more details on template spaces in the README.md file here:
% https://github.com/canlab/Neuroimaging_Pattern_Masks/tree/master/templates

%% Parcel probabilities
% Parcel probabilities indicate the likelihood that a a voxel would be
% assigned a particular label. Strictly speaking they represent the
% frequency with which a particlar labelwas asigned to a voxel the original 
% study which produced the atlas, and as a result the precision is only as
% good as the sample size in that study and the biases of that study. These
% will vary from one study to the next, but as long as you interpret the
% probabilities loosely they can still be helpful. 
% 
% For instance, for regions that are distinguished histologically, you may 
% not be able to perform histology yourself but you can use probabilities 
% from the histological sample used to produce say the hippocampal atlas, to 
% infer how likely an activation focus is to belong to any of several 
% neighboring regions. It bears remembering though that those probabilities
% were estimated in an elderly person's brain (because that's usually who
% donates their bodies to these studies) and so may be somewhat biased when
% used to infer structure labels in say an undergraduate student.
%
% There are two structures here which do not have probablistic labels: the
% thalamus and the shen brainstem regions (large patches, not the nuclei
% which are from Bianciardi's brianstem atlas). The shen parcels are
% basically just fillers, so it's not an issue. They've been gien
% probabilistic values that will cede identities to other atlases where
% they're available. The thalamic atlas however is totally bogus
% probabilities and may be replaced by a more modern probablistic atlas as
% a result.
%
% Those two caveates aside the probabilities are true probabilities in the
% sense that they sum to 1 in places where gray matter probability is 1
% but may sum to lesser values in areas near tissue boundaries. 
%
% We can visualize thse tissue probabilities by taking the sum of
% probability maps. This is an improvisation, but serves to illustrate what
% kind of information is stored in the probability_maps field of atlas
% objects.

close all;

pmap = sum(canlab2023_fine_fmriprep20_1mm.probability_maps,2);
pimg = fmri_data();
pimg = pimg.resample_space(canlab2023_fine_fmriprep20_1mm);
pimg.dat = pmap;
pimg.montage;

%%
% Probablistic labels enable mixing and matching different atlases, since 
% the probablistic labels should handle boundary delineation between 
% regions of different atlases in a principled way.
 
add example of atlas merging by replcaing CTI168 GP with Tian2020 GP

Could also sho how you can replace CIT168 red nucleus with bianciardi red nucleus

%%
% Probablistic values also enables using this atlas as a prior for bayesian
% updating of atlases or bayesian segmentations in novel participants 
% (e.g. conditioning label identity on some functional/structural feature
% that updates the atlas prior).

%% Parcel Manipulations
% In the course of developing CANLab2023 I also created two new functions
% which seemed helpful for a variety of parcel manipulations that are worth
% being aware of: lateralize() and dilate(). This section may be
% particularly helpful if you're trying to create a custom atlas. Probably
% too much information for the average user.
% 
% lateralize() will take a bilatral region and return unilateral regions 
% for each hemifield. It works by interogating the image metadata and
% assumes that the positive x direction points towards the right side of
% the brain. It could be improved by incorporating some coordinate
% convention awareness (e.g. RAS vs LAS) and incorporated into canlabCore 
% as an atlas method, but for the time being it's still useful for 
% splitting the brain, just be mindful to inspect the L/R suffixes it 
% adds to make sure they're oriented correctly. We can illustrate its 
% functionality easily using an atlas that doesn't natively lateralize 
% regions, like CIT168.

cit168 = load_atlas('cit168');
cit168_lateralized = lateralize(cit168);

cit168.orthviews;
disp(cit168.labels);
disp(cit168.label_descriptions);

%%
cit168_lateralized.orthviews;
disp(cit168_lateralized.labels);
disp(cit168_lateralized.label_descriptions);

%%
% lateralize can also be used to create lateralized masks which can be
% helpful for constructing new brain atlases, modifying existing atlases 
% and for evaluating left/right symmetry of brain physiology more
% generally (i.e. not only in the context of using an atlas).

default_mask = fmri_data();
default_mask = default_mask.resample_space(canlab2023_fine_fmriprep20_1mm);
default_mask = atlas(default_mask, ...
    'labels', {'brain'}, ...
    'label_descriptions', {'No really, the brain'});
lateralized_mask = lateralize(default_mask);
left_mask = fmri_mask_image(lateralized_mask.select_atlas_subset({'_L'}));
right_mask = fmri_mask_image(lateralized_mask.select_atlas_subset({'_R'}));

right_mask.orthviews;

%%
% dilate() will take an atlas and a mask and dilate the atlas so that it
% fills the mask using nearest neighbor labels. The nearest neighbor step
% is slow, but this can be useful if you are creating a new atlas and want
% to fill out a particular region more neatly than some labeling scheme
% allows, for instance CANLab2023 was designed to fill out CIFTI volumetric
% parcels, but uses the CIT168 globus pallidus, which doesn't necessarily
% segment the pallidum identically. Dilate could asign any residual voxels
% to the appropriate CIT pallidal structure. It can also be useful if your
% particular segmentation doesn't quite match an atlas of interest. For
% instance, if you're working in pure volumetric space you may have areas
% corresponding to the basal ganglia that fall outside the CIFTI mask used
% for CANLab2023's creation.
%
% Let's see how you might dilate the subcortical labels to incorporate some
% additional volume outside the CIFTI atlas. We will do this by dilating
% the cifti atlas, using the dilated cifti atlas and the canlab2023 atlas
% to label the newly created regions, and return a new subcorticl atlas.
% We'll use the default resolution/space of canlab2023 for this, which
% happens to be fmriprep20 space, the coarse parcellation and sampled 2mm,
% but can be invoked more directly by the canlab2023 keyword.

% load atlas
canlab2023 = load_atlas('canlab2023');

% get cifti atlas and dilate it
fid = fopen(which('hcp_cifti_subctx_labels.txt'));
labels = strsplit(char(fread(fid,inf))');
fclose(fid);
labels = labels(~cellfun(@isempty, labels));

cifti_atlas = atlas(which('hcp_cifti_subctx_labels_MNI152NLin2009cAsym.nii.gz'), ...
    'labels',labels);

%%
% we can ignore cerebellum and brainstem for now. Brainstem is
% comprehensive and cerebellum is large and consequently slow to dilate. 
% Not great for a demo. Meanwhile amygdala and hippocampus are embedded in
% the cortex and dilating those into surrounding gray matter seems less
% sensible than dilating say basal ganglia or thalamus into surrounding
% tissue. Slight misalignments of EPI to T1 might plausibly lead to
% meaningful evoked responses that we might attribute to the these regions 
% instead of say white matter.
subctx = cifti_atlas.select_atlas_subset({'accumbens','caudate','putamen',...
    'pallidum','thalamus'});
subctx = fmri_mask_image(subctx).replace_empty();
orig_subctx_regions = canlab2023.apply_mask(subctx).labels;

orig_subctx_regions = orig_subctx_regions(~contains(orig_subctx_regions,'Ctx'));

subctx.dat = iimg_smooth_3d(subctx.dat, subctx.volInfo, 0.5);

% dilate is automatically parallelized. Modify your parallel pool to match
% your number of cores (not virtual cores, virtual cores = 2*cores)
parpool(10)

canlab2023_dil = dilate(canlab2023,subctx);
canlab2023_dil = canlab2023_dil.select_atlas_subset(orig_subctx_regions);
canlab2023_dil_thr = canlab2023_dil.threshold(0.2);

o2 = canlab_results_fmridisplay('full hcp');
canlab2023_dil_thr.montage(o2, 'indexmap', cmap, 'interp', 'nearest');

%%
% note that dilation doesn't deal with probablistic maps too well. To
% make this useful you'd need to check and potentially modify your
% probablity map values and also apply some ventricular mask.