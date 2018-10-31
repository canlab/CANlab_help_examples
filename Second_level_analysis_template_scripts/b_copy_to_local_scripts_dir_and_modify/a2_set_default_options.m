% Set options used in various core scripts
% --------------------------------------------------------------------
%
% You can change these values on your local computer, but do not commit the
% changed version to the repository.

% prep_2_load_image_data_and_save options  (also prep_3_calc_univariate_contrast_maps_and_save)
% --------------------------------------------------------------------
dofullplot = true;         % default true  Can set to false to save time
omit_histograms = false;     % default false Histograms not useful for large samples 
dozipimages = true;        % default true  Set to false to avoid load on data upload/download when re-running often

% prep_3a_run_second_level_regression_and_save options 
% --------------------------------------------------------------------
dorobust = true;            % robust statistics [true, false] -- default true
myscaling = 'raw';          % 'raw' or 'scaled'
design_matrix_type = 'custom';   % 'group' or 'custom'
                            % Group: use DAT.BETWEENPERSON.group or DAT.BETWEENPERSON.contrasts{c}.group;
                            % Custom: use all columns of table object DAT.BETWEENPERSON.contrasts{c};

% prep_3b_run_SVMs_on_contrasts_and_save options 
% --------------------------------------------------------------------
dosubjectnorm = false;      % default false     normalize_each_subject_by_l2norm; can help with numerical scaling and inter-subject scaling diffs
dozscoreimages = false;     % default false     Z-score each input image, removing image mean and forcing std to 1. Removes overall effects of image intensity and scale. Can be useful across studies but also removes information. Use judiciously.
dosavesvmstats = true;      % default true      Save statistics and weight map objects for SVM contrasts
dobootstrap = true;         % default false     Takes a lot of time
boot_n = 1000;              % default number of bootstrap samples. Very slow. Recommend 5,000 for final published analysis
parallelstr = 'parallel';   % parallel proc for boot. 'parallel' or 'noparallel'


% prep_3c_run_SVMs_on_contrasts_masked options 
% --------------------------------------------------------------------
% see options in prep_3b above as well as the following:
maskdir = fullfile(basedir, 'masks');
maskname = which('gray_matter_mask.img');

% prep_4_apply_signatures_and_save options 
% --------------------------------------------------------------------
use_scaled_images = false;

% z_batch_publish_everything, z_batch_publish_analyses options 
% --------------------------------------------------------------------
% Enter string for which analyses to run, in any order
%
% 'contrasts'     : Coverage and univariate condition and contrast maps
% 'signatures'    : Pre-defined brain 'signature' responses from CANlab
% 'svm'           : Cross-validated Support Vector Machine analyses for each contrast
% 'bucknerlab'    : Decomposition of each condition and contrast into loadings on resting-state network maps
% 'meta_analysis' : Tests of "pattern of interest" analyses and ROIs derived from CANlab meta-analyses
%
% Default if you run z_batch_publish_analyses is to run all, in this order.
% Or run a custom set:
% batch_analyses_to_run = {'contrasts' 'signatures' 'svm' 'bucknerlab' 'meta_analysis'};
% z_batch_publish_analyses({'svm' 'bucknerlab'})

