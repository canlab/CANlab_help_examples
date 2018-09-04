%% CANlab_help_examples second-level batch scripts example
% 
% This code downloads sample data from figshare.com and contains basic
% steps for running a standard batch set of analyses on 2nd-level fMRI data
% (contrast images).
%

%% The dataset
% The dataset contains fMRI contrast images from 59 participants, for both pain
% and romantic rejection.
%
% Two versions of this dataset are shared on figshare.com
%
% This version has contrast images and scripts only:
%    https://figshare.com/articles/2014_Woo_DPSP_Pain_Rejection_contrast_images/7040201
% Download at:
%    https://ndownloader.figshare.com/articles/7040201/versions/1
%
% This version has all output from the CANlab 2nd-level batch scripts:
%    https://figshare.com/articles/2014_Woo_DPSP_Pain_Rejection/7040171
% Download at:
%    https://ndownloader.figshare.com/articles/7040171/versions/1

% Download the contrast images and scripts needed to recreate results
% (Needs fixing to get it to work? Not sure we can save folders as well as
% files?)
% see: https://docs.figshare.com/old_docs/api/

mydir = websave('2014_Woo_DPSP_Pain_Rejection', 'https://ndownloader.figshare.com/articles/7040201/versions/1');

