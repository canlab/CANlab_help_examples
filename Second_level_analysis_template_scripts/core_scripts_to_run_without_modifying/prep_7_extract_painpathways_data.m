%
%
% Format: The prep_7 script extracts signature responses and saves them.
% These fields contain data tables:
% DAT.SIGNATURES.(signaturename).(data scaling).(similarity metric).by_condition
% DAT.SIGNATURES.(signaturename).(data scaling).(similarity metric).contrasts
%
% signaturenames is any of those from load_image_set('npsplus')
% (data scaling) is 'raw' or 'scaled', using DATA_OBJ or DATA_OBJsc
% (similarity metric) is 'dotproduct' or 'cosine_sim'
% 
% Each of by_condition and contrasts contains a data table whose columns
% are conditions or contrasts, with variable names based on DAT.conditions
% or DAT.contrastnames, but with spaces replaced with underscores.

% Load objects
load pain_pathways_region_obj_with_local_patterns.mat
load pain_pathways_atlas_obj.mat

k = length(DAT.conditions);
kc = size(DAT.contrasts, 1);

printhdr('Extracting PainPathways, adding to DAT.PAINPATHWAYS')

%% Region averages
% -------------------------------------------------------------------------

labels = pain_pathways_finegrained.labels;
labels_regions = pain_pathways.labels;

for j = 1:length(labels)
    DAT.PAINPATHWAYS.conditions_fine_region_means.(labels{j}) = table();
end

for j = 1:length(labels_regions)
    DAT.PAINPATHWAYS.conditions_region_means.(labels_regions{j}) = table();
end

for i = 1:k

    fine_region_means = extract_data(pain_pathways_finegrained, DATA_OBJ{i});
    
    for j = 1:length(labels)
        DAT.PAINPATHWAYS.conditions_fine_region_means.(labels{j}).(DAT.conditions{i}) = fine_region_means(:, j);
    end
    
    region_means = extract_data(pain_pathways, DATA_OBJ{i});
    
    for j = 1:length(labels_regions)
        DAT.PAINPATHWAYS.conditions_region_means.(labels_regions{j}).(DAT.conditions{i}) = region_means(:, j);
    end
    
end

% barplot_columns(DAT.PAINPATHWAYS.conditions_fine_region_means.rvm_R, 'noviolin');

%% Contrasts - Region averages
% -------------------------------------------------------------------------

connames = strrep(DAT.contrastnames, '-', '_');
connames = strrep(connames, '>', '_');
connames = strrep(connames, '<', '_');
connames = strrep(connames, ' ', '_');


for j = 1:length(labels)
    
    convalues = table2array(DAT.PAINPATHWAYS.conditions_fine_region_means.(labels{j})) * DAT.contrasts';
    
     DAT.PAINPATHWAYS.contrasts_fine_region_means.(labels{j}) = table();
     
    for i = 1:kc
        
        DAT.PAINPATHWAYS.contrasts_fine_region_means.(labels{j}).(connames{i}) = convalues(:, i);
        
    end
    
end

for j = 1:length(labels_regions)
    
    convalues = table2array(DAT.PAINPATHWAYS.conditions_region_means.(labels_regions{j})) * DAT.contrasts';
    
     DAT.PAINPATHWAYS.contrasts_region_means.(labels_regions{j}) = table();
     
    for i = 1:kc
        
        DAT.PAINPATHWAYS.contrasts_region_means.(labels_regions{j}).(connames{i}) = convalues(:, i);
        
    end
    
end
%%

figtitle = 'Sensory_thalamocortical_path';
create_figure(figtitle, 2, 2);
myfield = 'Thal_VPLM_L';
barplot_columns(DAT.PAINPATHWAYS.contrasts_region_means.(myfield), 'noviolin', 'colors', DAT.contrastcolors, 'nofigure');
title(format_strings_for_legend(myfield));
subplot(2, 2, 2)
myfield = 'Thal_VPLM_R';
barplot_columns(DAT.PAINPATHWAYS.contrasts_region_means.(myfield), 'noviolin', 'colors', DAT.contrastcolors, 'nofigure');
title(format_strings_for_legend(myfield));
subplot(2, 2, 3)
myfield = 'dpIns_L';
barplot_columns(DAT.PAINPATHWAYS.contrasts_region_means.(myfield), 'noviolin', 'colors', DAT.contrastcolors, 'nofigure');
title(format_strings_for_legend(myfield));
subplot(2, 2, 4)
myfield = 'dpIns_R';
barplot_columns(DAT.PAINPATHWAYS.contrasts_region_means.(myfield), 'noviolin', 'colors', DAT.contrastcolors, 'nofigure');
title(format_strings_for_legend(myfield));

%% NPS local response
% -------------------------------------------------------------------------

labels_regions = {pain_regions_nps.shorttitle};

for j = 1:length(labels_regions)
    DAT.PAINPATHWAYS.conditions_local_NPS.(labels_regions{j}) = table();
end

for i = 1:k
    
    region_obj = extract_data(pain_regions_nps, DATA_OBJ{i}); % needs some work - will break if objects are not same size. add nan-pad step
    region_obj_dat = cat(2, region_obj.dat);
    
    for j = 1:length(labels_regions)
        DAT.PAINPATHWAYS.conditions_local_NPS.(labels_regions{j}).(DAT.conditions{i}) = region_obj_dat(:, j);
    end
    
end

% Contrasts

for j = 1:length(labels_regions)
    
    convalues = table2array(DAT.PAINPATHWAYS.conditions_local_NPS.(labels_regions{j})) * DAT.contrasts';
    
     DAT.PAINPATHWAYS.contrasts_local_NPS.(labels_regions{j}) = table();
     
    for i = 1:kc
        
        DAT.PAINPATHWAYS.contrasts_local_NPS.(labels_regions{j}).(connames{i}) = convalues(:, i);
        
    end
    
end

%%

figtitle = 'Sensory_thalamocortical_path_NPS';
create_figure(figtitle, 2, 2);
myfield = 'Thal_VPLM_L';
barplot_columns(DAT.PAINPATHWAYS.contrasts_local_NPS.(myfield), 'noviolin', 'colors', DAT.contrastcolors, 'nofigure');
title(format_strings_for_legend(myfield));
subplot(2, 2, 2)
myfield = 'Thal_VPLM_R';
barplot_columns(DAT.PAINPATHWAYS.contrasts_local_NPS.(myfield), 'noviolin', 'colors', DAT.contrastcolors, 'nofigure');
title(format_strings_for_legend(myfield));
subplot(2, 2, 3)
myfield = 'dpIns_L';
barplot_columns(DAT.PAINPATHWAYS.contrasts_local_NPS.(myfield), 'noviolin', 'colors', DAT.contrastcolors, 'nofigure');
title(format_strings_for_legend(myfield));
subplot(2, 2, 4)
myfield = 'dpIns_R';
barplot_columns(DAT.PAINPATHWAYS.contrasts_local_NPS.(myfield), 'noviolin', 'colors', DAT.contrastcolors, 'nofigure');
title(format_strings_for_legend(myfield));

%% Save

printhdr('Save results');

savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, 'DAT', '-append');


