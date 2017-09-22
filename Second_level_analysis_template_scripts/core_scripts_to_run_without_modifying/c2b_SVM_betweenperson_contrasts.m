% THIS SCRIPT RUNS BETWEEN-PERSON CONTRASTS
% Assuming that groups are concatenated into contrast image lists.
% Requires DAT.BETWEENPERSON.group field specifying group membership for
% each image.
% --------------------------------------------------------------------

%% Load stats
savefilenamedata = fullfile(resultsdir, 'svm_stats_results_betweenperson_contrasts.mat');

if ~exist(savefilenamedata, 'file')
    disp('Run prep_3d_run_SVM_betweenperson_contrasts with dosavesvmstats = true option to get SVM results.'); 
    disp('No saved results file.  Skipping this analysis.')
    return
end

fprintf('\nLoading SVM results and maps from %s\n\n', savefilenamedata);
load(savefilenamedata, 'svm_stats_results');



%% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
whmontage = 5; 
plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------


printhdr('Cross-validated SVM to discriminate between-person contrasts');


%% --------------------------------------------------------------------
%
% Get results for between-person SVM for each contrast
%
% --------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

for c = 1:kc
    
    % Summarize output and create ROC plot
    % --------------------------------------------------------------------
    figtitle = sprintf('SVM ROC %s', DAT.contrastnames{c});
    create_figure(figtitle);
    
    disp(' ');
    printstr(['Results: ' DAT.contrastnames{c}]); printstr(dashes);
    
    ROC = roc_plot(svm_stats_results{c}.dist_from_hyperplane_xval, logical(svm_stats_results{c}.Y > 0), 'color', DAT.contrastcolors{c}, 'Optimal balanced error rate');
    
    plugin_save_figure;
    close
    
    % Effect size, cross-validated
    dfun2 = @(x, Y) (mean(x(Y > 0)) - mean(x(Y < 0))) ./ sqrt(var(x(Y > 0)) + var(x(Y < 0))); % check this.
    
    d = dfun2(svm_stats_results{c}.dist_from_hyperplane_xval, svm_stats_results{c}.Y);
    fprintf('Effect size, cross-val: d = %3.2f\n\n', d);
    
    
    % Plot the SVM map
    % --------------------------------------------------------------------
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(svm_stats_results{c}.weight_obj), 'trans');
    
    % axes(o2.montage{whmontage}.axis_handles(5));
    title(DAT.contrastnames{c}, 'FontSize', 18)
    
    printstr(DAT.contrastnames{c}); printstr(dashes);

    figtitle = sprintf('SVM weight map nothresh %s', DAT.contrastnames{c});
    plugin_save_figure;
       
    o2 = removeblobs(o2);
    
end  % within-person contrast





function [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, i)

group = []; groupnames = []; groupcolors = [];

if isfield(DAT, 'BETWEENPERSON') && ...
        isfield(DAT.BETWEENPERSON, mygroupnamefield) && ...
        iscell(DAT.BETWEENPERSON.(mygroupnamefield)) && ...
        length(DAT.BETWEENPERSON.(mygroupnamefield)) >= i && ...
        ~isempty(DAT.BETWEENPERSON.(mygroupnamefield){i})
    
    group = DAT.BETWEENPERSON.(mygroupnamefield){i};
    
elseif isfield(DAT, 'BETWEENPERSON') && ...
        isfield(DAT.BETWEENPERSON, 'group') && ...
        ~isempty(DAT.BETWEENPERSON.group)
    
    group = DAT.BETWEENPERSON.group;

end

if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'groupnames')
    groupnames = DAT.BETWEENPERSON.groupnames;
elseif istable(group)
    groupnames = group.Properties.VariableNames(1);
else
    groupnames = {'1 = order REG_EXP' '-1 = order EXP_REG'};
end

if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'groupcolors')
    groupcolors = DAT.BETWEENPERSON.groupcolors;
else
    groupcolors = seaborn_colors(2);
end

if istable(group), group = table2array(group); end

end
