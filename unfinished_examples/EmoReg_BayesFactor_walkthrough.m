%% Load Emotion Regulation data 
image_obj=load_image_set('emotionreg'); %load fmri object for regulate vs look
behav_data=importdata(which('Wager_2008_emotionreg_behavioral_data.txt')); %load text file with behavior
reappraisal_success=behav_data.data(:,2); %store as single variable
image_obj.Y=reappraisal_success;


%% Compute t-map for comparison of high heat vs baseline
t=ttest(image_obj);
orthviews(t);

%% Compute map of Bayes Factors based on t-statistic and sample size 
BF_tstat=estimateBF(t,'t');
BF_tstat_th = threshold(BF_tstat, [-6 6], 'raw-outside');
orthviews(BF_tstat_th);
%% Compute correlations between regulate vs look and behavioral measure
r=t; %initialize stats object from t-test output
r.dat=corr(image_obj.dat',image_obj.Y); %replace data with simple correlation
orthviews(r); %show results

%% Compute map of Bayes Factors based on pearson correlations and sample size
BF_correlation=estimateBF(r,'r'); %estimate BF
BF_correlation_th = threshold(BF_correlation, [-6 6], 'raw-outside');
orthviews(BF_correlation_th);

%% Compute proportion of subjects with greater activation during regulation
prop=r; %initialize stats object from correlation output
prop.dat=sum(image_obj.dat'>0)'; %compute number of subjects with greater response to high heat
orthviews(prop);  %show results

%% Compute map of Bayes Factors based on proportion and sample size
BF_prop=estimateBF(prop,'prop'); %estimate BF
BF_prop_th = threshold(BF_prop, [-6 6], 'raw-outside');
orthviews(BF_prop_th);