%% Setting
clear all;
mycomp_dir = '/Users/clinpsywoo/Documents/2011-2016yr/2015-2016_5th_GS';
basedir = fullfile(mycomp_dir, 'fMRI_TorWager/Wani_simulation');

%% 1. DEFINE SIMULATION SPACE --------------------------------------------
dat = fmri_data(which('brainmask.nii'));

% true activaiton: right IFG
task_t_act = fmri_data(fullfile(basedir, 'IFG_right.nii'));

% false activation: left IFG
task_f_act = fmri_data(fullfile(basedir, 'IFG_left.nii'));

%% 2. FIRST-LEVEL ANALYSIS (subject level) -------------------------------

% between-subject variability: the values will scale the signal magnitude
ind_diff = normrnd(1,.3,20,1);

% fmri_data for betas from first-level analysis
b = dat;

% loop through subjects (N = 20)

for i = 1:20
    
    disp('========================================================');
    s = ['Working on subj ', num2str(i)];
    disp(s);
    disp('========================================================');
    
    dat.dat = normrnd(0,.5,size(dat.dat,1),200); % 200 time points
    % plot(dat)
    
    % create random time-series
    % -------------------------------------------------------
    n_ts = size(dat.dat, 2);
    
    % random onsets for true signal
    ons = find((rand(n_ts, 1)>.8))*2;
    
    % random onsets for fake signal
    noise_ons = find((rand(n_ts, 1)>.8))*2;
    
    % onset + HRF convolution
    ts = onsets2fmridesign({ons, noise_ons}, 2, 400, spm_hrf(1));
    ts = ts(:,1:2);
    
    % add noise (within-subject)
    ts_sig = ts + normrnd(0,.005,size(ts,1),2);
    
    % % time series
    % subplot(3,1,1);
    % plot([ts ts_sig]); set(gca, 'ylim', [-.03 .06]);
    % subplot(3,1,2);
    % plot(ts); set(gca, 'ylim', [-.03 .06]);
    % subplot(3,1,3);
    % plot(ts_sig); set(gca, 'ylim', [-.03 .06]);
    
    % add true signal into true activation mask
    t_act = double(task_t_act.dat);
    t_act = t_act*(ts_sig(:,1).*ind_diff(i))';
    
    % add fake signal into false activation mask
    f_act = double(task_f_act.dat);
    f_act = f_act*(ts_sig(:,2).*ind_diff(i))';
    
    % add true and fake signal into data
    dat.dat = dat.dat + t_act + f_act;
    
    % smoothing - will increase SNR
    disp('  smoothing.......');
    dat = preprocess(dat, 'smooth', 4);
    % plot(dat);
    
    % regression with the real time series
    X = [ts(:,1) ones(size(ts,1),1)];
    
    % calculate beta coefficients
    beta = pinv(X) * dat.dat'; % beta from the first-level analysis
    
    % stack the betas
    b.dat(:,i) = beta(1,:)';
    
end

save simulation_res_final b;

%% 2. SECOND-LEVEL T-TEST ------------------------------------------------
o2 = canlab_results_fmridisplay([], 'compact2', 'noverbose');
tb = ttest(b);
tb = threshold(tb, .05, 'fdr');
o2 = removeblobs(o2);
o2 = addblobs(o2, region(tb), 'splitcolor', {[0 0 1] [.3 0 .8] [.8 .3 0] [1 1 0]});

%% =======================================================================
% OPTIONAL: DISPLAY AN EXAMPLE OF SIGNAL 
% ========================================================================

colors = [0.1961    0.5333    0.7412
    0.8353    0.2431    0.3098
    0.6706    0.8667    0.6431
    0.9922    0.6824    0.3804];

subplot(3,1,1);
h = plot([ts ts_sig]); 
set(gca, 'ylim', [-.03 .06]);
for i = 1:numel(h)
    set(h(i), 'color', colors(i,:));
end
xlabel('time series')
ylabel('signal')
legend('true signal','fake signal', 'true signal + noise',  'fake signal + noise');

subplot(3,1,2);
h = plot(ts); 
set(gca, 'ylim', [-.03 .06]);
for i = 1:numel(h)
    set(h(i), 'color', colors(i,:));
end
xlabel('time series')
ylabel('signal')
legend('true signal','fake signal');


subplot(3,1,3);
h = plot(ts_sig); 
set(gca, 'ylim', [-.03 .06]);
for i = 1:numel(h)
    set(h(i), 'color', colors(i+2,:));
end

xlabel('time series')
ylabel('signal')
legend('true signal + noise',  'fake signal + noise');

