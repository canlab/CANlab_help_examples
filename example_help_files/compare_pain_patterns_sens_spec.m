%% Compare pain-related brain patterns

%% About this script
% 
% This script compares several pain-related 'signature' patterns developed in the
% CANlab over the past years. It uses a test dataset of N = 270
% participants from Kragel et al. 2018 to test the patterns' sensitivity
% and specificity to pain.
%
% it collects some key pain-classification stats in a table called
% |pain_table| for comparison across signatures
%
% At this writing, it uses the fmri_data method
% |test_pattern_on_kragel_2018_n270_data|
% This tests the cosine similarity between a pattern and each test image,
% and uses |roc_plot| to establish an optimal balanced accuracy threshold
% for one-vs-all classification of pain, cognitive control, and emotion
% task categories.
%
% Tests are prospective tests on new datasets and are
% largely unbiased. However, there is some overlap between thermal pain
% datasets (Studies 1 and 2) and the training data. This presents a
% potential for bias, which can be assessed by comparing these studies to
% other, independent test studies.
%
% One pattern, 'plspain', was developed on the N = 270 data and is not tested, as
% this test is biased. 

% ----------------------------------------------------------------------
% Display helper functions: Called by later scripts
% ----------------------------------------------------------------------

dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);

disp('Process: test_pattern_on_kragel_2018_n270_data');
printstr(dashes)

% Init
pain_table = table();

% ----------------------------------------------------------------------
% Loop through patterns
% ----------------------------------------------------------------------

pattern_names = {'nps' 'cpdm' 'pdm1' 'siips' 'fmpain'};

for i = 1:length(pattern_names)

    pat_name = pattern_names{i};
    
    printhdr(' '); printhdr(pat_name); printhdr(' ');
    
    switch pat_name
        case 'pdm1'
            obj = load_image_set('pdm');
            obj = get_wh_image(obj, 2);
            
        otherwise
            obj = load_image_set(pat_name);
    end

STATS = test_pattern_on_kragel_2018_n270_data(obj);

drawnow, snapnow

pain_table(i, :) = STATS.summary_table(1, :);
pain_table.Properties.RowNames{i} = pat_name;

end % Pattern loop

%% Final comparison table

disp(pain_table)



