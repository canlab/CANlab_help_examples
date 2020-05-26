[files_on_disk, url_on_neurovault, mycollection, myimages] = retrieve_neurovault_collection(504);

%%
data_obj = fmri_data(files_on_disk);

%% Prepare behavioral data vector - low/med/high
% We don't have ratings attached in Neurovault, so we'll do this instead.

behavior_hml = zeros(size(data_obj.dat, 2), 1);

x = cellfun(@(x) ~isempty(strfind(x, 'High')), cellstr(data_obj.image_names), 'UniformOutput', false);
x = cat(1, x{:});
behavior_hml(x) = 3;

x = cellfun(@(x) ~isempty(strfind(x, 'Medium')), cellstr(data_obj.image_names), 'UniformOutput', false);
x = cat(1, x{:});
behavior_hml(x) = 2;

x = cellfun(@(x) ~isempty(strfind(x, 'Low')), cellstr(data_obj.image_names), 'UniformOutput', false);
x = cat(1, x{:});
behavior_hml(x) = 1;

data_obj.Y = behavior_hml;

%% Predict - 5-fold cross-validation

[cverr, stats, optout] = predict(data_obj, 'algorithm_name', 'cv_lassopcr', 'nfolds', 5);

% but over-optimistic...build custom holdout

create_figure('scatter'); plot_correlation_samefig(stats.Y, stats.yfit, [], 'ko');
ylabel('Predicted'); xlabel('Observed');



