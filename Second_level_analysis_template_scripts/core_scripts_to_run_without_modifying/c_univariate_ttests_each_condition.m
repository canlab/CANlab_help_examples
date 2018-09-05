
% T-tests for each condition separately
% ------------------------------------------------------------------------

k = length(DATA_OBJ);
t = cell(1, k);

for i = 1:k
    
    t{i} = ttest(DATA_OBJ{i});
    t{i} = threshold(t{i}, .01, 'unc');
    
end

o2 = canlab_results_fmridisplay([], 'multirow', 2);

for i = 1:k
    
    o2 = addblobs(o2, region(t{i}), 'wh_montages', [2*i-1:2*i]);
    o2 = title_montage(o2, 2*i, DAT.conditions{i});
    
    
end
