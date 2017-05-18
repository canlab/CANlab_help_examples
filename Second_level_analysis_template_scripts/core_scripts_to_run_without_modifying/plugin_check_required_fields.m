function ok_to_run = plugin_check_required_fields(DAT, required_fields)
% Plugin helper function for Second_level_analysis_template_scripts
% See those scripts for usage.
%
% Example:
% ok_to_run = plugin_check_required_fields(DAT, {'EMO_CAT_SIG_conditions'});

nfields = length(required_fields);
isok = false(nfields, 1);

for i = 1:nfields
    if isfield(DAT, required_fields{i}), isok(i) = true; end
end

ok_to_run = all(isok);

% Print warnings
if ~ok_to_run

    disp('Required fields are missing:')
    
    for i = 1:nfields
        if ~isok(i), disp(required_fields{i}); end
    end
    
    disp('Check and run prep scripts for setup. Skipping this analysis.');
    
end

end % function