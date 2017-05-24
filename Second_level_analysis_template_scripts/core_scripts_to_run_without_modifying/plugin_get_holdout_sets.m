% get holdout set for SVM contrasts, 2nd-level batch scripts

% hard-coded options
% 'fivefold_leave_whole_subject_out' : 5-fold cross-validation, leaving
% whole subject out (all images from subject across all conditions)
% 'leave_one_subject_out' : leave one whole subject out

holdout_set_type = 'fivefold_leave_whole_subject_out';
nfolds = 5;

outcome_value = zeros(size(condition_codes));
holdout_set = {};

switch holdout_set_type
    
    case 'leave_one_subject_out'
        
        printhdr('Holdout set: leave one whole subject out');
        
        for i = 1:length(wh)
            
            n = sum(condition_codes == i);
            holdout_set{i} = [1:n]';
            
            outcome_value(condition_codes == i) = sign(mycontrast(wh(i)));
            
        end
        
    case 'fivefold_leave_whole_subject_out'
        
        clear n
        
        printhdr('Holdout set:  5-fold cross-validation, leaving whole subject out');
        
        for i = 1:length(wh) % wh is which conditions have non-zero contrast weights
            
            n(i) = sum(condition_codes == i);
            holdout_set{i} = zeros(n(i), 1);
            
            outcome_value(condition_codes == i) = sign(mycontrast(wh(i)));
            
        end
        
        % Take largest set and stratify into k folds
        % Or, if equal size sets, pick first
        [~, wh_max_imgs] = max(n);
        
        cvpart = cvpartition(n(wh_max_imgs),'k',nfolds);
        
        % Assign test set for each fold to all images in paired conditions
        % If participants are crossed with conditions, this leaves one whole participant out (all images across conditions)
        
        for i = 1:nfolds
            
            mytest = cvpart.test(i);
            
            for j = 1:length(wh)
                
                holdout_set{j}(mytest(1:n(j))) = i;  % works if some conditions have fewer images, though we expect them to match
                
            end
            
        end
        
    otherwise
        error('illegal holdout set keyword option');
end


holdout_set = cat(1, holdout_set{:});