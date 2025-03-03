%% Load a test map to use as an example

ns = load(which('neurosynth_data_obj.mat'));
test_map = get_wh_image(ns.topic_obj_reverseinference, 1); % somatosensory topic


%% Run annotations

annotate_binary_results_map(test_map)

