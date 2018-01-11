savename = fullfile(figsavedir, [figtitle '.png']);

disp(sprintf('Saving: %s', [figtitle '.png']));

fighan = findobj('Type', 'figure', 'Tag', figtitle);

if isempty(fighan)
    disp('Cannot find figure - Tag field was not set or figure was closed. Skipping save operation.');
    
else
    saveas(fighan, savename);
    
    drawnow, snapnow    % for HTML printouts
end

%close               % to save memory, etc., as we are printing figs

% Updated: 11/13/17 by Tor Wager, to provide robustness to users
% interacting with figure windows during run-time

