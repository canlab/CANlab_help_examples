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