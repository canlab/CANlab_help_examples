%% Atlas 2012 behavioral data plot
% This example shows how to plot line plots for multiple conditions with
% error bars and calculate and plot violin plots for contrasts, with
% missing data.

%% General instructions
%
% Before you start, the CANlab_Core_Tools must be added to your path with
% subfolders. Otherwise, you will get errors.
%
% Sample datasets are in the "Sample_datasets" folder in CANlab_Core_Tools.
%
% This example will use emotion regulation data in the file: 
% "Atlas_2012_REMI_behavioral_data.mat"
% The dataset is a series of pain ratings from N = 19 participants
% before, during, and after open or hidden remifentanil delivery.
% 
% These data were published in:
% Atlas, L. Y., Whittington, R., Lindquist, M., Wielgosz, J., Sonty, N., Wager, T. D. 
% (2012) Dissociable influences of opiates and expectations on pain. 
% Journal of Neuroscience. 32(23): p. 8053-8064.
%
%
% Here are a couple of helpful functions we will use for display:
% (you can ignore these.)
dashes = '----------------------------------------------';
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);

%% Section 1: Load the data
%
% The function load_image_set has a number of pre-defined image sets that
% you can load with one simple command.  This is the easiest way to load
% sample data.  The images must be on your Matlab path for this to work.

filename = which('Atlas_2012_REMI_behavioral_data.mat');
if isempty(filename), error('Data file is not on path!'); end

c = load(filename);

% c is an ad hoc data structure. The relevant fields are:
% c =
%
%            HO: [18x19 double]  TRIALS X SUBJECTS HOT OPEN PAIN SCORES
%            WO: [18x19 double]   TRIALS X SUBJECTS WARM OPEN PAIN SCORES
%            HH: [18x19 double] TRIALS X SUBJECTS HOT HIDDEN PAIN SCORES
%            WH: [18x19 double] TRIALS X SUBJECTS WARM HIDDEN PAIN SCORES

% It would be a very good idea to put these data in a canlab_dataset
% object, and then use the methods associated with that object to plot.

%% Section 2: Make a line plot of data by condition and time (trial)
%
printhdr('Line Plot by Condition');

% Set up the figure. create_figure is a function in the canlab toolbox that
% sets figure defaults and handles in a convenient way.

create_figure('remi pain', 1, 2);

% Draw some boxes to shade the background and mark off every other run

h1 = drawbox(.5, 3, 1, 7, [.5 .5 .5]); set(h1, 'FaceAlpha', .2, 'EdgeColor', 'none');
h1 = drawbox(6.5, 3, 1, 7, [.5 .5 .5]); set(h1, 'FaceAlpha', .2, 'EdgeColor', 'none');
h1 = drawbox(12.5, 3, 1, 7, [.5 .5 .5]); set(h1, 'FaceAlpha', .2, 'EdgeColor', 'none');

% Draw the box showing the drug delivery (and instruction) time 

h1 = drawbox(3.5, 9, 1, .3, [.4 .4 .4]); set(h1, 'FaceAlpha', 1, 'EdgeColor', [.2 .2 .2]);

% Plot one line for each condition

h = lineplot_columns(c.HH', 'color', 'r');
h2 = lineplot_columns(c.HO', 'color', 'b');

h3 = lineplot_columns(c.WH', 'color', [1 .5 0]);
h4 = lineplot_columns(c.WO', 'color', [0 .5 1]);

% Set legend, labels

xlabel('Trial number');
ylabel('Pain rating');
set(gca, 'YLim', [1 8]);

legend([h.line_han h2.line_han h3.line_han h4.line_han], {'Hot Hidden' 'Hot Open' 'Warm Hidden' 'Warm Open'});

subplot(2, 2, 2)
% Now plot the trial-by-trial open vs. hidden differences

hot_openvs_hidden = (c.HO - c.HH)';

h = lineplot_columns(hot_openvs_hidden, 'color', 'r');

h1 = drawbox(.5, 3, -1.7, 2, [.5 .5 .5]); set(h1, 'FaceAlpha', .2, 'EdgeColor', 'none');
h1 = drawbox(6.5, 3, -1.7, 2, [.5 .5 .5]); set(h1, 'FaceAlpha', .2, 'EdgeColor', 'none');
h1 = drawbox(12.5, 3, -1.7, 2, [.5 .5 .5]); set(h1, 'FaceAlpha', .2, 'EdgeColor', 'none');

h1 = drawbox(3.5, 9, -1.7, .3, [.4 .4 .4]); set(h1, 'FaceAlpha', 1, 'EdgeColor', [.2 .2 .2]);
h1 = plot_horizontal_line(0);
set(h1, 'LineStyle', '--');

set(gca, 'FontSize', 18);
title('Open vs. Hidden Effect');
ylabel('Pain');

drawnow, snapnow

%% Section 3: Make bar/violin plots of the contrasts
%
printhdr('Violin Plots of Contrasts');

% Identify trials when instructions/drug are being delivered. 

instruction_contrast = [-1 -1 -1 1 1 1 1 1 1 1 1 1 -1 -1 -1 -1 -1 -1]';

% Get means for this period for each subject x condition.
% Avoid NaNs by omitting case/subject-wise.

hot_hidden_during_instruct = nanmean(c.HH(instruction_contrast > 0, :))';
hot_open_during_instruct = nanmean(c.HO(instruction_contrast > 0, :))';
warm_hidden_during_instruct = nanmean(c.WH(instruction_contrast > 0, :))';
warm_open_during_instruct = nanmean(c.WO(instruction_contrast > 0, :))';

X = [hot_hidden_during_instruct hot_open_during_instruct warm_hidden_during_instruct warm_open_during_instruct ];
names = {'Hot Hidden' 'Hot Open' 'Warm Hidden' 'Warm Open'};

% Create the figure

create_figure('bars', 1, 2); 
barplot_columns(X, 'nofig', 'colors', {[1 0 0] [0 0 1] [1 .5 0] [0 .5 1]})
set(gca, 'XTickLabel', names);
set(gca, 'FontSize', 16);
ylabel('Pain');

title('Pain during instruction period');

subplot(1, 2, 2);
contrasts = [-1 1 0 0; 0 0 -1 1]';
convalues = X * contrasts;
connames = {'Hot' 'Warm'};

barplot_columns(convalues, 'nofig', 'colors', {[1 0 0] [1 .5 0]})
set(gca, 'FontSize', 16);
set(gca, 'XTickLabel', connames);
title('Open - Hidden');
ylabel('< Analgesia      Hyperalgesia >');

%% Section 4: Print table of means to save for later
%
printhdr('Subject means by condition');

print_matrix(X, names);

