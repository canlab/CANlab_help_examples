%% MULTIVARIATE_CONNECTIVITY_WALKTHROUGH
%  This helpfile contains a walkthrough of the steps need to complete a 
%    Multivariate Connectivity Analysis with fMRI Data
%
%  
%  This walkthrough was written by Marianne
%    at the Cognitive Affective Neuroscience Lab, CU Boulder
 
%% GENERAL INSTRUCTIONS
%  Prepare your data files for analysis
% ---------------------------------------------------------------
% Before you start, the CANlab_Core_Tools must be added to your path with
% subfolders. Besure that densityUtility is on path.
%
% Which dataset? - For now, Imagined Extinction, the Extinction Session of
% the IE group
 
addpath(genpath('/Volumes/engram/Resources/Respository/trunk/densityUtility/'));
 
%% BLOCK 1: Set up your files for analysis
% ---------------------------------------------------------------
 
% point to and navigate to your analysis directory
%  here we make you one
mkdir('MultivariateConnectivityWalkthrough');
cd('MultivariateConnectivityWalkthrough');
 
% specify your subject parent folders contain their fmri data
sub_dirs=filenames('/Volumes/engram/labdata/data/Imagination/Imaging/IE*EX/','absolute');
 
% specify your subject's preprocessed time course images
%  typically: swra*.nii
subjects=filenames('/Volumes/engram/labdata/data/Imagination/Imaging/IE*EX/Functional/Preprocessed/r2EXT/swraIE*.nii','absolute');
numsubs=length(subjects);
% sanity check
if numsubs ~= length(sub_dirs)
    warning('Mismatch number of subject timecourse images and sub_dirs')
end
 
% specify your nuisance covariates
%  if using our tools or spm this is typically noise_model_1.mat in the
%  spm_modeling folder
covs=filenames('/Volumes/engram/labdata/data/Imagination/Imaging/IE*EX/Functional/Preprocessed/r2EXT/spm_modeling/noise_model_1.mat','absolute');
 

% specify your regions of interest or a parcellation map
%  here, there were a priori regions of interest
mask_dir='/Volumes/engram/Users/marianne/Documents/MATLAB/MultiVarConnect/ROIs_2017_Walkthrough/';
roi_masks=filenames([mask_dir, '*']);num_masks=size(roi_masks,1);
%  use the region() tool to make clusters & store names
for r = 1:length(roi_masks)
    mask_split = strsplit(roi_masks{r},'/');
    mask_name = mask_split{end}(1:end-4);
    cl(r) = region(fmri_data(roi_masks{r}));
    names{r} = mask_name;
end

% add example of parcellation map
 
% save your set up files
save IE_MultiVar_Connect_SetUp_2017
 
%% BLOCK 2: Preprocess the raw signal
% ---------------------------------------------------------------
 
% Prepare the time series data for connectivity analysis by removing nuisance
%   variables and performing temporal filtering 
 
% specify your TR from data collection
TR=2;
 
% loop through each subject, canlab_connectivity_preproc()
for n = 1:numsubs
    dat = fmri_data(subjects{n});
    subject_dir = sub_dirs{n};
    load(covs{n});
    dat.covariates=R;
    
    %OPTIONS:
    % when you extract the roi information you can take the avg signal or
    % the pattern information
    [preprocessed_dat, roi_val] = canlab_connectivity_preproc(dat, 'vw', 'linear_trend','datdir',subject_dir, 'bpf', [.008 .25], TR, 'extract_roi', roi_masks, 'average_over','whole','no_plots');

    conn_dat{n}.preprocessed=preprocessed_dat;
    conn_dat{n}.rois=roi_val;
    conn_dat{n}.subj=subjects{n};
    conn_dat{n}.preprocessed.X = X;clear X;
    save MultiVarConnectivity_2017_walkthrough_IE -v7.3 conn_dat
end
 
%% BLOCK 3: OPTIONAL Apply predictors to the dat file
% ---------------------------------------------------------------
% specify predictors of interest (optional)
%  if using our tools or spm this is typically .mat in the
%  spm_modeling folder

pred=filenames('/Volumes/engram/labdata/data/Imagination/Imaging/IE*EX/Functional/Preprocessed/r2EXT/net_modeling/ext_cs_plus_all15.mat','absolute');
% remember these files start counting at 0 and are in seconds not TRs
% to use a predictor make sure it aligns in time with the preprocessed
% timecourse data, make it into an indicator function where stim on to b
% modelled is one and stim off is 0, then multiple the preprocessed data by
% the predictor

for n = 1:numsubs
%     ie_dat{n}.preprocessed.dat=(ie_dat{n}.preprocessed.dat'.*ie_dat{n}.preprocessed.X)';
    for r = 1:length(conn_dat{n}.rois)
        conn_dat{n}.rois{r}.dat=conn_dat{n}.rois{r}.dat.*conn_dat{n}.preprocessed.X;
    end
    save MultiVarConnectivity_2017_walkthrough_applyCSpcontrast_IE -v7.3 conn_dat    
end
 
% UPDATE THIS SECTION
 
%% BLOCK 4: Run the multivariate pattern connectivity analysis
% ---------------------------------------------------------------
% Connectivity and multivariate pattern-based prediction for multi-subject timeseries data
%   Currently runs predictive algorithm(s) on pairwise correlations among regions
 
 
%   :Features:
%     - Within-subject correlation matrices and 'random effects' statistics
%     - [optional] Prediction with LASSO-PCR/SVR/SVM of outcomes from pairwise connectivity
%     - Time-lagged cross-correlation options
%     - Graph theoretic measures
%     - [optional] Prediction with LASSO-PCR/SVR/SVM of outcomes from graph measures
%     - Can easily be extended to handle partial regression/correlation coefficients
 
%     **OUT:**
%          A structure containing subject correlation matrices, the mean
%          matrix, and raw and FDR-thresholded group matrix
%          Also contains matrices with [subjects x variables] pairwise
%          correlation elements and graph metrics
 
% Set up 'subject_grouping'
%   'subject_grouping' is a [subj x time]-length integer vector of which
%    observations belong to which subjects, e.g., [1 1 1 ... 2 2 2 ... 3 3 3 ...]'
%   The purpose it to label whose data is whose
clear sub_rois;
a=1;
for s = 1:size(conn_dat,2)
   for r = 1:size(conn_dat{s}.rois,1)
        sub_rois(:,r) = conn_dat{s}.rois{r}.dat;
   end
   ie_rois(a:a+size(sub_rois,1)-1,1:size(sub_rois,2))=sub_rois;
   a=a+size(sub_rois,1);
end
dat = ie_rois;
clear  subject_grouping;
% subj group [subj x time]
time=size(conn_dat{1}.rois{1}.dat,1);
a=1;
for s = 1:size(conn_dat,2)
    subject_grouping(a:a+time-1,1) = [ones(1,time)*s]';
    a=a+time;
end
 
%     **dat:**
%          concatenated data matrix of time points (t) within subjects x variables (e.g., ROIs)
%          [subj x time] x [variables]. That is, each row corresponds to a specific subject and
%          time, and each column corresponds to a variable.
 

OUT = canlab_connectivity_predict(dat, subject_grouping, 'partialr'); % could use outcome for pattern expression?
t =  OUT.stats.fdr_thresholded_tvalues;
[stats, handles] = canlab_force_directed_graph(t,'names', names,'rset', ieOUT.parcelindx,'cl',cl)
saveas(gcf, 'connect_graph.png');

%% ADDITIONAL OPTIONS
% If you are comparing two or more networks:
% 1. you can use 'predict' functions
%    to see if the networks are separable by a multivariate machine learning
%    classifier (range of choices)
% 2. you can extract metrics like the betweenness centrality of the nodes
%    or the node link strength and perform t-tests