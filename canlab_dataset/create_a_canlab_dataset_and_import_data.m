
% The canlab_dataset object is a way of collecting behavioral data
% and/or meta-data about fMRI (and other) studies in a standardized format.
% It has entries for experiment description, Subject-level
% variables, Event-level variables (e.g., for fMRI events or trials in a
% behavioral experiment) and other fields for sub-event level  data (e.g.,
% physio or continuous ratings within trials).

% for an overview, see:

help(canlab_dataset)

% and, for things you can do with dataset objects:
methods(canlab_dataset)

%% Specify filenames

% Between-person experiment-level datafile
% This is an fmri-type file, with a specific format
% - Column names are first row
% - You need columns named "id" "names"	"units"	"descrip"
% - id has one row per subject, with text ids
% - names has one row per Subject_Level variable, listing variable name -
%   no special characters or spaces
% - units specifies units for each variable, text
% - descrip specifies description for each variable, text
% - other columns can be added, but names must be specified under names
% - Additional columns should be named with variable names in "names"
% column, with one row per subject with Subject_Level data
% - ONLY between subject columns identified in the 'names' column are added.

DesignFile = which('Sample_canlab_dataset_experiment_level.xlsx');

if isempty(DesignFile), error('You need the sample filename on your path.  It is in the CANlab_help_examples github repository.'); end

% Subject-specific files with onsets and event-level data for a simulated
% fMRI experiment

SubjectFiles = filenames(fullfile(pwd,'Sample_canlab_dataset_subject*.xlsx'));


%% Create an empty canlab dataset object.
% This creates a new object with standard variable names, etc.
% This example is for an fmri dataset, which requires specific variable
% names with the same meaning across datasets.

dat = canlab_dataset('fmri');

%% Read the sample files and add them to the object
% This may not work (yet) for adding to an existing object.  (see below)

dat = read_from_excel(dat, DesignFile, SubjectFiles, 'fmri');

% Now print a summary
print_summary(dat)


% These are the variables you need at minimum for an fmri-type object:
%
%         Var_name                                      Description
%     ________________    ________________________________________________________________________
%
%     'SessionNumber'     'Within-study session number (e.g. 1,2,3)'
%     'RunName'           'A descriptive name of the fMRI run (e.g. PreRevealPlacebo)'
%     'RunNumber'         'Within-session run number (e.g. 1,2,3)'
%     'TaskName'          'The name of the task being performed during this event (e.g. Compassi?'
%     'TrialNumber'       'The trial number within the task for this event (e.g. 1,2,3)'
%     'EventName'         'The name of this event (e.g. HighPain, Cue, Fixation)'
%     'EventOnsetTime'    'The start time for each event in sec from start of the run'
%     'EventDuration'     'The length of time this event lasts in sec'
%

%% Another option, less complete
% But you can add to an existing canlab_dataset object!!

DesignFile = which('Sample_subject_level_data_to_add.xlsx');
dat = canlab_dataset('fmri');
dat = add_vars(dat, DesignFile, 'Subj_Level');
print_summary(dat)

