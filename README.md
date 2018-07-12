# CANlab_help_examples

This repository is designed to accompany the <a href = "http://canlab.github.io/CanlabCore">CANlab Core Tools repository for neuroimaging data analysis</a>. It includes:
- How-to examples that publish HTML files with code and output, focusing on the CANlab’s interactive object-oriented tools.
- A set of modifiable batch scripts that provide a second-level neuroimaging analysis pipeline, which stores objects and variables with standard names and prints date-stamped HTML reports for analyses. 

Running the examples also serves as a preliminary unit testing frame for the CANlab tools.
Please document errors by posting issues on the CANlab Github page.

The batch script system is in the folder "Second_level_analysis_template_scripts".  It provides a pipeline for generating analysis reports. It provides a "base package" of analyses based on simple scripts which are designed to be easy to modify and extend.  They use CANlab objects so that the commands in the scripts are simple and high-level. The philosophy is centered around:
- Interactive data analysis with objects, allowing flexibility 
- Re-use of code (objects and simple scripts) that is as well-vetted as possible and tested across users and contexts
- Simple scripts that minimize coding errors and maximize readability and reusability
- Date-stamped HTML reports with figures and statistics provide an archival record of analyses, are shareable, and ideally contain the information required to reproduce the analysis and write a publication
- A package that contains a minimal dataset and the code (scripts) required to run an analyses facilitate sharing and reproducibility.

The "base package" currently provides five types of date-stamped HTML analysis reports:

  'contrasts'     : Coverage and univariate condition and contrast maps
  'signatures'    : Pre-defined brain 'signature' responses from CANlab
  'svm'           : Cross-validated Support Vector Machine analyses for each contrast
  'bucknerlab'    : Decomposition of each condition and contrast into loadings on resting-state network maps
  'meta_analysis' : Tests of "pattern of interest" analyses and ROIs derived from CANlab meta-analyses
 
Quick start, walkthrough, and help:
------------------------------------------------------------
1 - Download the <a href = "http://canlab.github.io/CanlabCore">CANlab Core Tools repository for neuroimaging data analysis</a>
2 - Open Matlab and change to the directory where you want to install the toolboxes (i.e., drag folder into Matlab cmd window)
3 - Run canlab_toolbox_setup.m (in Canlab_Core) by dragging the file from Finder/Explorer into Matlab
4 - Create an study analysis folder where you want to store data and analyses for a study
5 - Change to that folder in Matlab
6 - Run a_set_up_new_analysis_folder_and_scripts.m by typing "a_set_up_new_analysis_folder_and_scripts" in Matlab

Also, see the help documents/walkthrough in the canlab_help_examples repository. They are called:
0_CANLab-Help2ndlevelExampleWalkthrough.pdf
0_begin_here_readme.m
0_debugging_common_errors.rtf

Getting help and additional information:
------------------------------------------------------------

More information canb be found on the CANlab website, https://canlabweb.colorado.edu/. We also maintain a WIKI with more information on some of our toolboxes and fMRI analysis more generally, which is <a href = "https://canlabweb.colorado.edu/wiki/doku.php/help/fmri_tools_documentation">here</a>.  For more information on fMRI analysis generally, see <a href = "https://leanpub.com/principlesoffmri">Martin and Tor's online book</a> and our free Coursera videos and classes <a href = "https://www.coursera.org/learn/functional-mri">Principles of fMRI Part 1</a> and <a href = "https://www.coursera.org/learn/functional-mri-2">Part 2 </a>. 

This is a list of other potential topics -- the help topics are still a work in progress:  


Overview
————————————————————————————

overview_fmri_data_object

overview_statistic_image_object

overview_region_object

overview_fmridisplay_object



Visualization
————————————————————————————

plot_montage_of_slices

plot_montage_of_multiple_maps

plot_blobs_on_3d_surface

plot_relationships_between_two_images

receiver_operating_characteristic_plot

Data manipulation
————————————————————————————

extract_data_from_regions_of_interest

make_a_group_average_anatomical_underlay_image

convert_a_statistic_image_to_region_object

convert_a_statistic_image_to_fmri_data_object

Quality control
————————————————————————————
basic_fmri_data_plot


Analysis
————————————————————————————
parcellate_regions

draw_regions_of_interest

choose_regions_of_interest_from_atlas

voxelwise_t_test

voxelwise_regression

threshold_and_display_a_brain_map

multivariate_prediction_of_a_binary_outcome

multivariate_prediction_of_a_continuous_outcome

bootstrap_a_multivariate_predictive_map

permutation_test_on_multivariate_predictive_map
