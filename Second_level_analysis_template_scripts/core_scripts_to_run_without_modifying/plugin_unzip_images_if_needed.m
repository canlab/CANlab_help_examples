function image_cell_str = plugin_unzip_images_if_needed(str)
% Take a string with wildcards (str) to list files, and return list of images image_string_matrix
% If no images, look for .gz version and unzip those.  
% If not found, return empty image_string_matrix
%
% image_string_matrix = plugin_unzip_images_if_needed(str)
% Used in prep_2 script

%[status,cmdout] = system(['ls ' strrep(str, ' ', '\ ')]);

image_cell_str = [];

% Check if images already exist
image_cell_str = filenames(str, 'absolute');

image_string_matrix = char(image_cell_str);
image_string_matrix = check_valid_imagename(image_string_matrix, 0);  % Return empty if not found

if ~isempty(image_string_matrix) % we have images
    return
    
else
    % image_string_matrix is empty
    % Try to unzip
    
    %fprintf('Didn''t find images. Trying to unzip images.');
    % try eval(['!gunzip ' strrep(str, ' ', '\ ') '.gz']), catch, end     % gunzip([str '.gz'])
    
    % Unzip command, replacing spaces with escape char \
    % Also force output, replacing original images
    
    cmdstr = ['gunzip -f ' strrep(str, ' ', '\ ') '.gz'];
    [status, cmdout] = system(cmdstr);  % cmdout is list of files; don't use, just for reference
    
    if status == 0
        
        disp('Unzipped .gz images successfully.');
        image_cell_str = filenames(str, 'absolute');
        
    else
        disp('Could not find images. Looked for .gz images, did not find them either.');
    end
    
end

end  % function

