function potential_outliers = canlab_simple_find_outliers(DATA_OBJ, condition_names)
% potential_outliers = canlab_simple_find_outliers(DATA_OBJ)
%
% Get outliers based on mahalanobis distance for each condition and print a short report
%
% e.g., potential_outliers = canlab_simple_find_outliers(DATA_OBJ, DAT.conditions)

dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('%s\n%s\n%s\n', dashes, str, dashes);

k = length(DATA_OBJ);
potential_outliers = cell(1, k);

for i = 1:k
    
    printhdr(condition_names{i});
    disp(' ');
    
    [ds, expectedds, p, wh_outlier_uncorr, wh_outlier_corr] = mahal(DATA_OBJ{i}, 'noplot', 'corr');
    potential_outliers{i} = wh_outlier_corr;
    
end

end % function

