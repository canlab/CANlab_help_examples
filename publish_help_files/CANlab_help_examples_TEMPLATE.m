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

%% Section 3: Inserting external graphics
%
% 
% <<CANlab_Methods.png>>
% 

% Note: You must have the png in your relevant HTML OUTPUT directory for this to work!

%% Section 4: Inserting HTML code
% You can add HTML code inserts in your files
% For this to work, there must be NO empty lines between the <html> and
% </html> tags. 
%
% In general, spaces after % characters, % with no text and empty lines are all
% interpreted as markdown elements, so the formatting can be finnicky.
% 
% See below for an example with an HTML table and links.

%% Explore More: CANlab Toolboxes
% Tutorials, overview, and help: <https://canlab.github.io>
%
% Toolboxes and image repositories on github: <https://github.com/canlab>
%
% <html>
% <table border=1><tr>
% <td>CANlab Core Tools</td>
% <td><a href="https://github.com/canlab/CanlabCore">https://github.com/canlab/CanlabCore</a></td></tr>
% <td>CANlab Neuroimaging_Pattern_Masks repository</td>
% <td><a href="https://github.com/canlab/Neuroimaging_Pattern_Masks">https://github.com/canlab/Neuroimaging_Pattern_Masks</a></td></tr>
% <td>CANlab_help_examples</td>
% <td><a href="https://github.com/canlab/CANlab_help_examples">https://github.com/canlab/CANlab_help_examples</a></td></tr>
% <td>M3 Multilevel mediation toolbox</td>
% <td><a href="https://github.com/canlab/MediationToolbox">https://github.com/canlab/MediationToolbox</a></td></tr>
% <td>M3 CANlab robust regression toolbox</td>
% <td><a href="https://github.com/canlab/RobustToolbox">https://github.com/canlab/RobustToolbox</a></td></tr>
% <td>M3 MKDA coordinate-based meta-analysis toolbox</td>
% <td><a href="https://github.com/canlab/Canlab_MKDA_MetaAnalysis">https://github.com/canlab/Canlab_MKDA_MetaAnalysis</a></td></tr>
% </table>
% </html>
% 
% Here are some other useful CANlab-associated resources:
%
% <html>
% <table border=1><tr>
% <td>Paradigms_Public - CANlab experimental paradigms</td>
% <td><a href="https://github.com/canlab/Paradigms_Public">https://github.com/canlab/Paradigms_Public</a></td></tr>
% <td>FMRI_simulations - brain movies, effect size/power</td>
% <td><a href="https://github.com/canlab/FMRI_simulations">https://github.com/canlab/FMRI_simulations</a></td></tr>
% <td>CANlab_data_public - Published datasets</td>
% <td><a href="https://github.com/canlab/CANlab_data_public">https://github.com/canlab/CANlab_data_public</a></td></tr>
% <td>M3 Neurosynth: Tal Yarkoni</td>
% <td><a href="https://github.com/neurosynth/neurosynth">https://github.com/neurosynth/neurosynth</a></td></tr>
% <td>M3 DCC - Martin Lindquist's dynamic correlation tbx</td>
% <td><a href="https://github.com/canlab/Lindquist_Dynamic_Correlation">https://github.com/canlab/Lindquist_Dynamic_Correlation</a></td></tr>
% <td>M3 CanlabScripts - in-lab Matlab/python/bash</td>
% <td><a href="https://github.com/canlab/CanlabScripts">https://github.com/canlab/CanlabScripts</a></td></tr>
% </table>
% </html>
%
% *Object-oriented, interactive approach*
% The core basis for interacting with CANlab tools is through object-oriented framework.
% A simple set of neuroimaging data-specific objects (or _classes_) allows you to perform
% *interactive analysis* using simple commands (called _methods_) that
% operate on objects. 
%
% Map of core object classes:
%
% <<CANlab_object_types_flowchart.png>>