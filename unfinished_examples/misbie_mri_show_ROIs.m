% vmpfc_index_vals = [121   122   127   128   129   130   175   176   185   186   327   328   329   330];

% Building a custom atlas with a set of ROIs

% Select sub-atlases for a set of regions of interest
vmpfc = select_regions_near_crosshairs(atlas_obj, 'coords', [0 38 -11], 'thresh', 12, 'flatten');
pcc = select_regions_near_crosshairs(atlas_obj, 'thresh', 12, 'coords', [0   -49    34], 'flatten');
lc = select_atlas_subset(atlas_obj, 'lc');
ca1 = select_atlas_subset(atlas_obj, 'CA1');
acaudate = select_atlas_subset(atlas_obj, {'Caudate_Ca'});

% Merge the atlases
combined_atlas = merge_atlases(vmpfc, pcc);
combined_atlas = merge_atlases(combined_atlas, lc);
combined_atlas = merge_atlases(combined_atlas, ca1);
combined_atlas = merge_atlases(combined_atlas, acaudate);

% Convert to region object and display
% This will auto-label the regions and save names in r(i).shorttitle
r = atlas2region(combined_atlas);
montage(r);

r(1).shorttitle = 'vmPFC';
r(2).shorttitle = 'PCC';
montage(r, 'regioncenters')
%% Surface

create_figure('surf');
axis off

surface_han = surface(r, 'coronal_slabs');
delete(surface_han(end-3:end));
surface_han = surface_han(1:end-4);

% add vmPFC
anat = fmri_data(which('keuken_2014_enhanced_for_underlay.img'), 'noverbose');
ax_han = axes(gcf, 'Position', [.62 .55 .15 .15]);
axis off
set(ax_han, 'Position', [.6 .53 .15 .15])
surf_han2 = isosurface(anat, 'thresh', 140, 'nosmooth', 'ylim', [20 Inf], 'Xlim', [0 -Inf]);
view(128, 22)
set(surf_han2, 'Facealpha', 1)
lightRestoreSingle

%render_on_surface(combined_atlas, [surf_han2 surf_han2], 'colormap', 'winter', 'clim', [1 7]);
cm = colormap_tor([.8 .1 .1], [1 1 0], [.9 .6 .1], 'n', 8);
render_on_surface(combined_atlas, [surface_han surf_han2], 'colormap', cm, 'clim', [1 7]);
render_on_surface(combined_atlas, [surface_han surf_han2], 'colormap', 'winter', 'clim', [1 7]);


%%
Keuken, M. C., P-L Bazin, L. Crown, J. Hootsmans, A. Laufer, C. Müller-Axt, R. Sier, et al. 2014. ?Quantifying Inter-Individual Anatomical 
Variability in the Subcortex Using 7 T Structural MRI.? NeuroImage 94 (July): 40?46. 

Keren, Noam I., Carl T. Lozar, Kelly C. Harris, Paul S. Morgan, and Mark A. Eckert. 2009. ?In Vivo Mapping of the Human Locus Coeruleus.? 

Glasser, Matthew F., Timothy S. Coalson, Emma C. Robinson, Carl D. Hacker, John Harwell, Essa Yacoub, Kamil Ugurbil, et al. 2016. A 
Multi-Modal Parcellation of Human Cerebral Cortex. Nature 536 (7615): 171?78. 

Pauli, Wolfgang M., Randall C. O?Reilly, Tal Yarkoni, and Tor D. Wager. 2016. ?Regional Specialization within the Human Striatum for 
Diverse Psychological Functions.? Proceedings of the National Academy of Sciences of the United States of America 113 (7): 1907?12.  

Amunts,K. et al., (2005). Anat. Embryol. (Berl) 210, 343-352.

Eickhoff S, Stephan KE, Mohlberg H, Grefkes C, Fink GR, Amunts K, Zilles K:
A new SPM toolbox for combining probabilistic cytoarchitectonic maps and functional imaging data. NeuroImage 25(4), 1325-1335, 2005



