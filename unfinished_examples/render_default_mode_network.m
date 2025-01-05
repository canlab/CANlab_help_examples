atl = load_atlas('yeo17networks');
def = select_atlas_subset(atl, {'Default'});
figure; montage(def);

%%
def = select_atlas_subset(atl, {'Default'}, 'flatten');
% figure; hh = addbrain('inflated surfaces')
% surface(def, 'surface_handles', hh);

figure; hh = addbrain('foursurfaces_hcp');
[~, cm] = seaborn_colors(22);
surface(def, 'surface_handles', hh, 'pos_colormap', cm);

%%
cm = colormap('summer');
% cm = [.5 .5 .5; cm];
create_figure('surf'); 
hh = addbrain('foursurfaces_hcp');
render_on_surface(def, hh, 'colormap', cm, 'clim', [0 1]);

%%
cm = colormap('winter');
% cm = [.5 .5 .5; cm];
create_figure('surf'); 
hh = addbrain('foursurfaces_hcp');
render_on_surface(def, hh, 'colormap', cm, 'clim', [0 1]);


%%
a = select_atlas_subset(atl, {'DefaultA'}, 'flatten');
b = select_atlas_subset(atl, {'DefaultB'}, 'flatten');
c = select_atlas_subset(atl, {'DefaultC'}, 'flatten');


b.labels{2} = 'tmp';
b.label_descriptions{2} = 'tmp';

c.labels{3} = 'tmp';
c.label_descriptions{3} = 'tmp';

b.dat(b.dat > 0) = 2;
c.dat(c.dat > 0) = 3;

abc = a;
abc.dat(b.dat > 0) = 2;
abc.dat(c.dat > 0) = 3;
abc.labels{2} = 'tmp';
abc.label_descriptions{2} = 'tmp';
abc.labels{3} = 'tmp';
abc.label_descriptions{3} = 'tmp';

figure; hh = addbrain('inflated surfaces');

surface(abc, 'surface_handles', hh);

%%

figure; hh = addbrain('foursurfaces');
[~, cm] = seaborn_colors(24);
surface(abc, 'surface_handles', hh, 'pos_colormap', cm);

%%
figure; hh = addbrain('foursurfaces_hcp');
[~, cm] = seaborn_colors(24);
surface(abc, 'surface_handles', hh, 'pos_colormap', cm);
