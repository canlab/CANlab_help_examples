mycosrange = [-.3 .3];  % Range for cosine similarity on polar plots
% [1 -1] would be full range, but individual person
% similarity is often much lower in scale, so
% consider narrowing scale for plot.

mycosrangenps = [-.05 .05];  % The 'signature' plots may have a different range

%% Profiles across Buckner Lab rsFMRI networks

% Polar plot: First condition
% ----------------------------------------------------------------
printhdr('BucknerLab rsFMRI Cosine Similarity : First condition');

create_figure('bucknerpluslabels');
i = 1;
[stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'nofigure', 'fixedrange', mycosrange);
drawnow, snapnow

% Polar plot: All conditions
% ----------------------------------------------------------------
printhdr('BucknerLab rsFMRI Cosine Similarity : All conditions');

k = length(DAT.conditions);
create_figure('bucknerlab', 1, k);

for i = 1:k
    
    subplot(1, k, i);
    [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'nofigure', 'fixedrange', mycosrange);
    hh = findobj(gca, 'Type', 'Text'); delete(hh)
    title(DAT.conditions{i})
    camzoom(1.3)
    
    % stretch to fill
    set(gca, 'DataAspectRatioMode', 'auto', 'PlotBoxAspectRatioMode', 'auto', 'CameraViewAngleMode', 'auto');
    axis image
    
    drawnow
end

snapnow

% Contrasts: All conditions
% ------------------------------------------------------------------------

if isfield(DAT, 'contrasts') && ~isempty(DAT.contrasts)
    
    printhdr('BucknerLab rsFMRI Cosine Similarity : All contrasts');
    
    kc = size(DAT.contrasts, 1);
    
    create_figure('bucknerlabcons', 1, kc);
    
    for i = 1:kc
        
        subplot(1, kc, i);
        [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ_CON{i}, 'average', 'cosine_similarity', 'colors', DAT.contrastcolors(i), 'nofigure', 'mapset', 'bucknerlab', 'fixedrange', mycosrange);
        hh = findobj(gca, 'Type', 'Text'); delete(hh)
        title(DAT.contrastnames{i})
        camzoom(1.3)
        
        % stretch to fill
        set(gca, 'DataAspectRatioMode', 'auto', 'PlotBoxAspectRatioMode', 'auto', 'CameraViewAngleMode', 'auto');
        axis image
        
        drawnow
        
    end
    
end

snapnow

%% Profiles across signatures

create_figure('npspluslabels');

% Polar plot: First condition
% ----------------------------------------------------------------

printhdr('CANlab Signatures Cosine Similarity : First condition');

[stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'nofigure', 'mapset', 'npsplus', 'fixedrange', mycosrangenps);
drawnow, snapnow

% Polar plot: All conditions
% ----------------------------------------------------------------

printhdr('CANlab Signatures Cosine Similarity : All conditions');

create_figure('npsplus', 1, k);

for i = 1:k
    
    subplot(1, k, i);
    [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'nofigure', 'mapset', 'npsplus', 'fixedrange', mycosrangenps);
    hh = findobj(gca, 'Type', 'Text'); delete(hh)
    title(DAT.conditions{i})
    camzoom(1.3)
    
    % stretch to fill
    set(gca, 'DataAspectRatioMode', 'auto', 'PlotBoxAspectRatioMode', 'auto', 'CameraViewAngleMode', 'auto');
    axis image
    
    drawnow
    
end

snapnow

% Contrasts: All conditions
% ------------------------------------------------------------------------

printhdr('Cosine Similarity : All contrasts');

% Contrasts: All conditions
% ------------------------------------------------------------------------

if isfield(DAT, 'contrasts') && ~isempty(DAT.contrasts)
    
    printhdr('CANlab Signatures Cosine Similarity : All contrasts');
    
    % Polar plot
    % ----------------------------------------------------------------
    
    create_figure('npspluscons', 1, kc);
    
    for i = 1:kc
        
        subplot(1, kc, i);
        [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ_CON{i}, 'average', 'cosine_similarity', 'colors', DAT.contrastcolors(i), 'nofigure', 'mapset', 'npsplus', 'fixedrange', mycosrangenps);
        hh = findobj(gca, 'Type', 'Text'); delete(hh)
        title(DAT.contrastnames{i})
        camzoom(1.3)
        
        % stretch to fill
        set(gca, 'DataAspectRatioMode', 'auto', 'PlotBoxAspectRatioMode', 'auto', 'CameraViewAngleMode', 'auto');
        axis image
        
        drawnow
        
    end
    
    snapnow
    
end % if



