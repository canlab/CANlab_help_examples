% publish script
% run to print results to PDF file
cd('/Users/tor/Google_Drive/Wagerlab_Single_Trial_Pain_Datasets/Data/Tor_bmrk3_datashare')

scriptsdir = '/Users/tor/Google_Drive/Wagerlab_Single_Trial_Pain_Datasets/scripts/BMRK3';
addpath(scriptsdir)

% ------------------------------------------------------------------------
pubfilename = 'bmrk3_analysis_by_temp_walkthrough';

p = struct('useNewFigure', false, 'maxHeight', 1200, 'maxWidth', 2000, ...
    'format', 'html', 'outputDir', fullfile(pwd, pubfilename), 'showCode', true);

publish('bmrk3_analysis_by_temp_walkthrough.m', p)

% ------------------------------------------------------------------------

rmpath(scriptsdir)
