%% CSF-adjusted data NPS responses
% ------------------------------------------------------------------------

disp(' ')
printhdr('NPS responses by condition - CSF-adjusted images');

figtitle = 'NPS response CSF-adjusted data';
create_figure('nps');

k = length(DAT.conditions);

for i = 1:k
    
    [DAT.npsresponsesc(i), ~, ~, DAT.npspos_by_regionsc(i), DAT.npsneg_by_regionsc(i)] = apply_nps(DATA_OBJsc{i}, 'noverbose', 'notables');
    
end

disp(DAT.conditions)
barplot_columns(DAT.npsresponsesc, figtitle, 'colors', DAT.colors, 'dolines', 'nofig');
set(gca, 'XTickLabel', DAT.conditions, 'XTickLabelRotation', 45, 'FontSize', 14);
title('NPS after CSF-scaling');

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

%% NPS Contrasts: CSF-adjusted data

printhdr('NPS contrasts - CSF-adjusted images data');
% ------------------------------------------------------------------------

% npsdat = cat(2, DAT.npsresponse{:}); DAT.npscontrasts = npsdat * DAT.contrasts';
% Apply contrasts a different way, allowing for differences across number of images in different sets

kc = size(DAT.contrasts, 1);

for c = 1:kc
    
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    DAT.npscontrastssc{c} = cat(2, DAT.npsresponsesc{wh}) * mycontrast(wh)';
end

figtitle = 'NPS contrasts - CSF-adjusted images';
create_figure('nps');

barplot_columns(DAT.npscontrastssc, figtitle, 'colors', DAT.contrastcolors, 'nofig');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45, 'FontSize', 16);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);


%% Correlations with global components after CSF scaling

if isfield(DAT, 'gray_white_csf_contrasts') || isempty(DAT.gray_white_csf_contrasts)

    printhdr('Correlations with global components after CSF scaling');
    printstr(dashes)
    
    clear r p
    
    for i = 1:kc
        
        [r(i, :), p(i, :)] = corr(DAT.npscontrastssc{i}, DAT.gray_white_csf_contrasts{i});
        
    end
    
    gwcsfnames = {'Gray' 'White' 'CSF'};
    
    print_matrix(r, gwcsfnames, DAT.contrastnames);
    
    create_figure('correlation between scaled NPS contrast value and global signal components', 1, 3);
    
    for i = 1:3
        
        subplot(1, 3, i);
        
        for j = 1:kc
            
            [~, infostring, sig, han] = plot_correlation_samefig(DAT.gray_white_csf_contrasts{j}(:, i), DAT.npscontrastssc{j});
            set(han, 'Color', DAT.contrastcolors{j} ./ 2, 'MarkerFaceColor', DAT.contrastcolors{j});
            
            allhan(j) = han;
        end
        
        xlabel(sprintf('Mean %s', gwcsfnames{i}));
        ylabel('NPS Response');
        
        han = plot_horizontal_line(0);
        set(han, 'LineStyle', '--');
        
        han = plot_vertical_line(0);
        set(han, 'LineStyle', '--');
        
        axis tight; title(sprintf('Corr with  %s', gwcsfnames{i}));
        
        if i == 2
            
            legend(allhan, DAT.contrastnames);
        end
    end
    
    drawnow, snapnow
    
end  % if Gray/white/CSF components exist

%% Save results
% ------------------------------------------------------------------------
savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, '-append', 'DAT');


