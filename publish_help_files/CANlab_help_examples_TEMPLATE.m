%% TITLE OF HELP FILE - e.g., HOW_DO_I_xxx...
% One-line description of what this help file shows.

%% General instructions

% Code blocks with %% will appear as sections in the table of contents.
% Comments fowing % will be printed as text.

%% Section 1: Creating figures in your code
% --------------------------------------------------------------

% use snapnow to take a snapshot of a figure in the HTML file.
% Example:

dat = magic(24);

figure; imagesc(dat)
snapnow


%% Section 2: Helper functions and printing text output
% --------------------------------------------------------------

% Let's create a standard set of helper functions to increase readability
% Display helper functions: Called by later scripts

dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);

% Example:

printhdr('This example prints some numbers:')
x = 5; y = 3.1415926535;
fprintf('Integer: %d\tfloat: %3.4f \n', x, y);


