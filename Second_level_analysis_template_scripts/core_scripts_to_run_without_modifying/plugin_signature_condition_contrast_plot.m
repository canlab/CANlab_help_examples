% Controlling for group admin order covariate (mean-centered by default)

group = [];
if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'group')
    group = DAT.BETWEENPERSON.group; % empty for no variable to control/remove
    
    printstr('Controlling for data in DAT.BETWEENPERSON.group');
end

% Format: The prep_4_apply_signatures_and_save script extracts signature responses and saves them.
% These fields contain data tables:
% DAT.SIG_conditions.(data scaling).(similarity metric).(signaturename)
% DAT.SIG_contrasts.(data scaling).(similarity metric).(signaturename)
%
% signaturenames is any of those from load_image_set('npsplus')
% (data scaling) is 'raw' or 'scaled', using DATA_OBJ or DATA_OBJsc
% (similarity metric) is 'dotproduct' or 'cosine_sim'
%
% Each of by_condition and contrasts contains a data table whose columns
% are conditions or contrasts, with variable names based on DAT.conditions
% or DAT.contrastnames, but with spaces replaced with underscores.
%
% Convert these to numerical arrays using table2array:
% table2array(DAT.SIG_contrasts.scaled.dotproduct.NPSneg)
%
% DAT.SIG_conditions.raw.dotproduct = apply_all_signatures(DATA_OBJ, 'conditionnames', DAT.conditions);
% DAT.SIG_contrasts.raw.dotproduct = apply_all_signatures(DATA_OBJ_CON, 'conditionnames', DAT.conditions);

k = length(DAT.conditions);
nplots = length(signatures_to_plot);
mysignames = strcat(signatures_to_plot{:});

myfontsize = get_font_size(k);
myaxislabels = format_strings_for_legend(DAT.conditions);
mypointsize = get_point_size(nplots, k);

%% Signature Response - conditions
% ------------------------------------------------------------------------

figtitle = sprintf('%s conditions %s %s', mysignames, myscaling, mymetric);
printhdr(figtitle);

fighan = create_figure(figtitle, 1, nplots);
adjust_fig_position_for_long_xlabel_names(fighan);

clear axh

for n = 1:nplots
    
    axh(n) = subplot(1, nplots, n);
    
    mysignature = signatures_to_plot{n};
    mydata = table2array(DAT.SIG_conditions.(myscaling).(mymetric).(mysignature));
    
    % get condition-specific group covariate data if any
    % this will not work yet, because barplot_columns cannot handle
    % condition-specific covariates. See "group diffs" script.
    %     mygroupnamefield = 'conditions';  % 'conditions' or 'contrasts'
    %     [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, n);
    
    handles = barplot_columns(mydata, 'title', format_strings_for_legend(mysignature), 'colors', DAT.colors, 'MarkerSize', mypointsize, 'dolines', 'nofig', 'names', myaxislabels, 'covs', group, 'wh_reg', 0);
    
    set(axh(n), 'FontSize', myfontsize);
    if n == 1, ylabel(format_strings_for_legend(mymetric)); else, ylabel(' '); end
    xlabel('')
        
    drawnow
end

kludgy_fix_for_y_axis(axh);

plugin_save_figure;
%close


%% Signature Response - contrasts
% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end
% ------------------------------------------------------------------------


figtitle = sprintf('%s contrasts %s %s', mysignames, myscaling, mymetric);
printhdr(figtitle);

fighan = create_figure(figtitle, 1, nplots);
adjust_fig_position_for_long_xlabel_names(fighan);

kc = size(DAT.contrasts, 1);
myfontsize = get_font_size(kc);
myaxislabels = format_strings_for_legend(DAT.contrastnames);
mypointsize = get_point_size(nplots, kc);

clear axh

for n = 1:nplots
    
    axh(n) = subplot(1, nplots, n);
    
    mysignature = signatures_to_plot{n};
    mydata = table2array(DAT.SIG_contrasts.(myscaling).(mymetric).(mysignature));
    
    % get condition-specific group covariate data if any
    % this will not work yet, because barplot_columns cannot handle
    % condition-specific covariates. See "group diffs" script.
    %     mygroupnamefield = 'contrasts';  % 'conditions' or 'contrasts'
    %     [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, n);
    
    handles = barplot_columns(mydata, 'title', format_strings_for_legend(mysignature), 'colors', DAT.contrastcolors, 'MarkerSize', mypointsize, 'nofig', 'names', myaxislabels, 'covs', group, 'wh_reg', 0);
    
    set(axh(n), 'FontSize', myfontsize);
    if n == 1, ylabel(format_strings_for_legend(mymetric)); else, ylabel(' '); end
    xlabel('')
    
    drawnow
end

kludgy_fix_for_y_axis(axh);

plugin_save_figure;
%close

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

end

% Not used - post hoc setting
function set_point_size(handles, n, k)

myhandles = handles.point_han(:);
myhandles(cellfun(@isempty, myhandles)) = [];
ptsize = get_point_size(n, k);
ptfun = @(x) set(x, 'MarkerSize', ptsize);
cellfun(ptfun, myhandles);

end


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
