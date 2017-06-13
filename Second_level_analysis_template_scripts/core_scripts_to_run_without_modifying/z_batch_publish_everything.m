% Runs batch analyses and publishes HTML report with figures and stats to 
% results/published_output in local study-specific analysis directory.

% Run this from the main base directory (basedir)

% Loads data, creates contrasts, extracts signatures and parcels
z_batch_publish_image_prep_and_qc

% Publishes analyses with contrasts, signatures, more
z_batch_publish_analyses
