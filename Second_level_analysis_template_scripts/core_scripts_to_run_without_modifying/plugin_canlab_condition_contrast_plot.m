% [fighan, axh, handles] = plugin_canlab_condition_contrast_plot(data_to_plot, DAT, analysis_name, dv_name)
%
% This plugin function plots a series of conditions in one panel, and a
% series of contrasts across those conditions in another. This is useful
% for showing patterns of means across conditions and contrasts in a
% format that reveals the effect size and consistency across participants
% of within-person contrasts.
%
% It is designed to be compatible with the "canlab second level batch
% scripts" framework. This requires certain inputs organized in an input structure
% (called DAT here).  But it can be run as a stand-alone with any type of
% data. So it can also be thought of as a template function for creating a
% commonly used type of plot.
% 
% Features:
% - Shows individual data for within-person contrasts
% - Shows and reports effect sizes for within-person contrasts
% - Compatible with CANlab 2nd-level batch script framework
% - Includes labels for analyses and conditions so output can be interpreted
% - Compatible with html report-generation so that this function can be used to generate reports
%
%
% INPUTS (and sample example data)
% ---------------------------------------------------------------------
%
% DAT.conditions = {'Cond1' 'Cond2' 'Cond3' 'Cond4'};   % Names of conditions
% DAT.colors = seaborn_colors(4);                       % Colors for each condition
% DAT.contrasts = [.5 .5 -.5 -.5; .5 -.5 .5 -.5; .5 -.5 -.5 .5]; % Contrast vectors (weights)
%           % Note: Each contrast is a ROW vector.
% DAT.contrastnames = {'M.E. 1' 'M.E. 2' 'Interaction'}; 
% DAT.contrastcolors = seaborn_colors(size(DAT.contrasts, 1));
%
% Make condition colors that vary along a spectrum:
% k = length(DAT.conditions);
% cm = colormap_tor([.8 .1 .1], [1 1 0], [.9 .6 .1]);
% wh = ceil(linspace(1, length(cm)-1, k));
% conditioncolors = mat2cell(cm(wh, :), ones(k, 1), 3)';
% DAT.colors = conditioncolors
%
% All other inputs are not in DAT structure because they are not
% standardized in 2nd-level scripts; so keep as separate inputs here:
%
% data_to_plot = randn(30, 4); % sample data: 30 subjects, 4 conditions.
% analysis_name = 'Sample_Analysis';
% dv_name = 'Outcome measure';
% [fighan, axh, handles] = plugin_canlab_condition_contrast_plot(data_to_plot, DAT, analysis_name, dv_name);
%
function [fighan, axh] = plugin_canlab_condition_contrast_plot(data_to_plot, DAT, analysis_name, dv_name)


% Display helper functions: Called by later scripts
% --------------------------------------------------------

dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);


% Check for required DAT fields. Skip analysis and print warnings if missing.
% ---------------------------------------------------------------------
% List required fields in DAT, in cell array:
required_fields = {'conditions', 'colors'};

ok_to_run = plugin_check_required_fields(DAT, required_fields); % Checks and prints warnings
if ~ok_to_run
    return
end

% COULD CONTROL FOR OTHER VARIABLES HERE - NOT IMPLEMENTED YET
% Controlling for group admin order covariate (mean-centered by default)
% 
group = [];
% if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'group')
%     group = DAT.BETWEENPERSON.group; % empty for no variable to control/remove
%     
%     printstr('Controlling for data in DAT.BETWEENPERSON.group');
% end

k = length(DAT.conditions);
nplots = 3;

myfontsize = get_font_size(k);
myaxislabels = format_strings_for_legend(DAT.conditions);
%mypointsize = get_point_size(nplots, k);
mypointsize = 3;

%% Signature Response - conditions
% ------------------------------------------------------------------------

printhdr([analysis_name ': Conditions']);

fighan = create_figure(analysis_name, 1, nplots);
adjust_fig_position_for_long_xlabel_names(fighan);

clear axh

for n = 1 % Legacy from version that included multiple outcome measures in panels/figures
    
    axh(n) = subplot(1, nplots, n);
    
    mydata = data_to_plot;                  % from 2nd level scripts: table2array(DAT.SIG_conditions.(myscaling).(mymetric).(mysignature));
    
    % Lines and point options are controlled here
    
    handles = barplot_columns(mydata, 'title', format_strings_for_legend(analysis_name), 'colors', DAT.colors, 'MarkerSize', mypointsize, 'dolines', 'nofig', 'names', myaxislabels, 'covs', group, 'wh_reg', 0);
    
    set(axh(n), 'FontSize', myfontsize);
    ylabel(dv_name); 
    xlabel('')
        
    drawnow
end

%% Plot without individual subject detail

printhdr([analysis_name ': Conditions']);

for n = 2 % Legacy from version that included multiple outcome measures in panels/figures
    
    axh(n) = subplot(1, nplots, n);
    
    mydata = data_to_plot;                  % from 2nd level scripts: table2array(DAT.SIG_conditions.(myscaling).(mymetric).(mysignature));
    
    % Lines and point options are controlled here
    
    handles2 = barplot_columns(mydata, 'title', format_strings_for_legend(analysis_name), 'colors', DAT.colors, 'MarkerSize', mypointsize, 'noind', 'noviolin', 'nofig', 'names', myaxislabels, 'covs', group, 'wh_reg', 0);
    
    set(axh(n), 'FontSize', myfontsize);
    ylabel(dv_name); 
    xlabel('')
        
    drawnow
end


%% Signature Response - contrasts
% ------------------------------------------------------------------------

% Check for required DAT fields. Skip analysis and print warnings if missing.
% ---------------------------------------------------------------------
% List required fields in DAT, in cell array:
required_fields = {'contrasts', 'contrastnames', 'contrastcolors'};

ok_to_run = plugin_check_required_fields(DAT, required_fields); % Checks and prints warnings
if ~ok_to_run
    return
end
% ------------------------------------------------------------------------

printhdr([analysis_name ': Contrasts']);

kc = size(DAT.contrasts, 1);        % number of contrasts
myfontsize = get_font_size(kc);
myaxislabels = format_strings_for_legend(DAT.contrastnames);
%mypointsize = get_point_size(nplots, kc);
mypointsize=3

for n = 3 % Legacy
    
    axh(n) = subplot(1, nplots, n);
    
    mydata = data_to_plot * DAT.contrasts';
    
    % get condition-specific group covariate data if any
    % this will not work yet, because barplot_columns cannot handle
    % condition-specific covariates. See "group diffs" script.
    %     mygroupnamefield = 'contrasts';  % 'conditions' or 'contrasts'
    %     [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, n);
    
    handles = barplot_columns(mydata, 'title', 'Contrasts', 'colors', DAT.contrastcolors, 'MarkerSize', mypointsize, 'nofig', 'names', myaxislabels, 'covs', group, 'wh_reg', 0);
    
    set(axh(n), 'FontSize', myfontsize);
    if n == 1, ylabel(format_strings_for_legend(mymetric)); else, ylabel(' '); end
    xlabel('')
    
    drawnow
end

kludgy_fix_for_y_axis(axh);

drawnow, snapnow

% plugin_save_figure;  % don't save yet...do this manually outside this function
% close

end % Main function


%%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% Sub-functions
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


%% Get font size
% -------------------------------------------------------------------------

function myfontsize = get_font_size(k)
% get font size
if k > 10
    myfontsize = 8;
elseif k > 8
    myfontsize = 9;
elseif k > 5
    myfontsize = 12;
elseif k > 2
    myfontsize = 14;
else
    myfontsize = 18;
end
end

%% Adjust figure position
% -------------------------------------------------------------------------

function adjust_fig_position_for_long_xlabel_names(fighan)

figpos = get(fighan, 'Position');
figpos(3) = figpos(3) - 100;
figpos(4) = figpos(4) + 100;
set(fighan, 'Position', figpos);

end

%% Fix y-axis values
% -------------------------------------------------------------------------

function kludgy_fix_for_y_axis(axh)
% Matlab is having some trouble with axes for unknown reasons

axis2 = get(axh(2), 'Position');

% re-set axis 1
mypos = get(axh(1), 'Position');
mypos([2 4]) = axis2([2 4]);  % re-set y start and height
set(axh(1), 'Position', mypos);

end


%% set point size
% -------------------------------------------------------------------------
function ptsize = get_point_size(n, k)

ptsize = 12 ./ (.5*n*log(1 + k));

ptsize = ptsize .* 10; % not sure why, but these are very small....
% I think scatterplot SizeData property is now used, which makes them
% very different from MarkerSize property.

end

% % Not used - post hoc setting
% function set_point_size(handles, n, k)
% 
% myhandles = handles.point_han(:);
% myhandles(cellfun(@isempty, myhandles)) = [];
% ptsize = get_point_size(n, k);
% ptfun = @(x) set(x, 'MarkerSize', ptsize);
% cellfun(ptfun, myhandles);
% 
% end


%% Get group between-person vectors of covariates and other info
% -------------------------------------------------------------------------

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
    groupnames = {'Group-Pos' 'Group-neg'};
end

if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'groupcolors')
    groupcolors = DAT.BETWEENPERSON.groupcolors;
else
    groupcolors = seaborn_colors(2);
end

if istable(group), group = table2array(group); end

if ~isempty(group), disp('Controlling for between-image group variable.'); end

end
