% publish script

% Run this from the 'scripts' directory where it is stored

close all
clear all

a_set_up_paths_always_run_first
b_reload_saved_matfiles

pubdir = fullfile(resultsdir, 'published_output');
if ~exist(pubdir, 'dir'), mkdir(pubdir), end

% ------------------------------------------------------------------------
pubfilename = ['analysis_coverage_and_contrasts_' scn_get_datetime];

p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
    'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);

publish('z_batch_coverage_and_contrasts.m', p)

% ------------------------------------------------------------------------
pubfilename = ['analysis_signature_analyses_' scn_get_datetime];

p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
    'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);

publish('z_batch_signature_analyses.m', p)