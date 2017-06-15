% Set options used in various core scripts
% --------------------------------------------------------------------
%
% You can change these values on your local computer, but do not commit the
% changed version to the repository.

% prep_2_load_image_data_and_save options  (also prep_3_calc_univariate_contrast_maps_and_save)
% --------------------------------------------------------------------
dofullplot = true;          % default true  Can set to false to save time
omit_histograms = false;    % default false Histograms not useful for large samples 
dozipimages = true;         % default true  Set to false to avoid load on data upload/download when re-running often


% c2_SVM_contrasts options
% --------------------------------------------------------------------
dosavesvmstats = true;      % default true      Save statistics and weight map objects for SVM contrasts
dobootstrap = false;        % default false     Takes a lot of time
boot_n = 5000;              % default number of bootstrap samples. Very slow. Recommend 5,000 for final published analysis

