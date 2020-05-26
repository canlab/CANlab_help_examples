% This walkthrough calculates Bayes Factors for a voxel-wise brain map using a Bayesian t-test approach. 

% Bayesian t-tests
% -----------------------------------------------------------------
% We use the BF Bayes' Factor Matlab toolbox, based on:
% 
%     Rouder et al., 2009     % one-sample t-test, t1smpbf.m
%     Rouder et al., 2009     % binomial test, binombf.m
%     Wetzels et al., 2012    % Pearson's r, corrbf.m
%     Boekel et al., 2014     % test for replicating Pearson's r in same direction
% 
% Implemented by Sam Schwarzkopf, UCL
%
% Rouder (2009) derived a formula to calculate Bayes Factors for a
% one-sample t-test, a common test statistic in neuroimaging, particularly 
% when testing contrast or 2nd-level (across-participant) summary statistics 
% in a two-level hierarchical model. They also provided a web application:
% http://pcl.missouri.edu/bf-one-sample
%
% Gönen et al. (2005) provided the corresponding equation
% for the unit-information Bayes factor. Liang et al. (2008)
% provided the corresponding JZS Bayes factors for testing
% slopes in a regression model.
% 
% As Rouder et al. point out: "Researchers need only provide the sample size N and
% the observed t value. There is no need to input raw data.
% The integration is over a single dimension and is computationally
% straightforward."
%
% This function iterates over voxels to calculate bayes factors for a map.
%
% Assumptions about prior distributions and parameter choices
% -----------------------------------------------------------------
% With Bayesian analysis, one must specify the distributional form of the
% prior belief about the effect size, which is integrated with evidence
% from the data to estimate a posterior probabilities of both null and
% alternative hypotheses. The Bayes Factor (BF) is a ratio of these (see below).
% 
% Different choices of prior distribution and effect size will thus yield
% different results for BFs, but there are some standard, reasonable
% choices. In addition, BFs are often not very sensitive to reasonable variation
% in priors, so it is reasonable to use a default choice for many applications.
% 
% The tests in the BF toolbox use default scaling values for prior distributions, and the
% Jeffrey-Zellner-Siow Prior (JZS, Cauchy distribution on effect size).
% This is standard, widely used prior. The JZS prior has heavier tails than
% the normal distribution, so does not penalize very large effect sizes as
% much as the Normal prior (large effects can also be unlikely given an
% assumption of a particular alternative distribution with moderate effect
% sizes). The JZS prior is there more noninformative than Normal prior.
%
% One additional choice is the choice of prior effect size under the
% alternative hypothesis, which is determined by the scale factor (r in the
% BF toolbox). This is a noncentrality parameter that governs the expected
% effect. If the observed effect is much *larger* than the belief about the
% alternative, evidence for the alternative will actually go down!
% However, in this case, the BFs will likely still very strongly favor the
% alternative, so this is not a problem with the JZS prior.
% In Rouder et al. 2009, the default r was 1.0, but it was changed in 2015
% to be 0.707, which is a reasonable choice. We use this default here.
%
% Interpreting Bayes Factors:
% -----------------------------------------------------------------
% Bayes Factors > 1 provide evidence in favor of the Alternative (an
% effect), and those < 1 provide evidence in favor of the Null (no effect).
%
% For example, bf = t1smpbf(3, 50); yields bf = 7.92, or about 8:1 in favor of the alternative.
% bf = bf = t1smpbf(2, 50); yields bf = 0.96, or about 1.04:1 in favor of the null.
%
% The BF toolbox returns BF values in their original scaling. the
% fmri_data.estimateBayesFactor method scales the BFs by 2*ln(BF),
% so that values of 0 indicate equal support for Null and Alternative,
% positive values support the Alternative, and negative values support the
% Null. (See Kass and Raftery 1995)
%
% These are returned in a statistic_image object BF, whose .dat field
% contains 2*ln(BF) values for each voxel.  A value of about 4.6 indicates
% a BF of 10, or 10:1 evidence in favor of the Alternative, which is a typical cutoff. 
% A value of about 6 indicates 20:1 evidence in favor of the Alternative.
% 

%% Load Emotion Regulation data 
image_obj=load_image_set('emotionreg'); %load fmri object for regulate vs look
behav_data=importdata(which('Wager_2008_emotionreg_behavioral_data.txt')); %load text file with behavior
reappraisal_success=behav_data.data(:,2); %store as single variable
image_obj.Y=reappraisal_success;

%% Compute standard t-map for comparison of high heat vs baseline

t=ttest(image_obj);

% Show the results:
orthviews(t)

create_figure('montage'); axis off
montage(t);

drawnow, snapnow

%% Compute map of Bayes Factors based on t-statistic and sample size 
BF_tstat=estimateBayesFactor(t,'t');

% Threshold at values larger than 6 in either direction. This corresponds
% to about 20:1 evidence in favor of the Alternative (for positive values)
% and Null (for negative values).

BF_tstat_th = threshold(BF_tstat, [-6 6], 'raw-outside');

orthviews(BF_tstat_th);

create_figure('montage'); axis off
montage(BF_tstat_th);

drawnow, snapnow

%% Compute correlations between regulate vs look and behavioral measure
r=t; %initialize stats object from t-test output
r.dat=corr(image_obj.dat',image_obj.Y); %replace data with simple correlation
orthviews(r); %show results
drawnow, snapnow

%% Compute map of Bayes Factors based on pearson correlations and sample size
BF_correlation=estimateBayesFactor(r,'r'); %estimate BF
BF_correlation_th = threshold(BF_correlation, [-6 6], 'raw-outside');
orthviews(BF_correlation_th);
drawnow, snapnow

%% Compute proportion of subjects with greater activation during regulation
prop=r; %initialize stats object from correlation output
prop.dat=sum(image_obj.dat'>0)'; %compute number of subjects with greater response to high heat
orthviews(prop);  %show results
drawnow, snapnow

%% Compute map of Bayes Factors based on proportion and sample size

BF_prop=estimateBayesFactor(prop,'prop'); %estimate BF

BF_prop_th = threshold(BF_prop, [-6 6], 'raw-outside');
orthviews(BF_prop_th);

drawnow, snapnow

