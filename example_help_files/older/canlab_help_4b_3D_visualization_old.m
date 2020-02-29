%% 3-D volume visualization

%% About volume visualisation
%
% Creating 3-D renderings of brain data and results can help localize brain
% activity and show patterns in a way that allows meaningful comparisons
% across studies.
%
% The CANlab object-oriented tools have methods built in for rendering
% volume data on brain surfaces. They generally use Matlab's isosurface and
% isocaps functions.
%

%% Prepare a sample statistical results map
%
% For this walkthrough, we'll use the "Pain, Cognition, Emotion balanced N = 270 dataset" 
% from Kragel et al. 2018, Nature Neuroscience. 
% More information about this dataset and how to download it is in an
% earlier walkthrough on "loading datasets"
%
% The code below loads it; but you could also use any other brain dataset
% for this purpose (e.g., the 'emotionreg' dataset in load_image_set.
%
% Our goal is to select subject-level images corresponding to a particular task type and
% do a t-test on these, and visualize the results in various 3-D ways.

[test_images, names] = load_image_set('kragel18_alldata', 'noverbose');

% This field contains a table object with metadata for each image:
metadata = test_images.dat_descrip;
metadata(1:5, :)                        % Show the first 5 rows

% Here are the 3 domains:
disp(unique(metadata.Domain))

% Find all the images of "Neg_Emotion" and pull those into a separate
% fmri_data object:

wh = find(strcmp(metadata.Domain, 'Neg_Emotion'));
neg_emo = get_wh_image(test_images, wh);

% Do a t-test on these images, and store the results in a statistic_image
% object called "t". Threshold at q < 0.001 FDR. This is an unusual
% threshold, but we have lots of power here, and want to restrict the
% number of significant voxels for display purposes below.

t = ttest(neg_emo, .001, 'fdr');

% Find the images for other conditions and save them for later:

wh = find(strcmp(metadata.Domain, 'Cog_control'));
cog_control = get_wh_image(test_images, wh);

wh = find(strcmp(metadata.Domain, 'Pain'));
pain = get_wh_image(test_images, wh);


%% The surface() method
% Most data objects, including fmri_data, statistic_image, and region objects,
% have a surface() method. Entering it with no arguments creates a surface
% or series of surfaces (depending on the object)
%
% The surface() method lets you easily render blobs
% on a number of pre-set choices for brain surfaces or 3-D cutaway surfaces. 

% This generates a series of 6 surfaces of different types, including a
% subcortical cutaway
surface(t);
drawnow, snapnow

% This generates a different plot 
t.surface('foursurfaces', 'noverbose');
snapnow

% You can see more options with:
% |help statistic_image.surface| or |help t.surface|

%% Using the surface() method for 3-D cutaways
%
% The surface() method with the 'cutaway' option lets you render blobs
% on a number of pre-set choices for 3-D cutaway surfaces. 
%
% The anatomical image used by default is adapted from the 7T high-resolution 
% atlas of Keuken, Forstmann et al.  
% References:
% Keuken et al. (2014). Quantifying inter-individual anatomical variability in the subcortex using 7T structural MRI.                                                                                                                 
% Forstmann, Birte U., Max C. Keuken, Andreas Schafer, Pierre-Louis Bazin, Anneke Alkemade, and Robert Turner. 2014. ?Multi-Modal Ultra-High Resolution Structural 7-Tesla MRI Data Repository.? Scientific Data 1 (December): 140050.
% Returning coordinates in mm and meshgrid matrices.

[all_surf_handles, pcl, ncl] = surface(t, 'cutaway', 'ycut_mm', -30, 'noverbose');
snapnow

create_figure('cutaways');  axis off
han = surface(t, 'right_cutaway', 'noverbose');
snapnow

create_figure('cutaways'); axis off
han = surface(t, 'coronal_slabs', 'noverbose');
snapnow

create_figure('cutaways'); axis off

poscm = colormap_tor([.5 0 .5], [1 0 0]);  % purple to red
     
surface_handles = t.surface('cutaway', 'ycut_mm', 10, 'pos_colormap', poscm, 'noverbose');
snapnow

%% Using addbrain to load or build surfaces
% You can also build any surface object you want and render colors onto it.
% This is a very versatile method. 
%
% Matlab creates handles to surfaces (and
% other graphics objects). You can use the handles to manipulate the
% objects in a many ways. They have, for example, color, line, face color,
% edge color, and many more properties. If |h| is a figure handle, |get(h)|
% shows a list of its properties. |set(h, 'MyPropertyName', myvalue)| sets
% the property |'MyPropertyName'| to |myvalue|.
%
% Here, we'll use |addbrain| to build up a set of surfaces with handles,
% and then render colored blobs on them using |surface()|. Instead of the
% object method, you can also use its underlying function: |cluster_surf|
%
% Try |help addbrain| for a list of surfaces, and |help cluster_surf| for
% other color/display/scaling options.

% Let's build a surface by starting with a group of thalamic nuclei, and
% adding the parabrachial complex and the red nucleus.
% Then, we'll render our t-statistics in colors onto those surfaces.

create_figure('cutaways'); axis off
surface_handles = addbrain('thalamus_group');

surface_handles = [surface_handles addbrain('pbn')];
surface_handles = [surface_handles addbrain('rn')];

drawnow, snapnow

%%
% Now render the statistic image stored in _t_ onto those surfaces.
% All non-activated areas turn gray.

t.surface('surface_handles', surface_handles, 'noverbose');
drawnow, snapnow

%%
% Transparent surfaces are a little hard to see.
% We can use Matlab's powerful handle graphics system to inspect and change
% all kinds of properties. See the Matlab documentation for more details.
% Let's just make the surfaces solid:

set(surface_handles, 'FaceAlpha', 1);
drawnow, snapnow

%%
% These surfaces can be rotated too (or zoom in/out, pan, set lighting,
% etc.) Let's shift the angle.

view(222, 15);          % rotate
camzoom(0.8);           % zoom out

% A helpful CANlab function to re-set the lighting after rotating is:

lightRestoreSingle;

drawnow, snapnow

%%
% addbrain also has keywords for composites of multiple surfaces

create_figure('cutaways'); axis off
surface_handles = addbrain('limbic');
t.surface('surface_handles', surface_handles, 'noverbose');

%% Removing blobs and re-adding new colors
% There is a special command to re-set the surface colors to gray.
% Then we can add a t-test for different contrasts without re-drawing
% surfaces.

surface_handles = addbrain('eraseblobs',surface_handles);

title('Cognitive Control');
t = ttest(cog_control, .001, 'unc');
t.surface('surface_handles', surface_handles, 'noverbose');
drawnow, snapnow

surface_handles = addbrain('eraseblobs',surface_handles);

title('Pain');
t = ttest(pain, .001, 'unc');
t.surface('surface_handles', surface_handles, 'noverbose');
drawnow, snapnow

surface_handles = addbrain('eraseblobs',surface_handles);

title('Megative Emotion');
t = ttest(neg_emo, .001, 'unc');
t.surface('surface_handles', surface_handles, 'noverbose');
drawnow, snapnow


%% Prepackaged cutaway surfaces
% Addbrain has many 3-D surfaces, including cutaways that show various 3-D
% sections. The code below visualizes the various options for cutaways.
%
% You can also pass any of these keywords into surface() to generate the
% surface and render colored blobs.

keywords = {'left_cutaway' 'right_cutaway' 'left_insula_slab' 'right_insula_slab' 'accumbens_slab' 'coronal_slabs' 'coronal_slabs_4' 'coronal_slabs_5'};

for i = 1:length(keywords)
    
    create_figure('cutaways'); axis off

    surface_handles = addbrain(keywords{i});
    title(['addbrain(' keywords{i} ')']);
    
    % Alternative: This command creates the same surfaces:
    % surface_handles = canlab_canonical_brain_surface_cutaways(keywords{i});
    
    drawnow, snapnow
    
end

%%
% Let's add a pain map to this last one

title('Pain');
t = ttest(pain, .001, 'unc');
t.surface('surface_handles', surface_handles, 'noverbose');
drawnow, snapnow

%% Creating isosurfaces
% The fmri_data.isosurface() method allows you to create and save
% isosurfaces for any image, parcel, or blob.
%
% You can also save the meshgrid output and surface structure that lets you
% render this surface easily in the future.
%
% Here's a simple example visualizing all of the parcels in an atlas as 3-D
% blobs:

atlas_obj = load_atlas('basal_ganglia');

create_figure('isosurface');
surface_handles = isosurface(atlas_obj);

% Now we'll set some lighting and figure properties
axis image vis3d off
material dull
view(210, 20);
lightRestoreSingle

drawnow, snapnow

%%
% Let's load another atlas, and pull out all the "default mode" regions
% We'll use isosurface to visualize these

atlas_obj = load_atlas('canlab2018_2mm');
atlas_obj = select_atlas_subset(atlas_obj, {'Def'}, 'labels_2');

create_figure('isosurface');
surface_handles = isosurface(atlas_obj);

% let's add a cortical surface for context
% We'll make the back surface (right) opaque, and the front (left) transparent
han = addbrain('hires right');
set(han, 'FaceAlpha', 1);

han2 = addbrain('hires left');
set(han2, 'FaceAlpha', 0.1);

axis image vis3d off
material dull
view(-88, 31);
lightRestoreSingle

drawnow, snapnow
%% Explore on your own
%
% 1. Try to create your own custom brain surface to visualize one of the 3
% statistic image maps we've been working on. Can you make a plot that
% really shows the important results in a clear way?
%
% 2. Try exploring movie_tools to create a movie where you rotate, zoom,
% and change the transparency of your surfaces in some way.
% You can write movie files to disk for use in presentations, too.
% 
% 3. Try rendering another atlas, or subset of an atlas, with isosurface()
%    Maybe you can pull out and render all the "ventral attention" network
%    regions.
%    
%% Explore More: CANlab Toolboxes
% Tutorials, overview, and help: <https://canlab.github.io>
%
% Toolboxes and image repositories on github: <https://github.com/canlab>
%
% <html>
% <table border=1><tr>
% <td>CANlab Core Tools</td>
% <td><a href="https://github.com/canlab/CanlabCore">https://github.com/canlab/CanlabCore</a></td></tr>
% <td>CANlab Neuroimaging_Pattern_Masks repository</td>
% <td><a href="https://github.com/canlab/Neuroimaging_Pattern_Masks">https://github.com/canlab/Neuroimaging_Pattern_Masks</a></td></tr>
% <td>CANlab_help_examples</td>
% <td><a href="https://github.com/canlab/CANlab_help_examples">https://github.com/canlab/CANlab_help_examples</a></td></tr>
% <td>M3 Multilevel mediation toolbox</td>
% <td><a href="https://github.com/canlab/MediationToolbox">https://github.com/canlab/MediationToolbox</a></td></tr>
% <td>M3 CANlab robust regression toolbox</td>
% <td><a href="https://github.com/canlab/RobustToolbox">https://github.com/canlab/RobustToolbox</a></td></tr>
% <td>M3 MKDA coordinate-based meta-analysis toolbox</td>
% <td><a href="https://github.com/canlab/Canlab_MKDA_MetaAnalysis">https://github.com/canlab/Canlab_MKDA_MetaAnalysis</a></td></tr>
% </table>
% </html>
% 
% Here are some other useful CANlab-associated resources:
%
% <html>
% <table border=1><tr>
% <td>Paradigms_Public - CANlab experimental paradigms</td>
% <td><a href="https://github.com/canlab/Paradigms_Public">https://github.com/canlab/Paradigms_Public</a></td></tr>
% <td>FMRI_simulations - brain movies, effect size/power</td>
% <td><a href="https://github.com/canlab/FMRI_simulations">https://github.com/canlab/FMRI_simulations</a></td></tr>
% <td>CANlab_data_public - Published datasets</td>
% <td><a href="https://github.com/canlab/CANlab_data_public">https://github.com/canlab/CANlab_data_public</a></td></tr>
% <td>M3 Neurosynth: Tal Yarkoni</td>
% <td><a href="https://github.com/neurosynth/neurosynth">https://github.com/neurosynth/neurosynth</a></td></tr>
% <td>M3 DCC - Martin Lindquist's dynamic correlation tbx</td>
% <td><a href="https://github.com/canlab/Lindquist_Dynamic_Correlation">https://github.com/canlab/Lindquist_Dynamic_Correlation</a></td></tr>
% <td>M3 CanlabScripts - in-lab Matlab/python/bash</td>
% <td><a href="https://github.com/canlab/CanlabScripts">https://github.com/canlab/CanlabScripts</a></td></tr>
% </table>
% </html>
%
% *Object-oriented, interactive approach*
% The core basis for interacting with CANlab tools is through object-oriented framework.
% A simple set of neuroimaging data-specific objects (or _classes_) allows you to perform
% *interactive analysis* using simple commands (called _methods_) that
% operate on objects. 
%
% Map of core object classes:
%
% <<CANlab_object_types_flowchart.png>>