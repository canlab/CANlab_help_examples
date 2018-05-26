function [group, groupnames, groupcolors] = plugin_get_group_names_colors(DAT, mygroupnamefield, i)
% 
% Helper function to get the grouping variable from the DAT structure that
% is specific to the condition/contrast of interest, indexed by 
% mygroupnamefield = 'condition' or 'contrast', and i indexes
% contrast/condition number. (Enter tables in each cell)
%
% If you enter a different group variable for each condition/contrast in
% DAT.BETWEENPERSON.conditions{i} and  DAT.BETWEENPERSON.contrasts{i}, then
% these condition/contrast-specific variables will be used. (Enter numeric codes) 
%
% Alternatively, if these are empty and you enter a single variable in 
% DAT.BETWEENPERSON.group, this will be used.
%
% Returns a numeric vector of codes.

group = []; groupnames = []; groupcolors = [];

% ...We have group variables for each condition or contrast
if isfield(DAT, 'BETWEENPERSON') && ...
        isfield(DAT.BETWEENPERSON, mygroupnamefield) && ...
        iscell(DAT.BETWEENPERSON.(mygroupnamefield)) && ...
        length(DAT.BETWEENPERSON.(mygroupnamefield)) >= i && ...
        ~isempty(DAT.BETWEENPERSON.(mygroupnamefield){i})
    
    group = DAT.BETWEENPERSON.(mygroupnamefield){i};
    
    % strip id variable
    wh_omit = strcmp(group.Properties.VariableNames, 'id');
    omitname = group.Properties.VariableNames(wh_omit);
    if ~isempty(omitname), group.(omitname{1}) = []; end
    
    % ...We have only a single group variable
elseif isfield(DAT, 'BETWEENPERSON') && ...
        isfield(DAT.BETWEENPERSON, 'group') && ...
        ~isempty(DAT.BETWEENPERSON.group)
    
    group = DAT.BETWEENPERSON.group;

end

% Get names for the two groups if we have them, or create generic ones
if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'groupnames')
    groupnames = DAT.BETWEENPERSON.groupnames;
elseif istable(group)
    groupnames = group.Properties.VariableNames(1);
else
    groupnames = {'Group-Pos' 'Group-neg'};
end

% Get colors for the two groups if we have them, or create generic ones
if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'groupcolors')
    groupcolors = DAT.BETWEENPERSON.groupcolors;
else
    groupcolors = seaborn_colors(2);
end

if istable(group), group = table2array(group); end

if ~isempty(group), disp('Controlling for between-image group variable.'); end

end
