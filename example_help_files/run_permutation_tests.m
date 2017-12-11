%% RUN_PERMUTATION_TESTS
% The help file shows you how to run permutation tests for nonparametrical
% significance testing for correlational data
% More information can be found here: https://docs.google.com/document/d/e/2PACX-1vTPQTLiYvKNUBpVc3PlRHDyonNaVLu-IAyEqyD8-M3jqvhVTPwvDi8wKNOVthNc6BqGxrcefyqrJSET/pub
%
% by marianne reddan, 2017

%% General instructions
% -----------------------------------------------------------------------
%
% Before you start, the CANlab_Core_Tools must be added to your path with
% subfolders. Otherwise, you will get errors.
%
% Part of the plotting (which is optional) calls upon the CosanlabToolbox,
% specifically the image_data object
%
% Examples of when you'd want to use this include:
%       testing differences between correlations of activity patterns 
%       for example: RSA
%
% The example data from this help file comes from this paper:
%   [insert citation for reappraisal success data
%
% CASE USE - high & low resilienc is the pfc correlated more strongly with
% amygdala in the high than the low
% its an individuals differences test
% not a common analysis
% voxel by voxel not really subj by subj
% dep version handles if they are dependent pairs
% ----------------------------------------------
%% Section 1: Load in data and quick view
% ----------------------------------------------
% Load in the image data (.nii or img) as an fmri_data object

% Establish that the example images are on path
% if not, you'll get an empty variable basedir
% basedir='/CanlabCore/CanlabCore/Sample_datasets/Wager_et_al_2008_Neuron_EmotionReg';
basedir = fileparts(which('con_00810001.img'));

% Load brain data
% Reappraise - Look Neg contrast images, one image per person
imgs = filenames(fullfile(basedir, 'con_*img'), 'char', 'absolute');

% Create the fmri_data object called "dat".  Store the contrast image data
% in it.
dat = fmri_data(imgs);

% Load mask
mask = which('VMPFC_display_mask.img');
mask = fmri_data(mask);
% Apply mask
dat = apply_mask(dat,mask);
    
% Quickly dispaly it and eyeball its properties
figure; plot(dat)
snapnow

pause;
% hit ENTER when you're ready to continue

close all;

% Set up grouping (this is a binary based on reapparaisal success
% assignment determined by if subj was above (2) or below (1) mean 
% behevioral data from Wager_2008_emotionreg_behavioral_data.txt
group=[1,1,2,1,1,1,1,2,1,2,1,1,1,2,2,1,1,2,2,1,1,2,1,1,2,1,2,2,2,2];
% sort the pattern data by group assignment
% you want this data matrix to be organized VOXELS (rows) by SUBJECT (col)
g1=[]; %N=17;
g2=[]; %N=13;
a=1;b=1; %counters
for i=1:length(group)
   if group(i) ==1
       g1(:,a)=dat.dat(:,i);
       a=a+1;
   elseif group(i) ==2
       g2(:,b)=dat.dat(:,i);
       b=b+1;       
   else 
       warning('issue with loop');
   end
end

% ----------------------------------------------
%% Visualize the pattern similarity correlations you will test
% ----------------------------------------------

% Note this section will require the CosanLabToolbox
pattern_dat=[g1 g2];

% Set up the correlation matrix, just for viewing
[R,P,RLO,RUP]=corrcoef(pattern_dat);
plot(image_data(R));title('Confusion Matrix - vmPFC')
% Visuall, look for difference popping out between the two groups
% There really aren't any, this example data wasn't collected for this
% purpose

% The question we are asking here -- is the pattern of activity in the
% vmPFC for this contrast DIFFERENT between the two groups (successful and
% unsuccessful reapparaisers)

% ----------------------------------------------
%% Set up and run the permutation tests
% ----------------------------------------------
% define the method you want to use
meth='taub';
%      String indicating the method for computing the correlation
%      coefficient, see correlation.m for details
%      DEFAULT: 'taub'
%      - Pearson's r.          Enter: {'r','pearson',[]}
%      - IRLS                  Enter: {'irls','robust'}
%      - Phi                   Enter: {'phi'}
%      - Spearman's rho        Enter: {'rho','spearman'}
%      - Kendall's Tau (a)     Enter: {'taua','kendalla'}
%      - Tau (b)               Enter: {'tau','kendall','taub','kendallb'}
%      - Gamma                 Enter: {'gamma','kruskal'}

% determine the number of permutations you want to run
nperms=10;
% define the conditions being compared, be sure to match the order in the
% dat file
conds=[ones(size(g1,2),1);ones(size(g2,2),1)*2];
% define the matrix of observations (n instances (SUBJECTS) by p variables (VOXELS))
% the dat matrix created previously for plotting needs to be transposed.
pattern_dat=[g1 g2];

% run it
OUT = correl_compare_permute(meth,pattern_dat,nperms,conds);

% NOTE: THIS WILL TAKE A LONG TIME AND LOTS OF COMPUTING POWER
% reduce the number of permutations to test

% ----------------------------------------------
%% Understanding the output
% ----------------------------------------------
% 