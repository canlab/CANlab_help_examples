addpath('/dartfs-hpc/rc/home/m/f0042vm/software/spm12');
addpath(genpath('/dartfs-hpc/rc/home/m/f0042vm/software/canlab/CanlabCore/CanlabCore/'))
addpath(genpath('/dartfs-hpc/rc/home/m/f0042vm/software/canlab/Neuroimaging_Pattern_Masks/'));

%% Plotting Parcellations
% There are two ways to plot parcellations. One is by defining an atlas and
% then invoking atlas2region to produce independent regions. These are then
% mapped one at a time. This is the old method
%
% Another way is to define an indexed fmri_data object, where each voxel
% corresponds to an index of a colormap. A colormap is then specified by an
% n x 3 matrix of RGB colors. So for instance a voxel of value 3 would map
% to row 3 of the colormap. Plotting the indexed fmri_data object with the
% desired colormap then achieves a similar result. This is the new way I've
% just introduced
%
% Thee are two important differences between these methods. The old method
% invokes the plotting functions n times, once for every region being
% plotted. The new method invokes the plotting functions only once. This
% means the new method runs (approximately) n times faster. The other major
% difference is that with the old method the boundaries of different
% adjacent regions may not perfectly align due to how the plotting 
% functions interpolate fmri_data objects to image patches and surfaces. 
% With the new method perfectly aligned boundaries are guaranteed.
%
% I will demonstrate this using the buckner 7 networks atlas using the
% Discovery compute cluster. Note that on compute clusters for whatever
% reason plotting is excruciatingly slow. Don't take the absolute
% timestamps below as an indicator of how fast these will run on your
% system, but for those using similar distributing computing environments
% the speedups of the new method will be especially valuable.
%
% some variations of the plotting functions may not work neatly with the 
% indexing option, I haven't tested it extensively. if they don't though, 
% just go back to the old method.

buckner = load_atlas('buckner');

cmap = colormap('lines');

%% old method
% we will invoke atlas/montage which internally implements atlas2region().
% atlas2region() splits buckner into it's constituent components so the
% result is an array of regions. A similar result can be obtained by,
% region(fmri_data(bucker),'unique_mask_values')
% region/montage is then invoked by atlas/montage. The default obehavior of
% region/montage is to plot distinct elements of an input array one at a
% time with one unique color per region. In other words, under the default
% behavior of atlas/montage, the role of the voxel values of the atlas only
% matter until region/montage is called, but after that they aren't used
% again.
% region/montage will use default colors, or whatever is passed with 
% 'colors'. Here I pass some colors of my own just to match what I get
% using then new method later, but the results will be essentially the same
% without the {'colors', cmap} arguments. Note also that I'm being lazy and
% misformating cmap, but it gets handled internally after some complaining.
% by region/montage.
% This would appear to do what we want: each atlas region is plotted with
% a unique color, except by plotting each region one at a time we get some 
% slight overlap among adjacent atlas regions because of how the boundaries 
% are interpolated into the image space. This results in 'earlier' regions
% being slightly obscured by later regions. This bias is especially
% problematic as regions become smaller (e.g. in canlab2018).
orig_t0 = tic;
buckner.montage('full','colors',cmap);
fprintf('Runtime %0.2f\n',toc(orig_t0));

%% new method
% Note that our results here occupy less area than above. When 'indexmap'
% is supplied it changes the plotting style from one region at a time to
% all regions at once. While region/montage ignores the voxel values it 
% gets from atlas/region when invoked with {'colors', cmap} (or with no 
% params), region/montage instead does use the voxel values when invoked 
% with {'indexmap', cmap}. Rather than plotting each region one at a time, 
% all are plotted as a single object, and the coloring is determined by 
% voxel values.
% This approach has the advantage of more precise area boundaries but
% precludes the use of certain decorations like area boundaries.
figure;
new_t0 = tic;
buckner.montage('full','indexmap',cmap);
fprintf('Runtime %0.2fs\n',toc(new_t0));

%% variations on the new method
o2 = fmridisplay();
o2 = canlab_results_fmridisplay(region(),'noverbose','full', 'noblobs', 'nooutline');
o2 = addblobs(o2,region(fmri_data(buckner)),'interp','nearest','indexmap',cmap);
