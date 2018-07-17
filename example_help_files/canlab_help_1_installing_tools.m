%% About the CANlab Core Tools repository and CANlab toolboxes

% The CANlab Core Tools repository is on https://github.com/canlab/CanlabCore
% It contains core tools for MRI/fMRI/PET analysis from the Cognitive and 
% Affective Neuorscience Lab (Tor Wager, PI) and our collaborators. Many of 
% these functions are needed to run other toolboxes, e.g., the CAN lab?s 
% multilevel mediation and Martin Lindquist?s hemodynamic response estimation 
% toolboxes.

% The tools include object-oriented tools for doing neuroimaging analysis with 
% simple commands and scripts that provide high-level functionality for 
% neuroimaging analysis. For example, there is an "fmri_data" object type 
% that contains neuroimaging datasets (both PET and fMRI data are ok, despite 
% the name). If you have created and object called my_fmri_data_obj, then
% plot(my_fmri_data_obj) will generate a series of plots specific to neuroimaging 
% data, including an interactive brain viewer (courtesy of SPM software). 
% predict(my_fmri_data_obj) will perform cross-validated multivariate prediction 
% of outcomes based on brain data. ica(my_fmri_data_obj) will perform independent 
% components analysis on the data, and so forth.

%% Dependencies:

% Matlab statistics toolbox
% Matlab signal processing toolbox
% Statistical Parametric Mapping (SPM) software https://www.fil.ion.ucl.ac.uk/spm/

% For full functionality, the other toolboxes below are recommended:

%% Available Toolboxes:

% CANlab Core Tools                             https://github.com/canlab/CanlabCore
% CANlab Neuroimaging_Pattern_Masks repository  https://github.com/canlab/Neuroimaging_Pattern_Masks
% CANlab_help_examples                          https://github.com/canlab/CANlab_help_examples
% M3 Multilevel mediation toolbox               https://github.com/canlab/MediationToolbox
% CANlab robust regression toolbox              https://github.com/canlab/RobustToolbox
% MKDA coordinate-based meta-analysis toolbox   https://github.com/canlab/Canlab_MKDA_MetaAnalysis

% and also:
% Paradigms_Public - experimental paradigms     https://github.com/canlab/Paradigms_Public
% FMRI_simulations - brain movies, effect size/power https://github.com/canlab/FMRI_simulations
% CANlab_data_public - Published datasets       https://github.com/canlab/CANlab_data_public
% DCC - Martin Lindquist's dynamic correlation tbx  https://github.com/canlab/Lindquist_Dynamic_Correlation
% CanlabScripts - in-lab Matlab/python/bash     https://github.com/canlab/CanlabScripts 

%% Quick start instructions

% Before you start, the CANlab_Core_Tools must be added to your path with
% subfolders. Otherwise, you will get errors.
%
% The script canlab_toolbox_setup can help download and install the
% toolboxes you need.

% First, go to a folder where you want to install
% toolboxes/repositories on your hard drive. Mine are in "Github" and I've
% already installed CanlabCore, so let's find it and go there:

mypath = what('CanlabCore');
mypath = fileparts(mypath(1).path);
disp(mypath)
cd(mypath)

% Now I'm ready to run the setup script:

canlab_toolbox_setup

% This will attempt to locate toolboxes, add them to your path, and give
% you the option to download them from Github if it can't find them.
