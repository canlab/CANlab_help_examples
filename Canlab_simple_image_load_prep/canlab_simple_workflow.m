% How to use these scripts:
% To set up and prep the analysis, you'll need a "main project directory"
% and several subdirectories with standard names: "data", "scripts", "results"
%
% Image data (.nii/.img) should be in the "data" directory.
% Create a "scripts" directory and put a copy of the script
% "canlab_simple_set_conditions_contrasts_colors.m" in there. This
% specifies where/how to find the images.
% Add the "scripts" directory to your matlab path using addpath.  
%
% Next, go to the main project directory -- this 
% is one level above the "data", "scripts", "results" dirs -- and run 
% "canlab_simple_workflow". This loads all the images into objects and saves 
% them in a standardized structure. 
% 
% You will need to define one custom script and save it in your local "scripts" 
% folder first. This is called "canlab_simple_set_conditions_contrasts_colors".
% Copy the master copy into your local scripts folder and modify it. Then run 
% canlab_simple_workflow.
% 
% Once you have run canlab_simple_workflow once, you need not run it again. 
% Go to your main project directory and run "canlab_simple_reload" to load all 
% your files into the workspace.
%
% These scripts do not support contrasts and full sets of analyses with them.
% If you are defining contrasts, use the main canlab_example_script system
% instead.  

%% Set paths based on current directory
% go to main project folder first:

canlab_simple_set_paths

%% Define local script and run
% Initializes DAT strucutre, so only run once during setup

canlab_simple_set_conditions_contrasts_colors

%% Load image data and save files for load/use
% only run once during setup

prep_2_load_image_data_and_save

%% After running these, reload to analyze/plot data

