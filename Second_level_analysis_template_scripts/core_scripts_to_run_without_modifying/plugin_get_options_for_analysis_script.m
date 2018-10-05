
if any(~options_exist)
    a2_set_default_options; 
end

printhdr('Options used in this analysis:');

for i = 1:length(options_needed)
    if ~exist(options_needed{i}, 'var')   % If still can't find it
        
        % ...use the default value specified above.
        if ischar(option_default_values{i})
        
            eval([options_needed{i} ' = ' option_default_values{i} ';']);
            
        elseif islogical(option_default_values{i})
            
            eval([options_needed{i} ' = logical(' num2str(option_default_values{i}) ');']);
            
        else
            
            eval([options_needed{i} ' = ' num2str(option_default_values{i}) ';']);
                        
        end
    end
    
    % Now print the option name and value
    eval(['myval = ' options_needed{i} ';']);
        
    if ischar(myval)
        fprintf('%s\t\t%s\n', options_needed{i}, myval);
    elseif islogical(myval)
        fprintf('%s\t\t%3.0f\n', options_needed{i}, myval);
    else
        fprintf('%s\t\t%3.2f\n', options_needed{i}, myval);
    end
    
end

fprintf('\n')

