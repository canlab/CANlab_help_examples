%% NPS Contrasts
% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end
% ------------------------------------------------------------------------

figtitle = 'NPS and SIIPS1 contrast compare';
printhdr(figtitle)

create_figure(figtitle, 4, 4);

signames = {'NPS' 'NPSpos' 'NPSneg' 'SIIPS'};

scalenames = {'raw' 'scaled'};
simnames = {'dotproduct' 'cosine_sim'};


indx = 0;

for i = 1:length(signames)
    
    for j = 1:length(scalenames)
        
        for k = 1:length(simnames)
            
            % subplot
            indx = indx + 1;
            
            myname = sprintf('%s %s %s', signames{i}, scalenames{j}, simnames{k});
            printhdr(myname);
            
            mydat = table2array(DAT.SIG_contrasts.(scalenames{j}).(simnames{k}).(signames{i}));
            
            subplot(4, 4, indx);
            
            axpos = get(gca, 'Position');
            
            barplot_columns(mydat, myname, 'colors', DAT.contrastcolors, 'nofig', 'names', DAT.contrastnames, 'noviolin');
            
            if indx > 1, set(gca, 'XTickLabel', {});  end
            
            set(gca, 'Position', axpos); 
            title(format_strings_for_legend(myname), 'FontSize', 12);
            
            axis tight
            
            drawnow
                        
        end % sim
        
    end % scale
    
end % sig

% kludge - some kind of bug...

subplot(4, 4, 16);
myname = sprintf('%s %s %s', signames{i}, scalenames{j}, simnames{k});
title(format_strings_for_legend(myname), 'FontSize', 12);

subplot(4, 4, 1);
myname = sprintf('%s %s %s', signames{1}, scalenames{1}, simnames{1});
title(format_strings_for_legend(myname), 'FontSize', 12);
set(gca, 'XTickLabel', {});

%%

plugin_save_figure;
close
