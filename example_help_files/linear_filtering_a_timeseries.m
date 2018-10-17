% Lindquist (under review): You should not sequentially apply high-pass
% filtering and nuisance regression. Combine them into one step. 
% This is an example of how to do that.

% Use SPM to get a filter
TR = 2;
n_timepoints = 300;
hpf = 128; % 128 is high pass filter length in sec, 1/hz
[S,KL,KH] = use_spm_filter(TR, n_timepoints,'none','specify',hpf);

% KH is the high-pass filter regressors

% Define functions that get the Smoothing matrix S.
% ---------------------------------------------------
get_hat = @(X) X * pinv(X);   % 
get_S = @(H) eye(size(H)) - H;

% S is the residual-forming matrix such that SY is Y' where Y' has
% regressors KH removed.
% H is the "Hat matrix" that produces fitted responses
% S is the residual-forming matrix that produces residuals


% Use functions to reconstruct S, call it S_prime
H = get_hat(KH);
S_prime = get_S(H);

figure; imagesc(S); colorbar

% Sanity check : whether we can reconstruct the matrix S manually, using our
% functions
% ---------------------------------------------------
% Check whether S = S_prime
% if zero, matrices are identical
max(abs(S(:) - S_prime(:)))
isequal(S, S_prime)


% Add nuisance covs and re-construct filter matrix S
% intercept(s) for runs, too.
% This is what we would use on the real data.
% ---------------------------------------------------

% N = simulated nuisance covariates, for this example
% Movement params, spikes, initial images, outliers with high mahal dist
N = randn(n_timepoints, 6);

% Simulated intercepts, say for example we have  3 runs
I = intercept_model([n_timepoints/3 n_timepoints/3 n_timepoints/3]);

% construct an overall set of nuisance covs with all the stuff we want to
% remove.

X = [KH N I]; 

H = get_hat(X);
S_prime = get_S(H);

% Generate a simulated time series and filter it
% ---------------------------------------------------

y = repmat([ones(15, 1); zeros(15, 1)], 10, 1); % a real signal, simulated
n = noise_arp(n_timepoints, [.7 .3]);
intercept_noise = I * randn(3, 1);
y_obs = y + n + intercept_noise;
figure; plot(y_obs)

% This does the filtering and nuisance cov removal:
y_filtered = S_prime * y_obs;

figure; plot(y_filtered);
hold on; plot(y - .5, 'r', 'Linewidth', 2);
corr(y, y_filtered)
corr(y, y_obs)
