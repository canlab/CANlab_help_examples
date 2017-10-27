%% Canlab dataset basic usage
% Shows how to load a sample canlab_dataset object, extract variables, and
% make some plots.

% Instructions to include in help files as appropriate:
% -----------------------------------------------------------------------
%
% Before you start, the CANlab_Core_Tools must be added to your path with
% subfolders. Otherwise, you will get errors.
%
% Sample datasets are in the "Sample_datasets" folder in CANlab_Core_Tools.
%
% This example will use behavioral data in the file: 
% 'Jepma_IE2_single_trial_canlab_dataset.mat'
% The dataset is a multi-level dataset with 34 subjects, 2 subject-level vars, 10 event-level vars
% consisting of a time series of trial-by-trial ratings of pain, expectations, and cue values for each subject 
%
% These data have been submitted for publication (M. Jepma, Wager et al.)
% Please do not reuse without permission.

%% Load the sample dataset and print a summary

% Load sample data file (this is in Sample_datasets in Core - make sure it's on your path)
load('Jepma_IE2_single_trial_canlab_dataset.mat'); % loads object called DAT 

% Print a summary:      
print_summary(DAT);     % see also list_variables(DAT)

%% Extract data two variables and make a plot

% Extract expectation and pain ratings, two continuous event-level variables from the object
[~, expect] = get_var(DAT, 'expected pain');
[~, pain] = get_var(DAT, 'reported pain');

% Make a multi-level scatterplot 
create_figure('lines_expect_pain', 1, 2);
[han, Xbin, Ybin] = line_plot_multisubject(expect, pain, 'n_bins', 5, 'group_avg_ref_line', 'MarkerTypes', 'o', 'colors', custom_colors([1 .7 .4], [1 .7 .4], 100), 'gcolors', {[.4 .2 0] [.8 .4 0]});
axis tight
xlabel('Expectations'); ylabel('Pain'); set(gca, 'FontSize', 24);

%% Extract data from one variable conditional on another variable, and plot

% Now extract expectation and pain variables conditional on cue value:
[~, expect_cshigh] = get_var(DAT, 'expected pain', 'conditional', {'cue valence' 1});
[~, expect_csmed] = get_var(DAT, 'expected pain', 'conditional', {'cue valence' 0});
[~, expect_cslow] = get_var(DAT, 'expected pain', 'conditional', {'cue valence' -1});
[~, pain_cshigh] = get_var(DAT, 'reported pain', 'conditional', {'cue valence' 1});
[~, pain_csmed] = get_var(DAT, 'reported pain', 'conditional', {'cue valence' 0});
[~, pain_cslow] = get_var(DAT, 'reported pain', 'conditional', {'cue valence' -1});

% Now make the plot, without individual subject lines
% First set colors and condition names
color1 = {[.9 .4 .2] [.6 .3 0]};
color2 = {[.5 .5 .5] [.2 .2 .2]};
color3 = {[.4 .8 .4] [.2 .7 .2]};
condition_names = {'High Cue' 'Medium Cue' 'Low Cue'};

% Now plot:
subplot(1, 2, 2)
[han1, Xbin, Ybin] = line_plot_multisubject(expect_cshigh, pain_cshigh, 'n_bins', 5, 'group_avg_ref_line', 'MarkerTypes', 'o', 'colors', color1, 'center', 'noind', 'nolines');
[han2, Xbin, Ybin] = line_plot_multisubject(expect_csmed, pain_csmed, 'n_bins', 5, 'group_avg_ref_line', 'MarkerTypes', 'o', 'colors',color2, 'center', 'noind', 'nolines');
[han3, Xbin, Ybin] = line_plot_multisubject(expect_cslow, pain_cslow, 'n_bins', 5, 'group_avg_ref_line', 'MarkerTypes', 'o', 'colors',color3, 'center', 'noind', 'nolines');
xlabel('Expectations'); ylabel('Pain'); set(gca, 'FontSize', 24);
legend([han1.grpline_handle(1) han2.grpline_handle(1) han3.grpline_handle(1)], condition_names);
drawnow, snapnow

