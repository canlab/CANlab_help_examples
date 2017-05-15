% publish script

% Run this from the 'scripts' directory where it is stored

close all
clear all

a_set_up_paths_always_run_first
b_reload_saved_matfiles           % done in indivdidual scripts to save output info in html, but re-run here so vars are available

pubdir = fullfile(resultsdir, 'published_output');
if ~exist(pubdir, 'dir'), mkdir(pubdir), end

do_coverage_contrasts = true;
do_signature_analyses = true;
do_meta_analysis_masks = true;

% ------------------------------------------------------------------------
if do_coverage_contrasts
    
    pubfilename = ['analysis_coverage_and_contrasts_' scn_get_datetime];
    
    p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
        'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);
    
    publish('z_batch_coverage_and_contrasts.m', p)
    
    close all
end

% ------------------------------------------------------------------------
if do_signature_analyses
    
    pubfilename = ['analysis_signature_analyses_' scn_get_datetime];
    
    p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
        'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);
    
    publish('z_batch_signature_analyses.m', p)
    
    close all
end

% ------------------------------------------------------------------------

if do_meta_analysis_masks
    
    pubfilename = ['analysis_meta_analysis_masks_' scn_get_datetime];
    
    p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
        'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);
    
    publish('z_batch_meta_analysis_mask_analyses.m', p)
    
    close all
end
