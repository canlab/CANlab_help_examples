%% Set up conditions 
% ------------------------------------------------------------------------

% conditions = {'C1' 'C2' 'C3' 'etc'};
% structural_wildcard = {'c1*nii' 'c2*nii' 'c3*nii' 'etc*nii'};
% functional_wildcard = {'fc1*nii' 'fc2*nii' 'fc3*nii' 'etc*nii'};
% colors = {'color1' 'color2' 'color3' etc}  One per condition

fprintf('Image data should be in /data folder\n');

DAT = struct();

% Names of subfolders in /data
DAT.subfolders = {'Pain_copes' 'Nausea_cope4m1' 'Itch_copes_combo'};

% Names of conditions
DAT.conditions = {'Pain' 'Nausea' 'Itch'};

DAT.conditions = format_strings_for_legend(DAT.conditions);

DAT.structural_wildcard = {};
DAT.functional_wildcard = {'cope3*nii' 'cope4*nii' 'cope1*nii'};

% Set Contrasts
% ------------------------------------------------------------------------

% Vectors across conditions
DAT.contrasts = [1 0 0; 0 1 0; 0 0 1];
    
DAT.contrastnames = {'Pain' 'Nausea' 'Itch'};

DAT.contrastnames = format_strings_for_legend(DAT.contrastnames);


% Set Colors
% ------------------------------------------------------------------------

% Default colors: Use Matlab's default colormap
% Other options: custom_colors, seaborn_colors, bucknerlab_colors

DAT.colors = custom_colors([.8 .7 .2], [.5 .2 .8], length(DAT.conditions));

DAT.contrastcolors = custom_colors ([.2 .2 .8], [.2 .8 .2], length (DAT.contrasts));

% colors = colormap; % default list of n x 3 color vector
% colors = mat2cell(colors, ones(size(colors, 1), 1), 3)';
% DAT.colors = colors;
% clear colors
%close

disp('SET up conditions, colors, contrasts in DAT structure.');


% Set BETWEEN-CONDITION contrasts, names, and colors
% ------------------------------------------------------------------------
% Currently used in c2c_SVM_between_condition_contrasts
%
% Matrix of [n contrasts x k conditions]

DAT.between_condition_cons = [1 -1 0;
                              1 0 -1];

DAT.between_condition_contrastnames = {'Pain vs Nausea' 'Pain vs Itch'};
          
DAT.between_condition_contrastcolors = custom_colors ([.2 .2 .8], [.2 .8 .2], size(DAT.between_condition_cons, 1));


