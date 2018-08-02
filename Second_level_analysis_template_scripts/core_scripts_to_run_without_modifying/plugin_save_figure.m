% To use: Create variable called figtitle with figure name, 
% and set 'Tag' property of figure to the value of figtitle/figstr.
% Then run this. Used in canlan_second_level scripts

% Try to find figure by tag 
fighan = findobj('Type', 'figure', 'Tag', figtitle);

% Take last one if multiple
if length(fighan) > 1
    [~, wh] = max(cat(1, fighan.Number));
    fighan = fighan(wh); 
end

% Create savename

if ishandle(fighan)
    
    savename = fullfile(figsavedir, [figtitle '.png']);
    
% if isempty(fighan) && exist('figstr', 'var')
%     
%     fighan = findobj('Type', 'figure', 'Tag', figstr);
%     savename = fullfile(figsavedir, [figstr '.png']);
    
elseif isempty(fighan)
    
    disp('Cannot find figure - Tag field was not set or figure was closed. Skipping save operation.');
    
    return
    
end
    
% If oK, save

disp(sprintf('Saving: %s', [figtitle '.png']));

saveas(fighan, savename);

drawnow, snapnow    % for HTML printouts

%close               % to save memory, etc., as we are printing figs

% Updated: 11/13/17 by Tor Wager, to provide robustness to users
% interacting with figure windows during run-time

