% Create and plot your own design matrix easily using CANlab tools!

% This also requires SPM software functions

%% Create a simple,  one-event design

% [X, e] = create_design_single_event(TR, ISI, eventduration, HPlength, dononlin)

TR = 2;
ISI = 18;
eventduration = 3;
HPlength = 128;
dononlin = 0;

create_figure('design');
[X, e] = create_design_single_event(TR, ISI, eventduration, HPlength, dononlin);

%% Create a randomized event-related design with 4 conditions

TR = 1;
ISI = 1.3;
eventduration = 1;
freqConditions = [.2 .2 .2 .2];
HPlength = 128;
dononlin = 0;

create_figure('design');
[X, e, ons] = create_random_er_design(TR, ISI, eventduration, freqConditions, HPlength, dononlin);
axis tight

%% Create an alternating block design with 3 conditions

scanLength = 300;
TR = 1.3;
nconditions = 3;
blockduration = 20;
HPlength = 128;
dononlin = 0;

create_figure('design');
[X, e] = create_block_design(scanLength, TR, nconditions, blockduration, HPlength, dononlin);
axis tight

%% Create a simple design with two event types and pre-specified onsets

T = 96;  % time points 
n = 12;  % number of events

% Create onsets for two events types
events{1} = randperm(T); events{1} = events{1}(1:n)';
events{2} = randperm(T); events{2} = events{2}(1:n)';

% Build model: Convolve with HRF (need SPM on path)
X = onsets2fmridesign(events, 1, T, spm_hrf(1));

% Plot it
create_figure('X'); 
h = plot_matrix_cols(zscore(X(:, 1:2)), 'vertical');

% Customize
set(h, 'LineWidth', 3);

% Another plot
create_figure('X 2nd plot'); 
h = plot_matrix_cols(zscore(X(:, 1:2)), 'vertical');

% Customize
set(h(1), 'LineWidth', 3, 'Color', [0    0.4470    0.7410]);
set(h(2), 'LineWidth', 3, 'Color', [0.8500    0.3250    0.0980]);
hh = plot_vertical_line(1 - .25); set(hh, 'LineStyle', '--');
hh = plot_vertical_line(2 - .25); set(hh, 'LineStyle', '--');
axis tight
axis off

%% Create a simple design, with three different basis sets


T = 96;  % time points 
n = 4;  % number of events

% Create onsets for two events types
events{1} = randperm(T); events{1} = events{1}(1:n)';
events{2} = randperm(T); events{2} = events{2}(1:n)';

clear X

% Build model: Convolve with basis set (need SPM on path)
% 1: canonical, 2: 3-parameter, 3: FIR
X{1} = onsets2fmridesign(events, 1, T, spm_hrf(1));

bfname = 'hrf (with time and dispersion derivatives)';
X{2} = onsets2fmridesign(events, 1, T, bfname);

bfname = 'Finite Impulse Response';
X{3} = onsets2fmridesign(events, 1, T, bfname);

create_figure('X_3basis sets', 2, 3); 

for i = 1:3
    
    subplot(2, 3, i)
    h = plot_matrix_cols(zscore(X{i}(:, 1:end-1)), 'vertical');
    set(gca, 'XColor', 'w', 'YTick', [0:20:100]);
    axis tight
    
    subplot(2, 3, 3+i)
    imagesc(X{i}(:, 1:end-1))
    set(gca, 'YDir', 'Reverse');
    axis tight
    axis off
end
