%% Make polar wedge plots for signatures
% This example shows how to load several signatures and plot their cosine
% similarities with a set of resting-state networks, to interpret the
% signatures in terms of networks.
%


%% General instructions
%
% Before you start, the CANlab_Core_Tools must be added to your path with
% subfolders. Otherwise, you will get errors.
%
% Sample datasets are in the "Sample_datasets" folder in CANlab_Core_Tools.
%
% This example will use signatures, including the NPS, PINES, and VPS.
% This requires the canlab_private repository, which has the signatures, for the 
% example to run correctly. You can adapt it for any pattern you are
% interested in, though.

%% Load the signature patterns 

[npsobj, npsobjnames] = load_image_set('npsplus'); % 1 is NPS, 4 is SIIPS, 5 is PINES, 7 is VPS
wh = [1 5 7];

k = length(wh);

%% Plot cosine similarity with the Buckner Lab networks
% Orange colors are positive associations
% Blue colors are negative associations
% The radius of the 'spokes' is proportional to the cosine similarity, and
% area of the wedges is proportional to variance in signature weights explained by the network pattern

create_figure('Signature wedge plots', 1, k);

for i = 1:length(wh)
    
    disp(npsobjnames{wh(i)})
    disp('-----------------------------------------');
    
    subplot(1, k, i);
    hold on
    
    mysignature = get_wh_image(npsobj, wh(i));
    
    % Plot similarity
    stats = image_similarity_plot(mysignature, 'cosine_similarity', 'bucknerlab_wholebrain', 'colors', {[1 .7 0] [.3 0 .7]}, 'bicolor');
    title(npsobjnames{wh(i)});
    
    % Same, but use older polar plot style
    % stats = image_similarity_plot(mysignature, 'cosine_similarity', 'bucknerlab_wholebrain', 'plotstyle', 'polar');
    
%     %     
%     stats = image_similarity_plot(mysignature, 'cosine_similarity', 'bucknerlab_wholebrain', 'colors', {[1 .7 0]});
%     title(npsobjnames{wh(i)});
end

%% Try using stripes for negative values

create_figure('Signature wedge plots 2', 1, k);
colors = colorcube_colors(length(wh));

for i = 1:length(wh)
    
    disp(npsobjnames{wh(i)})
    disp('-----------------------------------------');
    
    subplot(1, k, i);
    hold on
    
    mysignature = get_wh_image(npsobj, wh(i));
    
    % Plot similarity
    stats = image_similarity_plot(mysignature, 'cosine_similarity', 'bucknerlab_wholebrain', 'colors', colors(i));
    title(npsobjnames{wh(i)});
    
end

%% Polar plot style

create_figure('Signature polar plots', 1, k);
colors = colorcube_colors(length(wh));

for i = 1:length(wh)
    
    disp(npsobjnames{wh(i)})
    disp('-----------------------------------------');
    
    subplot(1, k, i);
    hold on
    
    mysignature = get_wh_image(npsobj, wh(i));
    
    % Plot similarity
    stats = image_similarity_plot(mysignature, 'cosine_similarity', 'bucknerlab_wholebrain', 'colors', colors(i), 'plotstyle', 'polar');
    title(npsobjnames{wh(i)});
    
end

%% We can also make polar and wedge plots for averages across individual subject maps.
% This example loads a sample emotion regulation dataset, and makes several
% kinds of plots: Wedge and polar plots of average network similarity
% across subjects, with error bars, and a polar plot of the individual
% subjects.

obj = load_image_set('emotionreg');
create_figure('wedge_and_polar_emoreg', 1, 3);

% Yellow: positive associations. Blue: Negative associations.  Plot shows mean +- std. error for each pattern of interest
stats = image_similarity_plot(obj, 'plotstyle', 'wedge', 'bucknerlab', 'nofigure');

subplot(1, 3, 2);

% Outside circle: positive associations. Inside circle: Negative associations.  Plot shows mean +- std. error for each pattern of interest
stats = image_similarity_plot(obj, 'plotstyle', 'polar', 'average', 'bucknerlab', 'nofigure', 'colors', {[1 0 0] [.7 0 0]});

subplot(1, 3, 3);

[stats hh hhfill] = image_similarity_plot(obj, 'plotstyle', 'polar', 'bucknerlab', 'nofigure');
delete(hhfill{1})  % Delete fill so we can see all the lines

drawnow, snapnow

%% Apply the PLS signatures from Kragel et al. 2018 to the emotion regulation dataset

% Load PLS signatures from Kragel et al. 2018
[obj, names] = load_image_set('pain_cog_emo');
bpls_wholebrain = get_wh_image(obj, [8 16 24]);
names_wholebrain = names([8 16 24]);
bpls_subregions = get_wh_image(obj, [1:6 9:14 17:22]);
names_subregions = names([1:6 9:14 17:22]);

% Load test data: Emotion regulation from Wager et al. 2008
test_data_obj = load_image_set('emotionreg');

% Make plots
% Yellow: positive associations. Blue: Negative associations.  Plot shows mean +- std. error for each pattern of interest

create_figure('Kragel Pain-Cog-Emo maps', 1, 2);
stats = image_similarity_plot(test_data_obj, 'average', 'mapset', bpls_wholebrain, 'networknames', names_wholebrain, 'nofigure');
subplot(1, 2, 2)
stats = image_similarity_plot(test_data_obj, 'average', 'mapset', bpls_subregions, 'networknames', names_subregions, 'nofigure');

drawnow, snapnow
