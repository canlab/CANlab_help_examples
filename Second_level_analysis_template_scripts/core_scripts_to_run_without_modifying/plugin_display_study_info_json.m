printhdr('Study Info')

infofilename = fullfile(basedir, 'study_info.json');

if ~exist(infofilename)
    disp('Info file study_info.json is missing.');
    return
    
else
    
    textdat = fileread(infofilename);
    
end

if ~exist('jsondecode', 'builtin')

    disp('Matlab version needs updating: jsondecode.m is missing');
    return
   
end

try
    infostruct = jsondecode(textdat);
catch
    error('plugin_display_study_info_json cannot decode JSON file. Check file format.');
    return
end

N = fieldnames(infostruct);

for i = 1:length(N)
    
    myfield = N{i};
    
    mystr = infostruct.(myfield);
    
    if isempty(mystr), continue, end
    
    disp(myfield)
    
    % special string: weblinks
    if strcmp(myfield, 'Publication_URLs')
        for i = 1:size(mystr, 1)
            fprintf('<a href = "%s">%s</a>\n', mystr(i, :), mystr(i, :))
        end
        
        % other strings
    elseif isstr(mystr)
        disp(mystr)
    end
    
    disp(' ')
    
end