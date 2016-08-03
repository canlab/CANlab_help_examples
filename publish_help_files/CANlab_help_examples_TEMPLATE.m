%% TITLE OF HELP FILE - e.g., HOW_DO_I_xxx...
% One-line description of what this help file shows.

%% General instructions
%
% Instructions for creating a file:
% -----------------------------------------------------------------------
%
% - Try to give a brief, but complete, description
% - Code blocks with %% will appear as sections in the table of contents.
% - Comments following % will be printed as text.
% - Comment lines *immediately below a %% code block will be printed as
% regular text.
%
% Instructions to include in help files as appropriate:
% -----------------------------------------------------------------------
%
% Before you start, the CANlab_Core_Tools must be added to your path with
% subfolders. Otherwise, you will get errors.
%
% Sample datasets are in the "Sample_datasets" folder in CANlab_Core_Tools.
%
% This example will use emotion regulation data in the folder: 
% "Wager_et_al_2008_Neuron_EmotionReg"
% The dataset is a series of contrast images from N = 30 participants.
% Each image is a contrast image for [reappraise neg vs. look neg]
% 
% These data were published in:
% Wager, T. D., Davidson, M. L., Hughes, B. L., Lindquist, M. A., 
% Ochsner, K. N.. (2008). Prefrontal-subcortical pathways mediating 
% successful emotion regulation. Neuron, 59, 1037-50.

%% Section 1: Creating figures in your code
%
% use snapnow to take a snapshot of a figure in the HTML file.
% Example:

dat = magic(24);

figure; imagesc(dat)
snapnow


%% Section 2: Helper functions and printing text output
%
% Let's create a standard set of helper functions to increase readability.
% You can include these in your help scripts.

dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);

% Example:

printhdr('This example prints some numbers:')
x = 5; y = 4*atan(-1.0);
fprintf('Integer: %d\tfloat: %3.14f \n', x, y);

