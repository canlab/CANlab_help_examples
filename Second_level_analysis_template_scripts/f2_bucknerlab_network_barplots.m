figtitlebase = 'BucknerLab rsFMRI Cosine Similarity';
image_set_name = 'bucknerlab';  % keyword for named set to pass into load_image_set


[mapset, netnames] = load_image_set(image_set_name);

mycolors = seaborn_colors(length(netnames));

k = length(DAT.conditions);

myfontsize = get_font_size(k); % This is a function defined below; ok in Matlab 2016 or later
mystarsize = myfontsize ./ 2;

%% Profiles across Buckner Lab rsFMRI networks

% Barplot: All conditions
% ----------------------------------------------------------------
figtitle = [figtitlebase ' all conditions'];

printhdr(figtitle);

nrows = ceil(k ./ 4);
ncols = ceil(k ./ nrows);

create_figure(figtitle, nrows, ncols);

clear axh handles

for i = 1:k
    
    subplot(nrows, ncols, i);
    
    [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, 'mapset', mapset, 'networknames', netnames, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'nofigure', 'noplot');
    
    % Could also do this with just the keyword, but this re-loads the map set
    %[stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ{i}, image_set_name, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'nofigure', 'noplot');
    
    handles{i} = barplot_columns(stats.r', 'colors', mycolors, 'noviolin', 'nofig', 'noind', 'names', netnames, 'MarkerSize', mystarsize);
    hold on; plot_horizontal_line(0);
    
    axh(i) = gca;
    set(gca, 'XTickLabel', netnames, 'XTickLabelRotation', 45, 'FontSize', myfontsize);
    if i == 1, ylabel('Cosine similarity'); else, ylabel(' '); end
    xlabel('')
    title(DAT.conditions{i});
    axis tight
    
end

equalize_axes(axh);
reset_star_y_position(handles);

if nrows == 1, kludgy_fix_for_y_axis(axh); end

plugin_save_figure;


%%

% Contrasts across conditions
% ------------------------------------------------------------------------

if isfield(DAT, 'contrasts') && ~isempty(DAT.contrasts)
    
    figtitle = [figtitlebase ' contrasts'];
    
    printhdr(figtitle);
    
    kc = size(DAT.contrasts, 1);
    
    myfontsize = get_font_size(kc); % This is a function defined below; ok in Matlab 2016 or later
    mystarsize = myfontsize ./ 2;
    
    nrows = ceil(kc ./ 4);
    ncols = ceil(kc ./ nrows);
    
    create_figure(figtitle, nrows, ncols);
    
    clear axh handles
    
    for i = 1:kc
        
        subplot(nrows, ncols, i);
        [stats hh hhfill table_group multcomp_group] = image_similarity_plot(DATA_OBJ_CON{i}, 'mapset', mapset, 'networknames', netnames, 'average', 'cosine_similarity', 'colors', DAT.colors(i), 'nofigure', 'noplot');
        
        handles{i} = barplot_columns(stats.r', 'colors', mycolors, 'noviolin', 'nofig', 'noind', 'names', netnames, 'MarkerSize', mystarsize);
        hold on; plot_horizontal_line(0);
        
        axh(i) = gca;
        set(gca, 'XTickLabel', netnames, 'XTickLabelRotation', 45, 'FontSize', myfontsize);
        if i == 1, ylabel('Cosine similarity'); else, ylabel(' '); end
        xlabel('')
        title(DAT.contrastnames{i});
        axis tight
        
    end
    
    equalize_axes(axh);
    reset_star_y_position(handles);
    
    if nrows == 1, kludgy_fix_for_y_axis(axh); end
    
    plugin_save_figure;
    
    
end



%%
function myfontsize = get_font_size(k)
% get font size
if k > 10
    myfontsize = 8;
elseif k > 8
    myfontsize = 9;
elseif k > 5
    myfontsize = 12;
elseif k > 2
    myfontsize = 14;
else
    myfontsize = 18;
end
end

%%
function kludgy_fix_for_y_axis(axh)
% Matlab is having some trouble with axes for unknown reasons

axis1 = get(axh(1), 'Position');
for i = 2:length(axh)
    
    mypos = get(axh(i), 'Position');
    mypos([2 4]) = axis1([2 4]);  % re-set y start and height
    set(axh(i), 'Position', mypos);
    
end

end

%%
function reset_star_y_position(handles)

% Reset y position for all stars
my_ylim = get(gca, 'YLim');
yval = my_ylim(2) - .05 * range(my_ylim);

for s = 1:length(handles)
    
    myhan = handles{s}.star_handles;
    for i = 1:length(myhan)
        mypos = get(myhan(i), 'Position');
        mypos(2) = yval;
        set(myhan(i), 'Position', mypos);
    end
    
end

end % function

