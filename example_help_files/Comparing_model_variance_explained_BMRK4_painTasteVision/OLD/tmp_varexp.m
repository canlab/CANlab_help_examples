% inputs: b, Y, X1 in glmfit_multilevel format, varargin "plots"


b = stats.beta';

% remove random intercepts per person - not interested in this variance
Yc = cellfun(@(x) scale(x, 1), Y, 'UniformOutput', false);

Ycat = cat(1, Yc{:});
Xcat = cat(1, X1{:});

nobs = size(Xcat, 1);

Xcat = [ones(nobs, 1) Xcat];


modelfit = Xcat * b;

vary = var(Ycat);               % removed random intercept
varexpfixed = var(modelfit);    % Ok even though there is intercept in model, constant (no effect on var)
varresid = vary - varexpfixed;  % measurement error (sigma) + var due to random slopes

partialfit = Xcat * diag(b);
partialfit = partialfit(:, 2:end); % ignore intercept, no variance

varbeta = var(partialfit);      % unique variance attributed to each

% varexpfixed = sum(varbeta) + varshared
varshared = varexpfixed - sum(varbeta);

% vary = varexpfixed + varresid = sum(varbeta) + varshared + varresid

create_figure('Pies', 1, 2);

% Pie chart of all variance (vary, excluding intercepts)
h = wani_pie([varbeta varshared varresid], 'hole');

subplot(1, 2, 2);

% Pie chart of all variance explained (varexpfixed, excluding intercepts)
h = wani_pie([varbeta varshared], 'hole');

% calculate percentages, print in table/output
% ***

% percentage of total variance (excluding intercept) attributable to each component

100 .* [varbeta varshared] ./ vary;

% percentage of variance explained attributable to each component
100 .* [varbeta varshared] ./ varexpfixed;



