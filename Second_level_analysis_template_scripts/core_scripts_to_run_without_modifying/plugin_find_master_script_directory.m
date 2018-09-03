masterscriptdir = what(fullfile('CANlab_help_examples', 'Second_level_analysis_template_scripts'));

if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
else
    masterscriptdir = masterscriptdir.path;
end


if isempty(masterscriptdir)
    error('Add Second_level_analysis_template_scripts folder from CANlab_help_examples repository to your path'); 
end
