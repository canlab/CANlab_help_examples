

%% Profiles across signatures

doriver = 1; % 1 = river plot, 0 = polar plot

if ~doriver
    % Polar plot
    % ----------------------------------------------------------------
    printhdr('Cosine Similarity : First condition');
    
    create_figure('npspluslabels');
    i = 1;
    [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'noplot');
    drawnow, snapnow
    
    printhdr('Cosine Similarity : All conditions');
    
    k = length(DAT.conditions);
    create_figure('npsplus', 1, k);
    
    for i = 1:k
        
        subplot(1, k, i);
        [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'noplot');
        hh = findobj(gca, 'Type', 'Text'); delete(hh)
        title(DAT.conditions{i})
        camzoom(1.3)
        drawnow
    end
    
    snapnow
    
else
    % Riverplot
    % ----------------------------------------------------------------
    printhdr('Cosine Similarity : All conditions');
    
    % Get mean data across subjects
    m = mean(DATA_OBJ{1});
    m.image_names = DAT.conditions{1};
    
    for i = 2:k
        
        m = cat(m, mean(DATA_OBJ{i}));
        m.image_names = strvcat(m.image_names, DAT.conditions{i});
        
    end
    
    [npsplus, netnames, imgnames] = load_image_set('npsplus');
    npsplus.image_names = netnames;
    
    riverplot(m, 'layer2', npsplus, 'pos', 'layer1colors', DAT.colors, 'layer2colors', seaborn_colors(length(netnames)), 'thin');
    pause(2)
   
    drawnow, snapnow
    figtitle = 'Riverplot all conditions';
    savename = fullfile(figsavedir, [figtitle '.png']);
    saveas(gcf, savename);
    
end


%% Contrasts: All signatures
% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end

printhdr('Cosine Similarity : All contrasts');

k = size(DAT.contrasts, 1);

if ~doriver
    % Polar plot
    % ----------------------------------------------------------------
    
    create_figure('npsplus', 1, k);
    
    for i = 1:k
        
        subplot(1, k, i);
        [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ_CON{i}, 'average', 'cosine_similarity', 'colors', DAT.contrastcolors(i), 'nofigure');
        hh = findobj(gca, 'Type', 'Text'); delete(hh)
        title(DAT.contrastnames{i})
        camzoom(1.3)
        drawnow
    end
    
    
    
else
    % River plot
    % ----------------------------------------------------------------
    % Get mean data across subjects
    m = mean(DATA_OBJ_CON{1});
    m.image_names = DAT.contrastnames{1};
    
    for i = 2:k
        
        m = cat(m, mean(DATA_OBJ_CON{i}));
        m.image_names = strvcat(m.image_names, DAT.contrastnames{i});
        
    end
    
    riverplot(m, 'layer2', npsplus, 'pos', 'layer1colors', DAT.colors, 'layer2colors', seaborn_colors(length(netnames)), 'thin');
    
    drawnow, snapnow
    figtitle = 'Riverplot all contrasts';
    savename = fullfile(figsavedir, [figtitle '.png']);
    saveas(gcf, savename);
    
end

drawnow, snapnow