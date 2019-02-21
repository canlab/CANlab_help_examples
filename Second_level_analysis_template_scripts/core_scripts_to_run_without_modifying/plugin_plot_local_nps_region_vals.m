function plugin_plot_local_nps_region_vals(nps_region_extract, save_dir)
%% Helper function to visualize local NPS region values from nps region extract (can be created by extract_local_nps_region_vals.m).
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
%
%
% :Usage:
% 
%     **NOTE**: This script and it's counterpart,
%     plugin_extract_local_nps_region_vals.m, ONLY pertain to the CANlab 2nd level
%     script system. They are not for general use. The input data object
%     for this script is a DAT object, which is specific to the 2nd level
%     script system, and other data objects may not work as intended with
%     this function. 
%
%      plot_local_nps_region_vals(NPS_region_values_object)
%
%
% :Inputs:
%   1.) An NPS_region_vals data object: This should be a data object including only
%   data from one NPS subregion. This object can be created using the
%   extract_local_nps_region_vals.m on a CANlab second level scripts DAT
%   object.
%
%  :Outputs:
%   1.) Two plots: One of the data from the NPS subregion of interest by
%   condition and one by contrast.
%
%  :Examples:
%   (1) plot_local_nps_region_vals(NPS_region_vals)
%
%   (2) To load in a CANlab second-level analysis session, extract an NPS subregion, and
%       then plot it by condition/contrast:
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

% Get input data
DATA_STRUCT = nps_region_extract;
num_cond = length(DATA_STRUCT.conditions); % get number of conditions
num_cont = length(DATA_STRUCT.contrastnames); % get number of contrasts

empty_conditions = cell(1,num_cond); % set condition names to empty string to plot clear x-axis
empty_contrasts = cell(1,num_cont); % set contrast names to empty string to plot clear x-axis


% Create empty plot 
f1 = create_figure(DATA_STRUCT.region, 1, 2);

% Get condition data and specify options to be plotted
mydata = DATA_STRUCT.condition_data;
input_options = {'colors', DATA_STRUCT.colors, 'nofig', 'names', empty_conditions, 'noviolin', 'noind'};

% Plot condition data
barplot_columns(mydata, input_options{:});

% Populate labels for conditions plot
%title('Conditions');
%ylabel(sprintf('%s local pattern response', DATA_STRUCT.region));
xlabel(sprintf(''));
ylabel(sprintf(''));

subplot(1, 2, 2);

% Get contrast data and specify options for plotting
mydata = DATA_STRUCT.contrast_data;
input_options = {'colors', DATA_STRUCT.contrastcolors, 'nofig', 'names', empty_contrasts, 'noviolin', 'noind'};

% Plot contrast data
barplot_columns(mydata, input_options{:});

% Populate labels for contrasts plot
%title('Contrasts');
%ylabel(sprintf('%s local pattern response', DATA_STRUCT.region));
xlabel(sprintf(''));
ylabel(sprintf(''));

%save output as Support vector graphics file image (SVG)
print(f1, [save_dir '/' DATA_STRUCT.region '_condition_contrast_plot'] , '-dsvg');
close all;
clear f1;
sprintf('Image %s _condition_contrast_plot.svg was saved to: \n %s', DATA_STRUCT.region, save_dir)
end
