%% Spatial specificity: Correlations between NPS contrasts and global gray, white, CSF

if isfield(DAT, 'gray_white_csf_contrasts') || isempty(DAT.gray_white_csf_contrasts)
    
    printhdr('Correlations between NPS and global gray, white, CSF');
    disp('Systematic non-zero values indicate global signal contamination');
    
    k = size(DAT.contrasts, 1);
    
    clear r p
    
    for i = 1:k
        
        [r(i, :), p(i, :)] = corr(DAT.npscontrasts{i}, DAT.gray_white_csf_contrasts{i});
        
    end
    
    gwcsfnames = {'Gray' 'White' 'CSF'};
    
    print_matrix(r, gwcsfnames, DAT.contrastnames);
    
    figtitle = 'correlation between NPS contrast value and global signal components';
    create_figure(figtitle, 1, 3);
    
    clear allhan
    
    for i = 1:3
        
        subplot(1, 3, i);
        
        for j = 1:k
            
            [~, infostring, sig, han] = plot_correlation_samefig(DAT.gray_white_csf_contrasts{j}(:, i), DAT.npscontrasts{j});
            
            if isa(han(1), 'matlab.graphics.chart.primitive.Scatter')
                % Newer Matlab (2017b+) uses scatter object:
                set(han(1), 'MarkerEdgeColor', DAT.contrastcolors{j} ./ 2, 'MarkerFaceColor', DAT.contrastcolors{j});
                
            else
                set(han(1), 'Color', DAT.contrastcolors{j} ./ 2, 'MarkerFaceColor', DAT.contrastcolors{j});
            end
            
            allhan(j) = han(1);
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
    
    plugin_save_figure;
    close
    
else
    
    printhdr('CANNOT DO CORRELATIONS WITH GLOBAL SIGNAL - GLOBAL DATA NOT EXTRACTED')
    
end  % if
