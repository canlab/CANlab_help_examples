

[~, netnames] = load_image_set('bucknerlab');

[~, npsplusnames] = load_image_set('npsplus');

mycolors = seaborn_colors(max(length(netnames), length(npsplusnames)));

%% Profiles across Buckner Lab rsFMRI networks

% Barplot: All conditions
% ----------------------------------------------------------------
printhdr('BucknerLab rsFMRI Cosine Similarity : All conditions');

k = length(DAT.conditions);
create_figure('bucknerlab', 1, k);


clear axh

for i = 1:k
    
    subplot(1, k, i);
    [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'nofigure', 'noplot');
    
    barplot_columns(stats.r', 'colors', mycolors, 'noviolin', 'nofig', 'noind', 'names', netnames);
    hold on; plot_horizontal_line(0);
    
    axh(i) = gca;
    set(gca, 'XTickLabel', netnames, 'XTickLabelRotation', 45);
    ylabel('Cosine similarity');
    xlabel('')
    title(DAT.conditions{i});
    axis tight

end

equalize_axes(axh);
drawnow, snapnow
figtitle = 'Bucknerlab networks all conditions';
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);
    

%%


% Contrasts: All conditions
% ------------------------------------------------------------------------

if isfield(DAT, 'contrasts') && ~isempty(DAT.contrasts)
    
    printhdr('BucknerLab rsFMRI Cosine Similarity : All contrasts');
    
    kc = size(DAT.contrasts, 1);
    
    create_figure('bucknerlabcons', 1, kc);
    
    for i = 1:kc
        
        subplot(1, kc, i);
        [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ_CON{i}, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'nofigure', 'noplot');
        
        barplot_columns(stats.r', 'colors', mycolors, 'noviolin', 'nofig', 'noind', 'names', netnames);
        hold on; plot_horizontal_line(0);
        
        axh(i) = gca;
        set(gca, 'XTickLabel', netnames, 'XTickLabelRotation', 45);
        ylabel('Cosine similarity');
        xlabel('')
        title(DAT.contrastnames{i});
        axis tight
        
    end

    equalize_axes(axh);
    drawnow, snapnow
    figtitle = 'Bucknerlab networks all contrasts';
    savename = fullfile(figsavedir, [figtitle '.png']);
    saveas(gcf, savename);
    
end

%% Profiles across signatures

create_figure('npspluslabels');

% Barplot plot: All conditions
% ----------------------------------------------------------------

printhdr('CANlab Signatures Cosine Similarity : All conditions');

create_figure('npsplus', 1, k);

clear axh

for i = 1:k
    
    subplot(1, k, i);
    [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, 'average', 'cosine_similarity', 'mapset', 'npsplus', 'colors', DAT.colors(i), 'nofigure', 'noplot');
    
    barplot_columns(stats.r', 'colors', mycolors, 'noviolin', 'nofig', 'noind', 'names', npsplusnames);
    hold on; plot_horizontal_line(0);
    
    axh(i) = gca;
    set(gca, 'XTickLabel', npsplusnames, 'XTickLabelRotation', 45);
    ylabel('Cosine similarity');
    xlabel('')
    title(DAT.conditions{i});
    axis tight
    
end

equalize_axes(axh);
drawnow, snapnow
figtitle = 'CANlab signatures all conditions';
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

% Contrasts: All conditions
% ------------------------------------------------------------------------

printhdr('Cosine Similarity : All contrasts');

% Contrasts: All conditions
% ------------------------------------------------------------------------

if isfield(DAT, 'contrasts') && ~isempty(DAT.contrasts)
    
    printhdr('CANlab Signatures Cosine Similarity : All contrasts');
    
    % Barplot plot
    % ----------------------------------------------------------------
    
    create_figure('npspluscons', 1, kc);
    
    for i = 1:kc
        
        subplot(1, kc, i);
        [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ_CON{i}, 'average', 'cosine_similarity', 'mapset', 'npsplus', 'colors', DAT.colors(i), 'nofigure', 'noplot');
        
        barplot_columns(stats.r', 'colors', mycolors, 'noviolin', 'nofig', 'noind', 'names', npsplusnames);
        hold on; plot_horizontal_line(0);
        
        axh(i) = gca;
        set(gca, 'XTickLabel', npsplusnames, 'XTickLabelRotation', 45);
        ylabel('Cosine similarity');
        xlabel('')        
        title(DAT.contrastnames{i});
        axis tight
        
    end

    equalize_axes(axh);
    drawnow, snapnow
    figtitle = 'CANlab signatures all contrasts';
    savename = fullfile(figsavedir, [figtitle '.png']);
    saveas(gcf, savename);
    
end % if



