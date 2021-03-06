%% Multi-level kernel density (MKDA) meta-analysis example: Agency database
% The starting point for coordinate-based meta-analysis (CBMA) is a text file 
% with the information entered from published studies. In this example, the 
% information is contained in the file "Agency_meta_analysis_database.txt"
% It is in the Neuroimaging_Pattern_Masks repository on Github. 
% 
% This file should be on your Matlab path:
% Neuroimaging_Pattern_Masks/CANlab_Meta_analysis_maps/2011_Agency_Meta_analysis/Agency_meta_analysis_database.txt

%% Section 1: Locate the coordinate database file
% Also, create a new analysis folder for this analysis

dbfilename = 'Agency_meta_analysis_database.txt';
dbname = which(dbfilename);

if isempty(dbname), error('Cannot locate the file %s\nMake sure it is on your Matlab path.', dbfilename); end

% Create a new directory for the analysis and go there:
analysisdir = fullfile(pwd, 'Agency_meta_analysis_example');
mkdir(analysisdir)
cd(analysisdir)

%% Section 2: Read in and set up the coordinate database
% When you set up your own database, several rules apply. Formatting the spreadsheet
% so it loads correctly can sometimes be the hardest part of running a
% meta-analysis.
%
% See https://canlabweb.colorado.edu/wiki/doku.php/help/meta/meta_analysis_mkda
% 
% And https://canlabweb.colorado.edu/wiki/doku.php/help/meta/database
%
% Here are some rules for setting up the file:
%   1     The variable "dbname" in the workspace should specify the name of your coordinate database file
%   2     The database must be a text file, tab delimited
%   3     The 1st row of the database must contain the number of columns as its 1st and only entry
%   4     The 2nd row of database must contain variable names (text, no spaces or special characters)
%   5     The 3rd - nth rows of the database contains data
%   6     Talairach coordinates are indicated by T88 in CoordSys variable
%   7     coordinate fields should be called x, y, and z
%   8     Do NOT use Z, or any other field name in clusters structure
% 
% The second row of your database should contain names for each variable
% you have coded.  Some variables should be named with special keywords,
% because they are used in the meta-analysis code. Other variables can be named 
% anything, as long as there are *no spaces or special characters* in the
% name (e.g., !@#$%^&*(){}[] ~`\/|<>,.?/;:"''+=). 
% Anything that you could not name a variable in Matlab will also not work
% here. 
% Here are the variable names with special meaning. They are case-sensitive:
%
% *Subjects*          : Sample size of the study to which the coordinate belongs
%
% *FixedRandom*       : Study used fixed or random effects. 
%                     Values should be Fixed or Random.
%                     Fixed effects coordinates will be automatically
%                     downweighted
%
% *SubjectiveWeights* : A coordinate or contrast weighting vector based on FixedRandom 
%                     and whatever else you want to weight by; e.g., study reporting threshold
%                     The default is to use FixedRandom only if available
%
% *x*, *y*, *z*           : X, Y, and Z coordinates
%
% *study*             : name of study
%
% *Contrast*          : unique indices (e.g., 1:k) for each independent
%                     contrast. This is a required variable!
%                     All rows belonging to the same contrast should
%                     (almost) always have the same values for every
%                     variable other than x, y, and z.
%
% *CoordSys*          : Values should be MNI or T88, for MNI space or Talairach space
%                     Talairach coordinates will be converted to MNI using
%                     Matthew Brett's transform

% Read in the database and save it in a structure variable called "DB"
clear DB
read_database;

% Optional: Create SubjectiveWeights
% We will skip this step, but you can use the SubjectiveWeights field to
% assign weights to coordinates. Weights should be between zero and 1


% Prepare the database by checking fields and separating contrasts,
% specifying a 10 mm radius for integrating coordinates:
DB = Meta_Setup(DB, 10);

% Meta_Setup automatically saves a file called SETUP.mat in your folder as well.
drawnow, snapnow
close

%% Check and clean up any variables that need recoding
% This is a good time to examine the DB structure to check whether the variables
% you entered look as intended (numeric or text), and clean up any
% variables that need recoding.  
% Sometimes, if text characters are entered
% in the spreadsheet in a column of numbers, the entire column will be read
% in as text.  
% Other times, variable entries with the same intended category/level will
% have different names, e.g., yes vs. Yes (all entries are
% case-sensitive).  You can either fix these in the spreadsheet (best) or
% re-code them here.
%
% There is no re-coding needed for this dataset, but here is an example:
% e.g., 
% wh = strcmp(DB.Increased_craving, 'yes'); DB.Increased_craving(wh) = {'Yes'};

% If you do re-code, do this afterwards:
% save SETUP -append DB

%% Select a subset of contrasts
% The function Meta_Select_Contrasts allows you to select a subset of the
% database (DB variable) based on a combination of selected levels on
% multiple variables.  We will skip that for this example, but if you do
% select variables, it is a good idea to create a subfolder for the
% analysis with selected coordinates, and save the DB variable in SETUP.mat
% in that folder, along with  other results you may generate.

%% Set up and run the analysis
% This step prepares the dataset for meta-analysis and runs the entire
% analysis.  It then generates results maps.
%
% It will generate new files for the analysis, so it is a good idea to
% create and go to a subfolder that will contain files for this analysis.
% Many meta-analysis projects involve several analyses, in several
% sub-folders.

modeldir = fullfile(analysisdir, 'MKDA_all_contrasts');
mkdir(modeldir)
cd(modeldir)

Meta_Activation_FWE('all', DB, 500, 'nocontrasts', 'noverbose');

% Note: For a "final" analysis, 10,000 iterations are recommended
%       Because we typically care about inferences at the "tails" of the
%       sampling distribution (i.e., voxels with low P-values)
%
% Note: You can also use Meta_Activation_FWE to do each piece separately:
%
% Meta_Activation_FWE('setup')          % sets up the analysis
%                                       Convolve with spheres and set up the study indicator dataset
% Meta_Activation_FWE('mc', 10000)      % Adds 10,000 Monte Carlo iterations
%
% A file is saved every 10 iterations, so if there are existing saved iterations 
% this will find them and add more.
%
% Meta_Activation_FWE('results')        % generates results maps

drawnow, snapnow

%% Reload masked activation map and display slice montage
% The code below uses the CANlab object-oriented tools, in
% CANlab_Core_Tools repository. There are many more options for
% visualization and data analysis

% load saved results mask (union of all thresholds)
img = fmri_data('Activation_FWE_all.img', 'noverbose');  % Create an fmri_data-class object

create_figure('slice montage'); axis off
o2 = montage(img);                                       % Display montage, and return an fmridisplay object called o2

drawnow, snapnow

%% Print transparent blobs and activation points on slice montage

o2 = removeblobs(o2);   
o2 = addblobs(o2, r, 'trans', 'transvalue', .4);
o2 = addpoints(o2, DB.xyz, 'MarkerFaceColor', [.5 0 0], 'Marker', 'o', 'MarkerSize', 4);

drawnow, snapnow

%% Print table of regions with region labels

r = region(img);            % Create a region-class object

[rpos, rneg] = table(r);    % Print table, returning regions separated by those with positive or negative data values
                            % Attach names

r = [rpos rneg];            % re-concatenate for convenience later

%% Surface rendering 

% Create a cutaway surface with blobs
surface(img, 'cutaway', 'ycut_mm', -30);

drawnow, snapnow

% Plot points as spheres on a canonical surface:

plot_points_on_surface2(DB.xyz, {[.5 0 0]});

drawnow, snapnow


%% Extract and plot study proportion data for significant regions
% First, we will load the MC_Info.mat file, which contains lots of
% information about the analysis.  The variable of main interest in this

% file is MC_Setup, which contains the contrast indicator maps. 
% This is stored in MC_Setup.unweighted_study_data

load MC_Info

% MC_Setup = 
%     unweighted_study_data: [231202�18 double]             % Voxels x contrast indicator maps (1/0)
%                   volInfo: [1�1 struct]                   % Info for mapping back into brain space
%                         n: [2 3 2 2 1 2 1 2 4 2 2 3 3 2 2 8 2 1] % Coordinates per study
%                       wts: [18�1 double]                  % Contrast weights
%                         r: 5                              % Radius in voxels
%                        cl: {1�18 cell}                    % contiguous blobs for each contrast, for Monte Carlo
                       
indicator_maps = MC_Setup.unweighted_study_data;

% Extract indicator for contrasts that activate within 10 mm (5 vox) of
% significant voxels region object r
[studybyroi,studybyset] = Meta_cluster_tools('getdata', r, indicator_maps, MC_Setup.volInfo);

% studybyroi: contrasts x regions, values 1/0 for whether each contrast activates the region
% studybyset: contrasts x 1, values 1/0 for whether each contrast activates any region in the set

create_figure('Activation_proportions')

[n, k] = size(studybyroi);
prop_by_condition = sum(studybyroi) ./ n;                        % Proportion of contrasts activating each ROI
se = ( (prop_by_condition .* (1-prop_by_condition) ) ./ n ).^.5; % Standard Error based on binomial distribution

han = bar(prop_by_condition);
ehan = errorbar(prop_by_condition, se);

set(han, 'EdgeColor', [0 0 .5], 'FaceColor', [.3 .3 .6]);
set(ehan, 'Color', [0 0 .5], 'LineStyle', 'none', 'LineWidth', 3);
set(gca, 'XTick', 1:k, 'XLim', [.5 k+.5], 'XTickLabel', {r.shorttitle});
ylabel('Proportion of studies activating');

%% Other plots and tables

% Print a table of regions, separating local maxima
% There are other options for other types of tables, separating by
% subpeaks, lateralization, and other things.  We will leave that for later
% walkthroughs.

%tic 
%cl = Meta_cluster_tools('make_table', r, MC_Setup, true, false);
%toc

% Another desirable thing to do is to plot and analyze activation
% proportions in region as a function of study conditions (e.g., type of
% study).  
% We won't do this here, but to plot a bar plot of ROI counts for different
% conditions, try:
% [prop_by_condition,se,num_by_condition,n] = Meta_cluster_tools('count_by_condition',dat,Xi,w,doplot,[xnames],[seriesnames], [colors])



