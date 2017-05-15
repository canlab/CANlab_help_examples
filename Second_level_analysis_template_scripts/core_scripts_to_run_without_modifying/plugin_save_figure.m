    savename = fullfile(figsavedir, [figtitle '.png']);
    
    disp(sprintf('Saving: %s', [figtitle '.png']));
    
    saveas(gcf, savename);
    
    drawnow, snapnow    % for HTML printouts
    
    %close               % to save memory, etc., as we are printing figs
    