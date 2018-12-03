%% Load thermal stimulation data from BMRK3
canlab_help_set_up_pain_prediction_walkthrough

%% Extract high heat trials and low heat trials - subtract
thermal_contrast=image_obj;
thermal_contrast.dat=image_obj.dat(:,6:6:end)-image_obj.dat(:,1:6:end);
thermal_contrast.Y=image_obj.Y(6:6:end)-image_obj.Y(1:6:end);

%% Compute t-map for comparison of high heat vs baseline
t=ttest(thermal_contrast);
orthviews(t);

%% Compute BF map based on tstatistic and sample size 
BF_tstat=estimateBF(t,'t');
orthviews(BF_tstat);
BF_tstat_th = threshold(BF_tstat, [-6 6], 'raw-outside');
orthviews(BF_tstat_th);
%% Compute correlations between high heat activation and pain ratings
r=t; %initialize stats object from t-test output
r.dat=corr(thermal_contrast.dat',thermal_contrast.Y); %replace data with simple correlation
orthviews(r); %show results

%% Compute BF map based on pearson correlations and sample size
BF_correlation=estimateBF(r,'r'); %estimate BF
orthviews(BF_correlation);  %show results
BF_correlation_th = threshold(BF_correlation, [-6 6], 'raw-outside');
orthviews(BF_correlation_th);
%% Compute proportion of subjects with greater responses to high heat
prop=r; %initialize stats object from correlation output
prop.dat=sum(thermal_contrast.dat'>0)'; %compute number of subjects with greater response to high heat
orthviews(prop);  %show results

%% Compute BF map based on proportion and sample size

BF_prop=estimateBF(prop,'prop'); %estimate BF
orthviews(BF_prop);  %show results

BF_prop_th = threshold(BF_prop, [-6 6], 'raw-outside');
orthviews(BF_prop_th);