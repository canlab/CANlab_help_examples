function NPS_region_vals = plugin_extract_local_nps_region_vals(second_level_DAT_object, my_region)
%% Helper function to extract local NPS region values from DAT object
%
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ..
%
% :Usage:
% ::
%     **NOTE**: This script and it's counterpart,
%     plugin_plot_local_nps_region_vals.m, ONLY pertain to the CANlab 2nd level
%     script system. They are not for general use. The input data object
%     for this script is a DAT object, which is specific to the 2nd level
%     script system, and other data objects may not work as intended with
%     this function. 
%
%
%     NPS_region_vals = extract_local_nps_region_vals(second_level_DAT_object, nps_region_of_interest)
%
%
% :Inputs:
%   1.) An CANlab 2nd level batch script DAT object: This is most likely created by using the
%   canlab 2nd level scripts, which can create a DAT object with the
%   property NPSsubregions. This function will use this property to extract
%   relevant data.
%
%   2.) An NPS region of interest: This can be any of the positive or
%   negative regions of the NPS, which include:
%
%       posnames: {'vermis'  'rIns'  'rV1'  'rThal'  'lIns'  'rdpInsDATA_STRUCT'  'rS2_Op'  'dACC'}
%       negnames: {'rLOC'  'lLOC'  'rpLOC'  'pgACC'  'lSTS'  'rIPL'  'PCC'}
%
%  :Outputs:
%   1.) NPS_region_vals: A data structure with the following properties
%        A.) Region: This is the NPS region from which the function is extracting data
%        B.) condition_data: Values from input fmri_data_object 
%             (usually DAT from 2nd level analysis) that correspond to NPS activation 
%              in input my_region. Values grouped by conditions in input fmri_data_object. 
%              This function pulls from fmri_data_object.NPSsubregions
%        C.) condition_names: Names of conditions from
%             fmri_data_object (usually DAT from 2nd level analysis) that
%             describe the condition_data groups. This function pulls from input
%             fmri_data_object.conditions
%        D.) contrast_data: Values from input fmri_data_object 
%             (usually DAT from 2nd level analysis) that correspond to NPS activation 
%              in input my_region. Values grouped by contrasts in input fmri_data_object. 
%              This function pulls from fmri_data_object.NPSsubregions
%        E.) contrast_names: Names of contrasts from fmri_data_object 
%              (usually DAT from 2nd level analysis) that describe the 
%               contrast_data groups. This function pulls from input
%             fmri_data_object.contrastnames
%        F.) colors: Colors pulled from input fmri_data_object for plotting
%        by conditions
%        G.) contrast_colors: Colors pulled from input fmri_data_object for
%        plotting by contrasts
% :Examples:
%  (1) NPS_region_vals = extract_local_nps_region_vals(DAT, 'dACC') %saves dACC
%  values to new variable NPS_region_vals
%
%   (2)To load in a CANlab second-level analysis session, extract an NPS subregion, and
%   then plot it by condition/contrast:
%
%   %reload second level analysis objects
%   addpath(genpath('/path/to/data/files'));
%   a_set_up_paths_always_run_first;
%   b_reload_saved_matfiles
%
%   %Example to extract dACC from DAT
%   NPS_local_dACC = extract_local_nps_region_vals(DAT, 'dACC')
%
%   %Example to plot newly extrated dACC object
%   plot_local_nps_region_vals(NPS_local_dACC)




% Get INPUTS
region = my_region;
in_DAT = second_level_DAT_object;

% check input region and designate pos or neg NPS 
if sum(strcmp(in_DAT.NPSsubregions.posnames, region)) == 1
    pos_or_neg_field = 'npspos_by_region';  % set flag field to positive
    wh_region = strcmp(in_DAT.NPSsubregions.posnames, region);  % find index of input region
    sprintf('Input region %s is an NPS Pos region.', region)
    
elseif sum(strcmp(in_DAT.NPSsubregions.negnames, region)) == 1
    pos_or_neg_field = 'npsneg_by_region';  % set flag field to negative
    wh_region = strcmp(in_DAT.NPSsubregions.negnames, region);  % find index of input region
    sprintf('Input region %s is an NPS Neg region.', region)
    
else
    error('Bad Region Name')
end

% Check input data for specified region for each condition
region_index = find(wh_region);
for i = 1:length(in_DAT.NPSsubregions.(pos_or_neg_field))
    if size(in_DAT.NPSsubregions.npspos_by_region{i}, 2) < region_index
        warning('Input object does not have NPS Data for specified region for every condition')
    end


NPS_region_vals = [];
NPS_region_vals.region = region;

k = length(in_DAT.conditions);
kc = length(in_DAT.contrastnames);

% check for problems
if sum(wh_region) > 1 || sum(wh_region) == 0, error('Bad region name'); end

% get the condition data
NPS_region_vals.condition_data = cell(1, k);
NPS_region_vals.conditions = in_DAT.conditions;

for i = 1:k
    NPS_region_vals.condition_data{i} = in_DAT.NPSsubregions.(pos_or_neg_field){i}(:, wh_region);
end

% get the contrast data
NPS_region_vals.contrastnames = in_DAT.contrastnames;

myfield = [pos_or_neg_field '_contrasts'];

for i = 1:kc
    NPS_region_vals.contrast_data{i} = in_DAT.NPSsubregions.(myfield){i}(:, wh_region);
end

% Copy colors for use later in plotting
NPS_region_vals.colors = in_DAT.colors;
NPS_region_vals.contrastcolors = in_DAT.contrastcolors;

end
