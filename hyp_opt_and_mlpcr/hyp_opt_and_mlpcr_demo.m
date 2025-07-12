
%% Multivariate prediction with Bayesian hyperparameter estimation
% This tutorial addresses two distinct but complementary problems. The
% first is on how to use the canlab multilevel PCR method for multivariate 
% analysis. The second is to address the use of Bayesian optimization for
% hyperparameter selection, which is especially well illustrated by
% multilevel PCR. If you only interested in the second you can skip ahead
% to "Gaussian process optimization of multilevel PCR hyperparameters"
% after reading this intro and the tutorial overview in the next section.
%
% Multilevel PCR is similar to PCR except it computes covariance of within
% subject variance and orthogonal between subject covariance components 
% separately, extracts eigenvectors and scores on those vectors for both
% sets of components and then performs a PCR style prediction using
% component scores as inputs to a regression equation. The result is a
% joint MVPA model which incorporates both elements, but also the option of
% obtaining models which only predict within or only between subject
% effects. This gives the model greater transparency than traditional PCR.
% Although multilevel PCR takes into account the block structure of data
% all parameter estimates are fixed effect estimates (e.g. the mean effect
% in one subject is estimated completely independently of other subjects).
% Generalizing to a mixed effects model is possible, but compuationally
% impractical.
%
% Multilevel PCR has two hyperparameters to optimize: the dimensions to
% retain at the within level and the dimensions to retain at the between
% level. Because between dimensions are orthogonalized with respect to
% within dimensions by design, the principal axes of the between dimensions
% change based on how many within dimensions are modeled and prediction 
% accuracy will vary in a complex way as a function of these variables. The 
% low number of parameters (<=5), large parameter space (wiDim x btDim = 
% 17205 hyperparameter combinations in this example) make this a good 
% candidate for optimization using Gaussian Processes, a bayesian method 
% of modeling a function probablistically.
%
% Bayesian optimization using Gaussian processes is provided by the
% bayesopt function in Matlab's Statistics and Machine Learning toolbox.
% The underlying mathematics are complex, but the principle is simple. If
% you perform grid sampling to map out a hyperparameter space, but don't
% sample exhaustively you have to interpolate between the points you have
% sampled to identify any minima or maxima in places you haven't seen.
% Gaussian processes provide a way of interpolating in a nonlinear way.
% Additionally there's uncertainty in the points you have estimated because
% any time you estimate model performance the cross validation fold slicing
% you pick will affect your performance, so grid sampling results are stochastic. 
% Gaussian processes are able to incorporate this error when computing
% interpolations. What makes it Bayesian is the use of a prior smoothness
% function which is well suited for hyperparameter optimization in machine
% learning, and basically supposes that underlying loss function will be
% twice differentiable at any particular point, which is just a fancy way
% of formalizing a particular notion of "smooth". Additionally, Bayesian
% optimization proceeds iteratively, meaning that the current best estimate
% can be used to inform the best future point to sample, and a point is
% selected which will maximally reduce model uncertainty, thus making the
% sampling "intelligent" and more efficient than grid sampling.
%
% We will use two datasets. The first comes from an experiment designed to 
% study race differences in pain report. There are published effects that
% distinguish different racial groups (hispanic, white and black), and the
% experimental design also involves variation in stimulus intensity within
% individuals (three stimulus levels, 47, 48 and 49C) so we have good reason
% to suspect both within and between subject differences might be captured 
% by an appropriate model. The second dataset is from a pain rating task
% with masked emotional faces. This second study was designed to minimize
% between subject differences by calibrating stimulus intensity for each
% subject, so we expect all experimental effects to be at the within level,
% meaning that being able to remove between effects selectively may give us
% a superior multivariate outcome. In both cases the datasets we're working
% with are "first level" statistical maps, estimated at the single stimulus
% event level and quantify the mean BOLD response during that stimulus
% event relative to the scan baseline. We begin by averaging results within
% stimulus level, which results in statistical maps very similar to those
% produced by a subject-level GLM analysis of mean BOLD response for each
% stimulus level (maps obtained by this averaging are nearly 
% indistinguishable from those produced by formally modeling the entire
% stimulus level by a single contrast vector in a GLM).
%
% Neither of these data are publically available as of the time of this 
% writing, but are available in the canlab single trials repository for 
% members of the lab to work with. If following this tutorial without
% access to these datasets you can try using the public bmrk3 dataset
% available through canlabCore by calling bmrk3 = load_image_set('bmrk3').
% subject_id is then in bmrk3.additional_info.subject_id instead of in the
% metadata_table fields used here.
%
% References:
%
% For Bayesian hyperparameter optimization,
% Snoek, et al. (2012) "Practical bayesian optimization of machine learning
% algorithms". Advances in Neural Information Processing Systems
% 
% For theory regarding Gaussian Process regression,
% Rasmussen and Williams. (2006) Gaussian process regression for machine 
% learning. The MIT Press. gaussianprocess.org/gpml
% 
% For a description of the multiracial dataset and experimental details,
% Losin E, et a. (2019). "Neural and sociocultural mediators of ethnic
% differences in pain". Nature Human Behavior.
%
% For a description of the calibrated dataset and experimental details,
% Wager T, et al. (2013). "An fMRI based neurological signature of physical
% pain." New England Journal of Medicine.
% Atlas L, et al. (2014) "Brain mediators of effects of noxious heat on
% pain." Pain.

%% Overview
% We begin with the multiracial pain dataset and first, fit an 
% unregularized PCR and multilevel PCR model (i.e. use all PCA dimensions) 
% to demonstrate their equivalence.
%
% Second we will show how multilevel PCR allows us to obtain patterns which
% predict between and within subjct pain variance. This comes in two parts.
% First we illustrate the patterns, then we analyze their sensitivity and
% specificity for the main effects of interest. It will be shown that
% within subject patterns are sensitive but not specific, while between
% subject patterns are somewhat sensitive but specific.
% 
% Third we will take a brief detour to discuss the nature of cross
% validation prediction accuracy by exploring a null model to provide
% perspective on the above.
%
% Next we will move on to hyperparameter optimization using bayesopt(). We
% will obtain an optimal model in the multiracial pain dataset and show that
% optimization justifies our original decision to retain all between and
% within components.
%
% To better illustrate the power of hyperparameter optimization we will use
% the matched pain dataset, obtain an unregularized model and an optimized
% model, and compare the differences.
%
% Finally we will use nested cross validation to estimate the
% generalization performance of bayesopt() optimized multilevel PCR models 
% in novel datasets, using the matched pain dataset.

%% Setup environment

close all; clear all

addpath(genpath('/projects/bope9760/spm12')); % canlabCore dependency
addpath(genpath('/projects/bope9760/CanlabCore'));
% We don't use any functions from canlab_single_trials, except for data
% importing functions.
addpath(genpath('/projects/bope9760/software/canlab/canlab_single_trials/'))
% we use a common data repository to share this resource across HPC users,
% but if not found it will be automatically downloaded by load_image_set()
% if you have the canlab_single_trials repository. Otherwise the bmrk5pain
% data is unavailable to you.
addpath(genpath('/work/ics/data/projects/wagerlab/labdata/projects/canlab_single_trials_for_git_repo/'))

%% load multiracial dataset

bmrk5pain = load_image_set('bmrk5pain');

% shouldn't be necessary if I'd done a better job cleaning this data for 
% the single trials repository, but I left the job unfinished in this 
% respect and data still has some nan voxels lingering as of this writing
bmrk5pain.dat(isnan(bmrk5pain.dat)) = 0;

% let's get rid of bad trials
bmrk5pain = bmrk5pain.get_wh_image(bmrk5pain.metadata_table.vif < 2.5);
bmrk5pain = bmrk5pain.get_wh_image(~isnan(bmrk5pain.Y));

% convert subjct_id to numeric
[~,~,subject_id] = unique(bmrk5pain.metadata_table.subject_id,'stable');
uniq_subject_id = unique(subject_id);
n_subj = length(uniq_subject_id);

% Lets average our data within stimulus level to speed up this tutorial by
% fitting models to smaller datasets. In principle there's no reason this 
% is necessary, and inflates our impression of how well our models do
% (because we're throwing out all between trial variance at the
% within-stimulus level).

newdat = {};
for i = 1:n_subj
    this_idx = find(uniq_subject_id(i) == subject_id);
    this_dat = bmrk5pain.get_wh_image(this_idx);
    
    T = this_dat.metadata_table.T;
    lvls = unique(T);
    n_lvls = length(lvls);
    
    for j = 1:n_lvls
        newdat{end+1} = mean(this_dat.get_wh_image(lvls(j) == T));
    end
end
newdat = cat(newdat{:});

varLost = 1 - sum((newdat.Y - mean(newdat.Y)).^2) / sum((bmrk5pain.Y - mean(bmrk5pain.Y)).^2);
fprintf('Discarding %0.3f%% of outcome variance\n', varLost)

bmrk5pain = newdat; clear newdat;


% zscore images if desired. We don't do it, but I mention this here to
% emphasize that any data averaging should be performed BEFORE image 
% scaling.(

%% prep metadata for cross validation
% there are number of reasons to manually specify cross validation fold
% membership rather than letting fmri_data/predict do it. First we're
% comparing two algorithms, so let's not introduce fold membership related
% variance by using the same folds in both cases. Second I'm not sure
% fmri_data/predict respects subject membership, it may, but I know it will
% if I tell it what the fold membership is myself. I use cvpartition2 which
% is a class that's a part of canlab_single_trials, but it's not hard to do
% manually either. fold_labels is just a vector of length size(bmrk5pain.dat,2)
% where each entry is either a 1,2,3,4 or 5, indicating fold membership of
% corresponding entries in bmrk5pain. Each subject belongs to a single fold to
% retain indepencende across independence and test sets.

[~,~,subject_id] = unique(bmrk5pain.metadata_table.subject_id,'stable');
uniq_subject_id = unique(subject_id);
n_subj = length(uniq_subject_id);

kfolds = 5;
cv = cvpartition2(ones(size(bmrk5pain.dat,2),1), 'KFOLD', kfolds, 'Stratify', subject_id);
fold_labels = zeros(size(bmrk5pain.dat,2),1);
for j = 1:cv.NumTestSets
    fold_labels(cv.test(j)) = j;
end

%% Fit MVPA model using PCR
% We fit a PCR model using all PCA dimensions to demonstrate convergence
% beween PCR and multilevel PCR models.

[pcr_cverr, pcr_stats, pcr_optout] = bmrk5pain.predict('algorithm_name','cv_pcr',...
    'nfolds',fold_labels);
fprintf('PCR r = %0.3f\n', corr(pcr_stats.yfit, bmrk5pain.Y));

figure
line_plot_multisubject(bmrk5pain.Y, pcr_stats.yfit, 'subjid', subject_id);
xlabel({'Observed Pain','(stim level average)'}); ylabel({'PCR Estimated Pain','(cross validated)'})

pcr_model = bmrk5pain.get_wh_image(1);
pcr_model.dat = pcr_optout{1}(:);
figure;
pcr_model.montage;

%% Fit MVPA model using multilevel PCR
% Multilevel PCR when used without any dimensionality reduction gives the 
% same solution as PCR (if PCR is also without dimensionality reduction).
% The results here shouldn't differ considerably from the above, but by 
% using multilevel PCR we will also get within and between model
% components.
%
% Note the specification of a subjIDs parameter. cv_mlpcr requires this.
%
% Note the performance penalty relative to PCR. It's not substantial but 
% it's not negligible eithr.

% overall model prediction
[mlpcr_cverr, mlpcr_stats, mlpcr_optout] = bmrk5pain.predict('algorithm_name','cv_mlpcr',...
    'nfolds',fold_labels,'subjIDs',subject_id);

fprintf('multilevel PCR r = %0.3f\n',corr(mlpcr_stats.yfit, bmrk5pain.Y));

figure
subplot(1,2,1)
line_plot_multisubject(pcr_stats.yfit, mlpcr_stats.yfit, 'subjid', subject_id);
xlabel({'PCR model prediction'}); ylabel('Multilevel PCR model prediction');
axis square
subplot(1,2,2);
plot(pcr_optout{1}(:),mlpcr_optout{1}(:),'.');
lsline;
xlabel('PCR model weights'); ylabel('Multilevel PCR model weights');
axis square

% let's now get the variance explained by just the between component or
% just the within component. These functions call the same thing under the
% hood, but simply perform cross validation using ONLY between or within
% subject models.

[mlpcr_bt_cverr, mlpcr_bt_stats] = bmrk5pain.predict('algorithm_name','cv_mlpcr_bt',...
    'nfolds',fold_labels,'subjIDs',subject_id, 'verbose', 0);
pred_bt = mlpcr_bt_stats.yfit;

[mlpcr_wi_cverr, mlpcr_wi_stats] = bmrk5pain.predict('algorithm_name','cv_mlpcr_wi',...
    'nfolds',fold_labels,'subjIDs',subject_id, 'verbose', 0);
pred_wi = mlpcr_wi_stats.yfit;


fprintf('Between subject PCR components r = %0.3f\n', corr(mlpcr_bt_stats.yfit, bmrk5pain.Y));
fprintf('Within subject PCR components r = %0.3f\n', corr(mlpcr_wi_stats.yfit, bmrk5pain.Y));

figure
subplot(1,2,1)
line_plot_multisubject(bmrk5pain.Y, pred_bt, 'subjid', subject_id);
xlabel({'Observed pain'}); ylabel('Between subject components'' prediction');
axis square
subplot(1,2,2)
line_plot_multisubject(bmrk5pain.Y, pred_wi, 'subjid', subject_id);
xlabel({'Observed pain'}); ylabel('Within subject components'' prediction');
axis square

%% Sensitivity and specificity of between and within subject patterns
% above we've simply plotted the predictions on the within and between
% compoents in each case, but it's hard to see how well they satisfy their
% design objectives. In the training data the within components are
% selected such that IF they predict any between subject pain variance they
% do so using representations of pain which characterize within subject variance.
% Meanwhile the between subject components are designed to be invariant
% within subject and only predict between subject pain. To see if these
% objectives are satisfied we have to subdivide both observed pain and each
% pain prediction into within and between components, so let's do that and
% plot the results.
%
% In the data presented below we have I subjects {1, 2, ..., I}, each with 
% J stimulus levels each {1, 2, ..., J}. J may differ between subjects 
% (but mostly doens't). Pain_i_j means pain rating from subject i on 
% stimulus level j. Pain_i_. means pain rating from subject i averaged 
% overall all J stimulus levels. The same notation is used for predictions.
%
% We can see that within patterns do predict between subject pain differences.
% Within patterns most likely represent the effects of afferent input,
% because our within subject data varies in stimulus intensity, and
% averaging within stimulus intensity means that this dimension is likely a
% very salient one in our within data. However differences in afferent
% input may exist between subjects too due to differences in peripheral
% sensitivity or tissue thermal conductance (the stimulus intensities are
% the same across subjects).
%
% Meanwhile between subject differences vary between subjects but do not
% predict within subject effects. The within subject effects are negatively
% predicted, which may see a bit confusing, but this is actualy what's 
% expected from a cross validated null model. We'll save this for the next 
% section. For now just note that it doesn't predict within effects. 
% Thus the within subject variance predicted by the between subject 
% pattern is most likely noise. If we look at the mean between pattern 
% predictions for each subject we see that these predict the mean pain 
% report for each subject.
%
% Thus we have successfully used multilevel PCR to break down a PCR model
% into a within subject and between subjct predictive pattern.
%
% Standard Errors are illustrated on between effcts plots.

% let's get the within and between pain components using a centering matrix 
% to demean or average within subject. This is faster and easier than 
% implementing a for loop every time, because matlab has fast matrix math 
% and slow for loops.
cmat = []; % within subject centering matrix
mumat = []; % within subject averaging matrix
n = [];
for i = 1:n_subj
    this_blk = uniq_subject_id(i);
    this_n = sum(this_blk == subject_id);
    n = [n(:); this_n*ones(this_n,1)];
    cmat = blkdiag(cmat, eye(this_n) - 1/this_n);
    mumat = blkdiag(mumat, ones(this_n)*1/this_n);
end
[~,exemplar] = unique(subject_id);

Y_wi = cmat*bmrk5pain.Y;
Y_bt = mumat*bmrk5pain.Y;

pred_bt_bt = mumat*pred_bt;
pred_bt_wi = cmat*pred_bt;

pred_wi_bt = mumat*pred_wi;
pred_wi_wi = cmat*pred_wi;

% compute standard standard errors on subject mean predictions and ratings
v_pred_bt = (mumat*(pred_bt_wi.^2)./n).^0.5; 
v_pred_wi = (mumat*(pred_wi_wi.^2)./n).^0.5; 
v_Y_bt = (mumat*(Y_wi.^2)./n).^0.5;

% get rid of redundant rows
Y_bt = Y_bt(exemplar);
v_Y_bt = v_Y_bt(exemplar);
pred_bt_bt = pred_bt_bt(exemplar);
v_pred_bt = v_pred_bt(exemplar);
pred_wi_bt = pred_wi_bt(exemplar);
v_pred_wi = v_pred_wi(exemplar);

figure
subplot(2,2,1);
[~,p] = corr(Y_wi, pred_wi_wi);
line_plot_multisubject(Y_wi, pred_wi_wi,'subjid', subject_id);
title({'Within Pattern vs. Pain',sprintf('p = %0.3f',p)});
ylabel({'Prediction within subject','Pred_i_j - Pred_i_.'})
xlabel({'Pain within subject','Pain_i_j - Pain_i_.'})

subplot(2,2,2); hold off;
[~,p] = corr(Y_bt, pred_wi_bt);
plot(Y_bt, pred_wi_bt,'b.'); lsline
hold on;
errorbar(Y_bt, pred_wi_bt, v_pred_wi, v_pred_wi, v_Y_bt, v_Y_bt,'ob')
title({'Within Pattern vs. Pain',sprintf('p = %0.3f',p)});
ylabel({'Mean subject prediction','Pred_i_.'})
xlabel({'Mean subject pain','Pain_i_.'})

subplot(2,2,3);
[~,p] = corr(Y_wi, pred_bt_wi);
line_plot_multisubject(Y_wi, pred_bt_wi,'subjid', subject_id);
title({'Between Pattern vs. Pain',sprintf('p = %0.3f',p)});
ylabel({'Prediction within subject','Pred_i_j - Pred_i_.'})
xlabel({'Pain within subject','Pain_i_j - Pain_i_.'})

subplot(2,2,4);
[~, p] = corr(Y_bt, pred_bt_bt);
hold off
plot(Y_bt, pred_bt_bt,'b.'); lsline
hold on;
errorbar(Y_bt, pred_bt_bt, v_pred_bt, v_pred_bt, v_Y_bt, v_Y_bt,'ob')
title({'Between Pattern vs. Pain',sprintf('p = %0.3f',p)});
ylabel({'Mean subject prediction','Pred_i_.'})
xlabel({'Mean subject pain','Pain_i_.'})

pos = get(gcf,'Position');
set(gcf,'Position',[pos(1:2), 1205, 785]);

%% Null prediction
% Notice how the between subjects components do not predict within subject
% pain well. The prediction is in fact significantly negative! How is this
% possible?
%
% In traditional regression analysis a null (intercept only) model shows a 
% correlation of 0 not negative correlations. However in a cross validated
% context the null intercept only model shows a ngative correlation. This is 
% because training set means are negatively biased estimates of the test 
% set means, and the bias is especially severe for small datasets.
% 
% Let's see what the null model looks like.

pred_null = zeros(length(bmrk5pain.Y), 1);
for i = 1:cv.NumTestSets
    training_fold = cv.training(i); % Binary vector of length(nsf.Y) indicating membership in this training fold
    test_fold = cv.test(i);
    pred_null(test_fold) = mean(bmrk5pain.Y(training_fold)); % intercept only model
end

fprintf('Null model r=%0.3f\n', corr(pred_null, bmrk5pain.Y));


%% Illustrate within and between subject predictive patterns
% while PCR and multilevel PCR can provide the same overall predictive
% maps, multilevel PCR is able to distinguish parts of the map that predict
% within subject variance from those that only predict between subject
% variance.
%
% Visualizing these maps is facilitated by bootstrap correcting voxels so
% that only stable model weights are illustrated. When making predictions on
% novel data the entire model will be used, but when evaluating predictive
% performance using cross validation, model weights will change across
% cross validation folds. Therefore to understand what's driving estimates
% of predictive performance it's helpful to look at bootstrap corrected 
% maps since they illustrate the voxels most likely to be inolved in models
% across cross validation folds.
%
% fmri_data/predict has a built in bootstrapping feature for data
% prediction, but the results it gives us for multilevel PCR are invalid.
% It uses matlab's bootstrp function which isn't block aware. It just
% resamples individual images. But we don't want to resample images, we 
% want to resample blocks (subjects), because our images are dependent 
% within block, only our blocks are independent from one another, and 
% bootstrap estimates assume independent data. Therefore we implement 
% bootstrapping by hand.
%
% I also make some improvements on the predict bootstrapping model by
% incorporating bias correction and acceleration into my bootstrap
% estiamtes. The actual implementation exceeds the scope of this tutorial,
% so I've included them as functions at the end of the file, sort of like
% an appendix. For now we just have a function BCa that gives us a list of
% significant voxels we need at each level of our model.

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
parpool(16);

% this is our bias corrected acclerated bootstrapping procedure using 500
% bootstraps at an alpha = 0.05 voxel-wise level.
sig = BCa(500, 0.05, bmrk5pain, subject_id, 'verbose', 0);

map1 = bmrk5pain.get_wh_image(1);
map1.dat = mlpcr_optout{1}.*sig{1};
map1.dat = map1.dat(:);

map2 = bmrk5pain.get_wh_image(1);
map2.dat = mlpcr_optout{2}.*sig{2};
map2.dat = map2.dat(:);

map3 = bmrk5pain.get_wh_image(1);
map3.dat = mlpcr_optout{3}.*sig{3};
map3.dat = map3.dat(:);

map = cat(map1, map2, map3);
map.montage('trans');

%% Recovering source signals
% Although model voxel patterns are informative for telling us how the
% model is working, and assuring us that something sensible is happening,
% they are difficult to interpret because they reflect a combination of
% signal and noise, the idea being that predictive algorithms attempt to
% retrieve models which are orthogonal to noise sources. This makes it
% difficult to ascertain the biological origin of many of the signals of
% interest we're looking at. We can recover the "generative model"
% suggested by our PCR models (both multilevel and non-multilevel) by
% looking at our data covariance with the PCA scores. We will show the
% results from PCR and the results from multilevel PCR

% Multilevel PCR gives us all the information we need in the optout
% argument from predict
[~,~,optout] = bmrk5pain.predict('algorithm_name', 'cv_mlpcr', 'nfolds',0,...
    'subjIDs',subject_id, 'verbose', 0);

sc_b = optout{6}; % between scores
sc_w = optout{8}; % within scores
b = optout{9};
b(1) = []; % drop intercept
b_b = b(1:size(sc_b,2));
b_w = b(size(sc_b,2) + (1:size(sc_w,2)));
sc = [sc_b, sc_w];

% this only works because all components are orthogonal, otherwise formula
% is more complex
src_X = bmrk5pain.dat*(sc*b);
bt_src_X = bmrk5pain.dat*(sc_b*b_b);
wi_src_X = bmrk5pain.dat*(sc_w*b_w);

src = bmrk5pain.get_wh_image(1:3);
src.dat = [src_X, bt_src_X, wi_src_X];

src.montage('trans');

%% Interim Conlcusions
% It looks like multilevel PCR is able to pick apart between and within
% subject components. There area few lingering comments worth making
%
% Within subject pain predictions differ between subjects. This between
% subject variance is likely noise, and there are concievable scenarios
% where the only function of the between subject components are to correct
% for this noise, rather than to tell us anything unique. In practice you
% should check for this possibility by inspecting the correlation between
% within and between subject components. The closer it is to zero, the
% better. A negative correlation though would indicate this kind of 
% compensatory behavior. The analysis was not performed here.
%
% Additionally, one might think that because these spurious between subject
% predictions are noise in the within model and the within variance is
% spurious in the between model, that perhaps you could take your model
% predictive fractions (e.g. your within models predictions and your
% between model's predictions) and simply denoise them by centering or
% averaging within subject (respectively) and then adding the results.
% Whether or not this will work is unclear, but I suspect for it to work
% one would need to incorporate this procedure into their loss function
% estimation during model dimensionality optimization (optimization, but 
% not this specific centering/demeaning tactic, is discussed below). It's a
% direction for future research.

%% Gaussian process optimization of multilevel PCR hyperparameters
% Better performing models may be obtained using optimized
% hyperparameters. Hyperparameters control model regulizarization,  and 
% estimates will reduce variance in prediction error (i.e. improve 
% prediction performance),  at the expense of more biased model and more
% computation time. Here we  demonstrate how to use Matlab's Bayesian 
% hyperparameter optimization to obtain optimized multilevel PCR models. 
% The parameters we optimize are the within and between dimensions, and the 
% performance measure we use is 1-r, where r is the correlation between 
% model predictions and observed pain. The same approach could work for 
% other algorithms with other hyperparameters and different loss functions.
%
% We instruct bayesopt to display its estimate of the loss function, which
% in practice will be updated at every step of the algorithm, but in this
% tutorial you will only be able to see the final result (I think).
%
% This approach cannot simultaneously give us an estimate of 
% generalization performance (we'll do that later using nested cross 
% validation) but it can give us an optimized model.
%
% The same approach can be used to optimize PCR, but comparison of
% algorithm performance exceeds the scope of this tutorial so PCR
% regularization is not pursued. However, it should be noted that 
% regularized multilevel PCR will yeild different solutions than those 
% obtained with regularized PCR. For the curious, performance of PCR and
% multilevel PCR don't seem to be all that different. Multilevel PCR might
% be slightly better, but it's a very slight improvement if anything. The
% reason to use multilevel PCR is if you want to interpret between and
% within subject effects specifically, not to obtain more predictive 
% models.

%% optimized multilevel PCR model for multiracial pain dataset
% We will show that bayesian optimization justifies the use of all
% principal components when modeling pain outcomes in the multiracial pain
% dataset. This is a bit boring, so after showing this result we will move
% on to the matched pain dataset for something more interesting. This
% section is instructive because it has most of the commentd implementation
% details.

% define hyperparameter search space by finding maximum df you'll have for 
% any training fold
max_subj_per_fold = length(unique(subject_id)) - floor(length(unique(subject_id))/5);
min_subj_per_fold = length(unique(subject_id)) - ceil(length(unique(subject_id))/5);
minTrainingSize = length(fold_labels) - max(accumarray(fold_labels,1));

% optimizableVariable is a datatype used by bayesOpt(). bayesOpt draws from
% this space and submits a table with one entry per column to an objective
% function which must return a loss estimate over which bayesOpt will
% optimize these variables. Each column will be named 'wiDims' or 'btDims'
% as specified below.
dims_wi = optimizableVariable('wiDims', [0, minTrainingSize - max_subj_per_fold - 1], 'Type', 'integer');
dims_bt = optimizableVariable('btDims', [0, min_subj_per_fold - 1], 'Type', 'integer');

% makes sure there's at least one dimension in use and we're not
% just testing a null model. Sometimes you want for the null model to be 
% tested during optiization, othertimes you may not. Think it through and
% ask yourself if it would mean anything to you if after optimizing the 
% best parameters indicated a null model was best. Whether or not there is 
% predictive information in our data is not the question of this tutorial, 
% it's a demonstration of model application, so I want to make sure we're 
% actually using the multilevel PCR solution, and not a null solution. 
% Hence this constraint.
%
% Note invocation of table column headers by name.
constraint=@(x1)(x1.btDims + x1.wiDims > 0);

% There are two ways to define objective functions. One is inline using
% "anonymous functions", the other is with function files. We use a
% combination for flexiblity and readability. The function definition is at
% the end of this script
objfxn = @(dims1)(lossEst(dims1, bmrk5pain));

% The bayesopt optimizer selects search coordinates based on the current
% best estimate of the function, so you you want parallel computations to
% be a relatively small fraction of your total iter count. In an extreme
% situation where your iter count is equal to your parallel worker instances
% you're just randomly sampling points rather than selecting any
% intelligently. At the other extreme where you run things serially each 
% point will be selected intelligently based on all previously observed 
% solutions, but things will run slowly. We use 30 iterations, and we'll 
% run 4x parallel instances which is a good balance of these considerations.
if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
parpool(4)
hp_mlpcr = bayesopt(objfxn,[dims_bt,dims_wi],'XConstraintFcn',constraint,...
    'AcquisitionFunctionName','expected-improvement-plus','MaxObjectiveEvaluations',30,...
    'UseParallel',1);

% we won't bother fitting the full model, since it's nothing new, but
% commented out below is the code that would have done it. Note the way the
% hyperparameters are retrieved from the hp_mlpcr variable.
%{
optDims = table2array(hp_mlpcr.XAtMinEstimatedObjective);

mlpcr_opts = {'numcomponents', optDims, 'useparallel', 0};

% get full optimized model
[~, ~, opt_mlpcr_optout] = bmrk5pain.predict('algorithm_name','cv_mlpcr',...
    'nfolds', 0, 'subjIDs',subject_id, mlpcr_opts{:});
%}

%% load matched pain dataset
clear all; close all;
nsf = load_image_set('nsf');

% shouldn't be necessary if I'd done a better job cleaning this data for 
% the single trials repository, but I left the job unfinished in this 
% respect and data still has some nan voxels lingering as of this writing
nsf.dat(isnan(nsf.dat)) = 0;

% let's get rid of bad trials
nsf = nsf.get_wh_image(~isnan(nsf.Y));

% convert subjct_id to numeric
[~,~,subject_id] = unique(nsf.metadata_table.subject_id,'stable');
uniq_subject_id = unique(subject_id);
n_subj = length(uniq_subject_id);

% Lets average our data within stimulus level to speed up this tutorial by
% fitting models to smaller datasets. In principle there's no reason this 
% is necessary, and inflates our impression of how well our models do
% (because we're throwing out all between trial variance at the
% within-stimulus level).

newdat = {};
for i = 1:n_subj
    this_idx = find(uniq_subject_id(i) == subject_id);
    this_dat = nsf.get_wh_image(this_idx);
    
    T = this_dat.metadata_table.T;
    lvls = unique(T);
    n_lvls = length(lvls);
    
    for j = 1:n_lvls
        newdat{end+1} = mean(this_dat.get_wh_image(lvls(j) == T));
    end
end
newdat = cat(newdat{:});

varLost = 1 - sum((newdat.Y - mean(newdat.Y)).^2) / sum((nsf.Y - mean(nsf.Y)).^2);
fprintf('Discarding %0.3f%% of outcome variance\n', varLost)

nsf = newdat; clear newdat;

%% optimized multilevel PCR model for matched pain dataset
% Here we will fit an optimized PCR model to a matched pain dataset. We do
% not expect substantial between subject effects, so let's see what our
% model optimization is able to deduce about this from the data. For
% explanations of what this code is doing, refer to the previous section.

% get new cross validation folds. We don't actually use the folds here, but
% they're useful for determining what minimum fold size is, which we need
% for establishing the boundaries of the search space since fold size
% affects degrees of freedom and the maximum dimensions we can retain.

[~,~,subject_id] = unique(nsf.metadata_table.subject_id,'stable');
uniq_subject_id = unique(subject_id);
n_subj = length(uniq_subject_id);

kfolds = 5;
cv = cvpartition2(ones(size(nsf.dat,2),1), 'KFOLD', kfolds, 'Stratify', subject_id);
fold_labels = zeros(size(nsf.dat,2),1);
for j = 1:cv.NumTestSets
    fold_labels(cv.test(j)) = j;
end

% perform optimization

max_subj_per_fold = length(unique(subject_id)) - floor(length(unique(subject_id))/5);
min_subj_per_fold = length(unique(subject_id)) - ceil(length(unique(subject_id))/5);
minTrainingSize = length(fold_labels) - max(accumarray(fold_labels,1));

dims_wi = optimizableVariable('wiDims', [0, minTrainingSize - max_subj_per_fold - 1], 'Type', 'integer');
dims_bt = optimizableVariable('btDims', [0, min_subj_per_fold - 1], 'Type', 'integer');

constraint=@(x1)(x1.btDims + x1.wiDims > 0);
objfxn = @(dims1)(lossEst(dims1, nsf));

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
parpool(4)
hp_mlpcr = bayesopt(objfxn,[dims_bt,dims_wi],'XConstraintFcn',constraint,...
    'AcquisitionFunctionName','expected-improvement-plus','MaxObjectiveEvaluations',30,...
    'UseParallel',1);

optDims = table2array(hp_mlpcr.XAtMinEstimatedObjective);

mlpcr_opts = {'numcomponents', optDims, 'useparallel', 0};

% get full optimized model
[~, ~, opt_mlpcr_optout] = nsf.predict('algorithm_name','cv_mlpcr',...
    'nfolds', 0, 'subjIDs',subject_id, mlpcr_opts{:});
%{
%% Illustration of bootstrap maps for optimized multilevel PCR models
% Here we plot the bootstrap corrected maps again, as for the case where we
% used all PCA dimensions, only now we've optimized our MVPA dimensiosn and
% presumably denoised our models a bit, so our new maps may look somewhat 
% different.

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
parpool(16);

% use kernel density estimation of bias corrected accelerated bootstrap to
% obtain p-values using 500 resamples
[sig, w] = BCa(500, 0.05, nsf, subject_id, mlpcr_opts{:});

map1 = nsf.get_wh_image(1);
map1.dat = opt_mlpcr_optout{1}.*sig{1};
map1.dat = map1.dat(:);

map2 = nsf.get_wh_image(1);
map2.dat = opt_mlpcr_optout{2}.*sig{2};
map2.dat = map2.dat(:);

map3 = nsf.get_wh_image(1);
map3.dat = opt_mlpcr_optout{3}.*sig{3};
map3.dat = map3.dat(:);

map = cat(map1, map2, map3);
map.montage('trans');

%% Estimate generalization performance of optimized models.
% Hyperparameter optimization should be conceptualized as a model fitting
% procedure, so even though cross validation is used as part of the
% optimization routine (see lossEst() below) that cross validation doesn't
% estimate the performance of the optimized model. Only once the optimized
% model has been fit can its performance be tested on an independent test
% set, therefore to estimate generalization performance of optimized models
% one must use nested cross validation. In the outer loop K different
% optimized models are fit to K different training sets, and tested on K
% hold out sets. The inner cross validation loops are used internally by
% the fitting routine to select optimal hyperparameters, based on estimates
% obtained on each outer training fold and complete inner loop is 
% run on each iteration of the outer loop. Nexted cross validation will
% show better estimated model performance with optimization than we can
% obtain without optimization in the unregularized case for the matched
% pain dataset.
%
% The inner fold is already taken care of by lossEst() below, which uses
% fmri_data/predict's built in cross validation, so we only need to take
% care of the outer loop here.
%
% In addition to testing the full model performance, we're also going to
% test the performance of only the within and only the between part in thie
% next section.


% what follows simply copies what we used for model fitting in the last
% section. Only now we put it in a loop and do it K times on different 
% training data splits. Comments are ommitted for brevity. See multiracial 
% pain optimized model fitting above for details on the mechanics.
%
% Notice how each training fold gives a slightly different estimate of the
% optimum hyperparameters. This imprecision in the loss function estimate
% is the reason we need to do nested cross validation. Any particular
% optimum function will involve hyperparameters which are biased in favor
% of the data they were optimized on.
%
% This runs relatively quickly here because we've averaged all our data
% into stimulus-level observations, but for larger datasets this can
% lead to considerable overhead because it requires fitting at least 
% k + k^2 models (more if using fmri_predict on the inner loop, since it
% fits a superfluous full model on every cv iteration)

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
parpool(4)

[pred, pred_bt, pred_wi] = deal(zeros(length(nsf.Y),1));
for k = 1:kfolds
    training = nsf.get_wh_image(fold_labels ~= k);
    test = nsf.get_wh_image(fold_labels == k);
    
    training_sid = training.metadata_table.subject_id;
    [~,~,training_sid] = unique(training_sid,'stable');
    
    max_subj_per_fold = length(unique(training_sid)) - floor(length(unique(training_sid))/kfolds);
    min_subj_per_fold = length(unique(training_sid)) - ceil(length(unique(training_sid))/kfolds);
    minTrainingSize = length(fold_labels) - max(accumarray(fold_labels,1));

    dims_wi = optimizableVariable('wiDims', [0, minTrainingSize - max_subj_per_fold - 1], 'Type', 'integer');
    dims_bt = optimizableVariable('btDims', [0, min_subj_per_fold - 1], 'Type', 'integer');

    constraint=@(x1)(x1.btDims + x1.wiDims > 0);

    % note objFxn is given training data here
    objfxn = @(dims1)(lossEst(dims1, training));

    % note changes with verbose and PlotFcn to suppress spurious output
    % Just take it for granted that each iteration estimates a different
    % set of hyperparameters.
    hp_mlpcr = bayesopt(objfxn,[dims_bt,dims_wi],'XConstraintFcn',constraint,...
        'AcquisitionFunctionName','expected-improvement-plus','MaxObjectiveEvaluations',30,...
        'UseParallel',1,'verbose',0,'PlotFcn',{});
    
    hp = table2array(hp_mlpcr.XAtMinEstimatedObjective);
    
    fprintf('Optimum at [%d,%d] between and within dimensions (resp).\n',hp);
    
    [~, ~, fold_model] = training.predict('algorithm_name','cv_mlpcr',...
        'nfolds',0,'subjIDs',training_sid,'numcomponents', hp, 'verbose', 0);
    
    pred(fold_labels == k) = test.dat'*fold_model{1} + fold_model{4};
    
    % the between maps are designed to be orthogonal to within variation,
    % and vice versa. This doesn't work out perfectly in practice, because
    % estimates of these component directions isn't perfect in the training
    % data. But it means we can behave as if they are orthogonal for
    % testing purposes to evaluate how well the model does what it's
    % supposed to be doing. Therefore we can just apply the between and
    % within models to the full dataset (rather than subdividing our
    % testing data into within or between components itself).
    pred_bt(fold_labels == k) = test.dat'*fold_model{2} + fold_model{4};
    
    pred_wi(fold_labels == k) = test.dat'*fold_model{3} + fold_model{4};
end

% let's also fit a non optimized model for comparison, because we've only
% done that for the multiracial pain data so far
[~,nsf_stats] = nsf.predict('algorithm_name', 'cv_mlpcr', 'nfolds', fold_labels, ...
    'subjIDs', subject_id, 'numcomponents' , [Inf, Inf], 'verbose', 0);

figure;
subplot(1,2,1);
line_plot_multisubject(nsf.Y, nsf_stats.yfit, 'subjid', subject_id);
xlabel('Pain')
ylabel({'Prediction','(cross validated)'});
title({'Pain prediction multilevel PCR','without hyperparameter optimizatoin'});

subplot(1,2,2);
line_plot_multisubject(nsf.Y, pred, 'subjid', subject_id);
xlabel('Pain')
ylabel({'Prediction','(cross validated)'});
title({'Pain prediction multilevel PCR','with hyperparameter optimizatoin'});


fprintf('Optimized multilevel PCR models r = %0.3f.\n', corr(pred,nsf.Y));
fprintf('Non-optimized multilevel PCR models r = %0.3f.\n', corr(nsf_stats.yfit, nsf.Y));

%% Evaluating sensitivity and specificity of optimized within and between patterns.
% Let's now plot our results as we did for the unregularized/unoptimized
% multilevel PCR models. We will find that within subject pain prediction
% explains both within and between subject pain, while between subject pain
% ratings are not well predicted by the between subject signature, which
% instead shows a borderline tendency to predict within subject pain. This 
% prediction is negative, similar to a cross validated null model prediction. 
% This is consistent with a study designed to eliminate between subject
% differences in pain. 
%
% One might have hoped that the between subject
% dimensions would have been pushed to zero, and perhaps they might have if
% we ran the optimization algorithm for more iterations. Inspecting the 
% loss function profile reveals two local minima, one of which involves no
% between dimensions. This illustrates the limitations of Bayesian
% optimization, namely that it is only an approximation of the loss
% function and is succeptible to noise in your loss estimation procedure.
% Nevertheless it's notable that our overall prediction accuracy is still
% improved in spite of this imperfection (see previous section).

cmat = []; % within subject centering matrix
mumat = []; % within subject averaging matrix
n = [];
for i = 1:n_subj
    this_blk = uniq_subject_id(i);
    this_n = sum(this_blk == subject_id);
    n = [n(:); this_n*ones(this_n,1)];
    cmat = blkdiag(cmat, eye(this_n) - 1/this_n);
    mumat = blkdiag(mumat, ones(this_n)*1/this_n);
end
[~,exemplar] = unique(subject_id);

Y_wi = cmat*nsf.Y;
Y_bt = mumat*nsf.Y;

pred_bt_bt = mumat*pred_bt;
pred_bt_wi = cmat*pred_bt;

pred_wi_bt = mumat*pred_wi;
pred_wi_wi = cmat*pred_wi;

% compute standard standard errors on subject mean predictions and ratings
v_pred_bt = (mumat*(pred_bt_wi.^2)./n).^0.5; 
v_pred_wi = (mumat*(pred_wi_wi.^2)./n).^0.5; 
v_Y_bt = (mumat*(Y_wi.^2)./n).^0.5;

% get rid of redundant rows
Y_bt = Y_bt(exemplar);
v_Y_bt = v_Y_bt(exemplar);
pred_bt_bt = pred_bt_bt(exemplar);
v_pred_bt = v_pred_bt(exemplar);
pred_wi_bt = pred_wi_bt(exemplar);
v_pred_wi = v_pred_wi(exemplar);

figure
subplot(2,2,1);
[~,p] = corr(Y_wi, pred_wi_wi);
line_plot_multisubject(Y_wi, pred_wi_wi,'subjid', subject_id);
title({'Within Pattern vs. Pain',sprintf('p = %0.3f',p)});
ylabel({'Prediction within subject','Pred_i_j - Pred_i_.'})
xlabel({'Pain within subject','Pain_i_j - Pain_i_.'})

subplot(2,2,2); hold off;
[~,p] = corr(Y_bt, pred_wi_bt);
plot(Y_bt, pred_wi_bt,'b.'); lsline
hold on;
errorbar(Y_bt, pred_wi_bt, v_pred_wi, v_pred_wi, v_Y_bt, v_Y_bt,'ob')
title({'Within Pattern vs. Pain',sprintf('p = %0.3f',p)});
ylabel({'Mean subject prediction','Pred_i_.'})
xlabel({'Mean subject pain','Pain_i_.'})

subplot(2,2,3);
[~,p] = corr(Y_wi, pred_bt_wi);
line_plot_multisubject(Y_wi, pred_bt_wi,'subjid', subject_id);
title({'Between Pattern vs. Pain',sprintf('p = %0.3f',p)});
ylabel({'Prediction within subject','Pred_i_j - Pred_i_.'})
xlabel({'Pain within subject','Pain_i_j - Pain_i_.'})

subplot(2,2,4);
[~, p] = corr(Y_bt, pred_bt_bt);
hold off
plot(Y_bt, pred_bt_bt,'b.'); lsline
hold on;
errorbar(Y_bt, pred_bt_bt, v_pred_bt, v_pred_bt, v_Y_bt, v_Y_bt,'ob')
title({'Between Pattern vs. Pain',sprintf('p = %0.3f',p)});
ylabel({'Mean subject prediction','Pred_i_.'})
xlabel({'Mean subject pain','Pain_i_.'})

pos = get(gcf,'Position');
set(gcf,'Position',[pos(1:2), 1205, 785]);

%% Conclusions
% We've now demonstrated how to use multilevel PCR to obtain between and
% within subject predictive MVPA maps, and we've also shown how to use
% bayesian hyperparameter optimization to improve these predictive models.
%
% The use of Bayesian optimization can be applied to many other machine
% learning algorithms as well and perameters can be quite different from
% those we have here. For instance kernel selection for SVM can be
% optimized using bayesopt(), even though it's a categorical parameter and
% not continuous like our hyperparameters here. It will work best when the
% parameters you're optimizing are few (<=5) and when the sapce you have to
% explore is too large for grid sampling to be practical, or when it's too 
% rugose for simple linear interpolation after sparse grid sampling of the
% loss functions dependence on hyperparameter value.
%
% One notabe point which hasn't been discussed so far is the choice of loss
% function. 1-r was used instead of the more typical mean squared error.
% For reasons so far unknown fMRI based predictive models tend to do best
% as correlation measures, but do not provide very good absolute estimates
% of outcomes. This isn't limited to pain prediction either. You can see 
% similar things in Jim Haxby's classic MVPA papers that use "1-nearest 
% neighbor correlation" for classification. I personally have an aversion
% to using 1-r, because correlations allow for additional degrees of
% freedom in your performance evaluation, so they seem like cheating,
% but the fact of the matter is that they seem to produce better behaved
% loss functions in practice. You should make up your own mind regarding
% the matter. 

% The main motivation guiding loss function use here was that all of
% our outcome metrics are correlation based, so it seems sensible to
% optimize the same measure. Some objectives are more sporting than 
% others, and this tutorial didn't have a particularly high ambitions. It's
% simply here to proide some convenient and accessible illustrations of a
% toolkit, not to do rigorous science.
%}
%% APPENDIX A: loss function for mlPCR optimization

function loss = lossEst(dim, dat)
    subject_id = dat.metadata_table.subject_id;
    [~,~,subject_id] = unique(subject_id);
    % we want to incorporate CV fold slicing variance into our estimator so
    % let's get new CV folds to use on this iteration. If we revisit this
    % spot in the search space we'll get new slices and the variance can be
    % incorporated by bayesopt into its model of the loss function
    kfolds = 5;
    cv = cvpartition2(ones(size(dat.dat,2),1), 'KFOLD', kfolds, 'Stratify', subject_id);

    [I,J] = find([cv.test(1),cv.test(2), cv.test(3), cv.test(4), cv.test(5)]);
    fold_labels = sortrows([I,J]);
    fold_labels = fold_labels(:,2);
    
    r = dat.predict('algorithm_name','cv_mlpcr',...
           'nfolds',fold_labels,'numcomponents',[dim.btDims, dim.wiDims], ...
           'verbose',0, 'subjIDs', subject_id, 'error_type','r');
    loss = 1-r;
end


%% APPENDIX B: bootstrapping functions
% the code below is not thoroughly vetted. If you borrow it for any other
% purposes you should check its results against a reference source.
% Matlab's bootstrp function can also perform bias corrected accelerated
% bootstraps. With some modifications you could set this up to provide
% convergent results and check that you obtain them.

% this bootstraps subjects while keeping trials within subject fixed. 
% Bootstrapping both results in a very small effective dataset size and is
% not practical. Each bootstrap selects on average 63% of the data, so
% doubly bootstrapping selects 40%. Bootstrapping only within dimensions is
% possible but this leads to instability of between dimension estimation
% and doesn't inform cross validation results which vary in subject
% selection, not in trial selection within subject.
function w = bootstrap(dat, subject_id, n, varargin)
    [w, w_bt, w_wi] = deal(zeros(size(dat.dat,1),n));
    [uniq_subj_id, ~, subject_id] = unique(subject_id,'rows','stable');
    n_subj = length(uniq_subj_id);
    parfor i = 1:n
        uniq_bs_subj_id = uniq_subj_id(randi(n_subj,n_subj,1));
        bs_subject_id = [];
        bs_idx = [];
        for j = 1:n_subj
            this_bs_subj = uniq_bs_subj_id(j);
            this_idx = find(this_bs_subj == subject_id);
            
            bs_idx = [bs_idx(:); this_idx(:)];
            bs_subject_id = [bs_subject_id(:); j*ones(length(this_idx),1)];
        end
        
        bs_dat = dat.get_wh_image(bs_idx);
        [~, ~, bs_optout] = bs_dat.predict('algorithm_name','cv_mlpcr',...
            'nfolds',0,'verbose', 0, 'subjIDs',bs_subject_id, varargin{:});
        w(:,i) = bs_optout{1};
        w_bt(:,i) = bs_optout{2};
        w_wi(:,i) = bs_optout{3};
    end
    
    w = {w, w_bt, w_wi};
end

function w = jackknife(dat, subject_id, varargin)
    [uniq_subj_id, ~, subject_id] = unique(subject_id,'rows','stable');
    n_subj = length(uniq_subj_id);
    
    [w, w_bt, w_wi] = deal(zeros(size(dat.dat,1), n_subj));
    parfor i = 1:n_subj
        this_subj = uniq_subj_id(i);
        these_subj = find(subject_id ~= this_subj);
        this_dat = dat.get_wh_image(these_subj);

        [~, ~, optout] = this_dat.predict('algorithm_name','cv_mlpcr',...
            'nfolds',0,'verbose',0,'subjIDs',subject_id(these_subj), varargin{:});
        w(:,i) = optout{1};
        w_bt(:,i) = optout{2};
        w_wi(:,i) = optout{3};
    end
    
    w = {w, w_bt, w_wi};
end

% computes bootstrap bias corrected accelerated bootstrap confidence
% interval and returns if it includes 0 as a logical vector sig
function [sig, w_bs] = BCa(n, alpha, dat, subject_id, varargin)
    % get mean estimate
    [~, ~, optout] = dat.predict('algorithm_name','cv_mlpcr',...
        'nfolds',0,'subjIDs',subject_id, varargin{:});
    
    w = optout(1:3);
        
    fprintf('Computing bootstrap models...\n ');
    w_bs = bootstrap(dat, subject_id, n, varargin{:});
    
    fprintf('Computing jackknife...\n');
    w_jk = jackknife(dat, subject_id, varargin{:});
    
    fprintf('Estimating BCa CIs...\n')
    sig = cell(3,1);
    for i = 1:length(sig)
        bias = sum(w_bs{i} < w{i}(:),2)./size(w_bs{i},2);
        z0 = icdf('norm', bias, 0, 1);

        jkEst = mean(w_jk{i}, 2);
        num = sum((jkEst - w_jk{i}).^3, 2);
        den = sum((jkEst - w_jk{i}).^2, 2);
        a = num ./ (6*den.^(3/2));

        zL = z0 + icdf('norm',alpha/2,0,1);
        alpha1 = normcdf(z0 + zL./(1-a.*zL));
        zU = z0 + icdf('norm',1-alpha/2,0,1);
        alpha2 = normcdf(z0 + zU./(1-a.*zU));
        CI = zeros(size(w_bs{i},1),2);
        parfor j = 1:size(w_bs{i},1)
            CI(j,:) = quantile(w_bs{i}(j,:), [alpha1(j), alpha2(j)]);
        end

        sig{i} = prod(sign(CI),2) > 0;
    end
end
