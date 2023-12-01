function move_betas_to_secondlvl(firstlvl_dir, datadir, operation, varargin)
% MOVE_BETAS_TO_SECONDLVL Move beta images to a second-level analysis directory.
%
% This function moves or creates symbolic links to beta images from a first-level
% analysis directory to a second-level analysis directory. It is designed to be 
% used with BIDS-formatted datasets and supports operations to either copy the 
% beta images or create symbolic links.
%
% Inputs:
%   firstlvl_dir - String. Path to the first-level analysis directory.
%   datadir - String. Path to the destination directory for the second-level analysis.
%   operation - String. Specify 'copy' to copy the files, or 'symlink' to create symbolic links.
%   varargin - (Optional) Cell array. Specific conditions to process,
%   passed in as a cell-array of char-strings e.g., {'hot', 'warm', 'imagine'}.
%
% Outputs:
%   None. This function operates by side effects (file operations).
%
% Example usage:
%   move_betas_to_secondlvl('/CANlab/labdata/data/WASABI/derivatives/canlab_firstlvl/sub-SID00XXXX/ses-0X/func/firstlvl/bodymap', ...
%       '/CANlab/labdata/projects/WASABI/WASABI_N_of_Few/analysis/WASABI-NofFew_BodyMap/data', 'symlink');
%
% Notes:
%   - This function is intended to be used as part of a SLURM job script.
%   - Requires appropriate permissions to read from the source and write to the destination directories.
%   - Symbolic link creation is platform dependent and may require administrative privileges.
%
% Author: Michael Sun, Ph.D.
% Created: 12/1/2023
% Last Modified: 12/1/2023

    % Extract sub, ses, and task using fileparts
    [path, task, ~] = fileparts(firstlvl_dir);
    
    % Extract sub, ses, and task from name_parts
    % sub = char(strcat('sub-', extractBetween(path, 'sub-', [filesep, 'ses'])));         % Assuming sub-SID*
    % ses = char(strcat('ses-', extractBetween(path, 'ses-', [filesep, 'func'])));         % Assuming ses-*
    
    % Creating a pattern that matches either '/' or '\'
    slashPattern = '[/\\]';
    
    % Extracting the subject ID
    subPattern = strcat('sub-', '.*?(?=', slashPattern, 'ses)');
    subMatch = regexp(path, subPattern, 'match');
    if ~isempty(subMatch)
        sub = subMatch{1};
    else
        sub = '';
    end
    
    % Extracting the session ID
    sesPattern = strcat('ses-', '.*?(?=', slashPattern, 'func)');
    sesMatch = regexp(path, sesPattern, 'match');
    if ~isempty(sesMatch)
        ses = sesMatch{1};
    else
        ses = '';
    end

    % Extracting task
    task=['task-', task];

    load(fullfile(firstlvl_dir, sub, 'SPM.mat'));
    if ~exist('varargin', 'var')
        conditions=varargin;
    end

    if ~exist('conditions', 'var')
        conditions={};
    end

    if isempty(conditions)
        % If no conditions are passed in, generate a list of conditions
        % from SPM.xX.name that don't include constants or noise (R)
        % regressors.

        % Regular expression pattern
        % Pattern for 'R' followed by one or more digits, or 'constant'
        pattern = '(R\d+|constant)$';
        
        % Finding indices of cells that do not match the pattern
        idx = cellfun(@isempty, regexp(SPM.xX.name, pattern));
        
        % The cells that do not contain 'R' followed by numbers or 'constant'
        conditions = SPM.xX.name(idx);

        % Remove 'Sn(*) ' prefix
        pattern = 'Sn\(\d+\) ';
        % Stripping the pattern from each string in result using
        % regex-replace
        conditions = regexprep(conditions, pattern, '');
        % Remove '* *bf(*)' suffix
        pattern = ' \*bf\(\d+\)';
        conditions = regexprep(conditions, pattern, '');

        % Extract only the unique conditions
        conditions=unique(conditions);
    end

    for k = 1:numel(conditions)
        % Search for the beta number that corresponds to the condition in
        % question.
        betanum=find(contains(SPM.xX.name, conditions{k}));
        if ~isempty(betanum)
            % 
            for i = 1:numel(betanum)
                betafile=fullfile(firstlvl_dir, sub, ['beta_', sprintf('%04d',betanum(i)),'.nii']);
                if ~isempty(sub)
                    bidsname=[sub,'_'];
                end
                if ~isempty(ses)
                    bidsname=[bidsname, ses,'_'];
                end
                run=['run-',char(extractBetween(SPM.xX.name(betanum(i)), 'Sn(', ')'))];
                bidsname=sprintf('%s%s_%s.nii', bidsname, task, run);
                
                destination_folder=fullfile(datadir,sub,conditions{k});
    
                % Check if the destination folder exists, and create it if it does not
                if ~exist(destination_folder, 'dir')
                    mkdir(destination_folder);
                end
    
                if strcmp(operation, 'copy')
                    copyfile(betafile, destination_folder);
                    new_betafile=fullfile(datadir,sub,conditions{k}, ['beta_', sprintf('%04d',betanum(i)),'.nii']);
                    renamed_betafile=fullfile(datadir,sub,conditions{k}, bidsname);
                    movefile(new_betafile, renamed_betafile);
                elseif strcmp(operation, 'symlink')
                    % Create symlink using system command
                    % Rename the file into BIDS-format
                    dest_link_path = fullfile(destination_folder, bidsname);
                    if ispc  % Check if the system is Windows                    
                        cmd = ['cmd.exe /C mklink "' dest_link_path '" "' betafile '"'];
                    else
                        cmd = sprintf('ln -s %s %s', betafile, dest_link_path);
                    end
                    system(cmd);
                else
                    error('Invalid operation. Choose either "copy" or "symlink".')
                end
            end
        end              
    end
end