%% Multi-level kernel density (MKDA) meta-analysis example: Agency database
% The starting point for coordinate-based meta-analysis (CBMA) is a text file 
% with the information entered from published studies. In this example, the 
% information is contained in the file "Agency_meta_analysis_database.txt"
% It is in the Neuroimaging_Pattern_Masks repository on Github. 
% 
% This file should be on your Matlab path:
% Neuroimaging_Pattern_Masks/CANlab_Meta_analysis_maps/2011_Agency_Meta_analysis/Agency_meta_analysis_database.txt

%% Section 1: Locate the coordinate database file
%

dbfilename = 'Agency_meta_analysis_database.txt';
dbname = which(dbfilename);

if isempty(dbname), error('Cannot locate the file %s\nMake sure it is on your Matlab path.', dbfilename); end

%% Section 2: 
%

