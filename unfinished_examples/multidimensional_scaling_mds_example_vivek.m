% Load and characterize Hansen PET maps with MDS/clustering
% Load Hansen maps
petmaps = load_image_set('hansen22');

[~, ~, pet_condf] = string2indicator(petmaps.metadata_table.target);

plot_correlation_matrix(petmaps.dat, 'var_names', petmaps.metadata_table.target, 'partitions', pet_condf);

% Multidimensional scaling 
% ------------------------------------------------
mdsinfo_struct = [];
mdsinfo_struct.names = petmaps.metadata_table.target;

mdsinfo_struct.r = corr(petmaps.dat);

% Correlation distance
% figure; imagesc(mdsinfo_struct.r)
mdsinfo_struct.D = (1 - mdsinfo_struct.r) ./ 2;
% figure; imagesc(mdsinfo_struct.D)

[mdsinfo_struct.MDScoords,mdsinfo_struct.obs,mdsinfo_struct.implied_dissim] = shepardplot(mdsinfo_struct.D,[]);
% 10

create_figure('mds plot'); 
point_handles = plot(mdsinfo_struct.MDScoords(:, 1), mdsinfo_struct.MDScoords(:, 2), 'o', 'MarkerFaceColor', [.2 .2 .2]);

% for lines - 1/0 matrix of which lines to draw
mdsinfo_struct.sig = sign(mdsinfo_struct.r) .* abs(mdsinfo_struct.r) > 0.4;

line_handles =  nmdsfig_tools('drawlines',mdsinfo_struct.MDScoords, mdsinfo_struct.sig);
set(line_handles.hhp, 'LineWidth', .5, 'Color', [.7 .7 .7])

% Clustering
% ------------------------------------------------

% Convert to condensed vector form needed by linkage()
distvec = squareform(mdsinfo_struct.D, 'tovector');

% Perform hierarchical clustering using Ward linkage
linkage_tree = linkage(distvec, 'average');

k = 12;  % specify the number of desired clusters
mdsinfo_struct.cluster_labels = cluster(linkage_tree, 'maxclust', k);

% Optional: Plot dendrogram
create_figure('dendrogram');
[~, wh_order] = dendrogram(gca, linkage_tree, 0, 'Labels', mdsinfo_struct.names, 'ClusterIndices', mdsinfo_struct.cluster_labels, 'ShowCut', true);
title('Hierarchical Clustering Dendrogram');
ylabel('Distance');
set(gca, 'FontSize', 18)


% nmdsfig_plot showing MDS space and clusters
% ------------------------------------------------
% for compatibility with nmdsfig_plot
mdsinfo_struct.GroupSpace = mdsinfo_struct.MDScoords;
mdsinfo_struct.ClusterSolution.classes =  mdsinfo_struct.cluster_labels;
mdsinfo_struct.STATS.sigmat = mdsinfo_struct.sig;
mdsinfo_struct.STATS.sigmat2 = [];
mdsinfo_struct.colors = seaborn_colors(k);

out = nmdsfig_tools('nmdsfig_plot',mdsinfo_struct, 0, 0, 'fill');

