function canlab_help_publish(pubfilename)
% This function publishes a help file to HTML
%
% Enter the name of the script to publish as the input argument
% canlab_help_publish('CANlab_help_examples_TEMPLATE')

close all
% clear all

codedir = fileparts(which('CANlab_help_examples_TEMPLATE'));
codedir = fileparts(codedir);

if isempty(codedir), error('Cannot find CANlab_help_examples directory on path.'), end


pubdir = fullfile(codedir, 'published_html', pubfilename);
if ~exist(pubdir, 'dir'), mkdir(pubdir), end

% ------------------------------------------------------------------------
%pubfilename = fullfile(pubdir,

p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 800, ...
    'format', 'html', 'outputDir', pubdir, ...
    'showCode', true, 'stylesheet', which('mxdom2simplehtml_CANlab.xsl'));

publish(pubfilename, p)

close all

end