
% Create_wedge_plot and extract subject scores for each network
% ------------------------------------------------------------------------

% Custom colors, mirroring clusters across L/R hem networks:

[colors1, colors2] = deal(scn_standard_colors(16));
colors = {};
indx = 1;
for i = 1:length(colors1)
    colors{indx} = colors1{i}; colors{indx + 1} = colors2{i}; indx = indx + 2;
end

[hh, output_values_by_region, labels, atlas_obj, colorband_colors] = wedge_plot_by_atlas(imgs, 'atlases', {'yeo17networks'}, 'montage', 'colorband_colors', colors);

labels = labels{1}';                               % network labels
subj_dat = double(output_values_by_region{1});    % subject x network scores

%% Lateralization test
% ------------------------------------------------------------------------

% because these are ordered L then R, we can subtract them to get a
% lateralization score.  score so we have R - L
% positive scores are R, negative scores are L

RL_lat_score = subj_dat(:, 2:2:end) - subj_dat(:, 1:2:end) ;

% t-tests on each region across images (often subjects)
[h, p, ci, stat] = ttest(RL_lat_score);

R = nanmean(subj_dat(:, 2:2:end))';
L = nanmean(subj_dat(:, 1:2:end))';
RvsL = nanmean(RL_lat_score)';

RvsLste = ste(RL_lat_score)';

t = stat.tstat';

p = p';

% Stars for each region
for j = 1:length(p)
    
    if p(j) < .0015, mystr = '***';
    elseif p(j) < .015, mystr = '**';
    elseif p(j) < .055, mystr = '*';
    elseif p(j) < .105, mystr = '+';
    else mystr = ''; xadj = 0;
    end
    
    stars_by_condition{j, 1} = mystr;
    
end % loop through regions

net_labels = labels(1:2:end);
net_labels = strrep(net_labels, 'LH ', '');

roi_table = table(net_labels, R, L, RvsL, RvsLste, t, p, stars_by_condition);

disp(roi_table)


%%

atlas_obj = load_atlas('yeo17networks');
r = atlas2region(atlas_obj);

[roi_table, r] = ttest_table_by_condition(r, imgs);
