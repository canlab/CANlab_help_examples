%% Load a sample dataset
% This example shows how to load a pre-set example fMRI dataset into
% an fmri_data object.

%% General instructions

% Before you start, the CANlab_Core_Tools must be added to your path with
% subfolders. Otherwise, you will get errors.
%
% The sample datasets are in the Sample_datasets folder.
% This example will use emotion regulation data in the folder Wager_et_al_2008_Neuron_EmotionReg
%
% Here are a couple of helpful functions we will use for display:
% (you can ignore these.)
dashes = '----------------------------------------------';
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);

%% Section 1: The quick and easy way to load a pre-specified dataset

% First, check whether images are on your path:
% We will search for one image and save the path name.

printhdr('Check that we can find data images:')
myfile = which('con_00810001.img');
mydir = fileparts(myfile);
if isempty(mydir), disp('Uh-oh! I can''t find the data.'), else disp('Data found.'), end


%% Section 2: Use filenames to find file names 

% First, we need to list the file names in a string matrix.
% Then, we can load them into an fmri_data object

printhdr('Find files and get their names:')
image_names = filenames(fullfile(mydir, 'con_008100*img'), 'absolute');

% Now load them into an fmri_data object.

data_obj = fmri_data(image_names);

% This is the gateway to doing many other things, which are explained in
% other help files.  But just to get us started, let's run through a few
% basic things we can do. We'll mainly just look at some standard plots of
% the data.

%% Section 3: Plot the data we just loaded

% Operations that we can perform on fmri_data objects are called methods.
% You can see a list of methods by typing methods(data_obj).
% Here, we'll call the plot method to visualize the data.

plot(data_obj)
snapnow
