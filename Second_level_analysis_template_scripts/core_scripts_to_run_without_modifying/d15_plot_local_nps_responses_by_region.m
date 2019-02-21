%% Extract and Plot all NPS sub regions
% Once the CANlab second level batch prep_* sequence has been run, this
% script will identify all NPS subregions in the DAT object and then
% extract and plot those subregions one by one. Figures will automatically
% be saved in the figsavedir, which is set in a_set_up_paths_always_run_first.m

% get list of all NPS sub regions
regions = cat(2, DAT.NPSsubregions.posnames, DAT.NPSsubregions.negnames)

% Loop through DAT object and for each NPS sub region, extract data and
% plot
for i=1:length(regions)
nps_local_object = plugin_extract_local_nps_region_vals(DAT, regions{i});
plugin_plot_local_nps_region_vals(nps_local_object, figsavedir);
end