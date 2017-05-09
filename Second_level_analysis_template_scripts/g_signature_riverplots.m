

%% Profiles across signatures

% Load signature maps
[npsplus, netnames, imgnames] = load_image_set('npsplus');
npsplus.image_names = netnames;

% Riverplot
% ----------------------------------------------------------------
printhdr('Cosine Similarity : All conditions');

% Name the conditions
for i = 1:length(DATA_OBJ), DATA_OBJ{i}.image_names = DAT.conditions{i}; end

% plot significant associations only
riverplot(DATA_OBJ, 'layer2', npsplus, 'pos', 'significant_only', 'layer1colors', DAT.colors, 'layer2colors', seaborn_colors(length(netnames)));

% Old way: not statistically thresholded, but works:
% Get mean data across subjects
%     m = mean(DATA_OBJ{1});
%     m.image_names = DAT.conditions{1};
%
%     for i = 2:k
%
%         m = cat(m, mean(DATA_OBJ{i}));
%         m.image_names = strvcat(m.image_names, DAT.conditions{i});
%
%     end
%
%
%     riverplot(m, 'layer2', npsplus, 'pos', 'layer1colors', DAT.colors, 'layer2colors', seaborn_colors(length(netnames)), 'thin');
%     pause(2)

figtitle = 'CANlab signatures riverplot of conditions';
plugin_save_figure;


%% Contrasts: All signatures
% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end

printhdr('Cosine Similarity : All contrasts');

k = size(DAT.contrasts, 1);


% River plot
% ----------------------------------------------------------------

for i = 1:length(DATA_OBJ_CON), DATA_OBJ_CON{i}.image_names = DAT.contrastnames{i}; end

% plot significant associations only
riverplot(DATA_OBJ_CON, 'layer2', npsplus, 'pos', 'significant_only', 'layer1colors', DAT.contrastcolors, 'layer2colors', seaborn_colors(length(netnames)));

% Old way: not statistically thresholded, but works:
% Get mean data across subjects
%     m = mean(DATA_OBJ_CON{1});
%     m.image_names = DAT.contrastnames{1};
%
%     for i = 2:k
%
%         m = cat(m, mean(DATA_OBJ_CON{i}));
%         m.image_names = strvcat(m.image_names, DAT.contrastnames{i});
%
%     end
%
%     riverplot(m, 'layer2', npsplus, 'pos', 'layer1colors', DAT.contrastcolors, 'layer2colors', seaborn_colors(length(netnames)), 'thin');

figtitle = 'CANlab signatures riverplot of contrasts';
plugin_save_figure;

