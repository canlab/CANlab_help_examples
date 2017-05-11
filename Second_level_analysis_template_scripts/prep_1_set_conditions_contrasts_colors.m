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

% There are several options for defining colors for conditions and
% contrasts, or enter your own in a cell array of length(conditions) for
% DAT.colors, and size(contrasts, 1) for DAT.contrastcolors
% It is better if contrasts have distinct colors from conditions

% Some options: scn_standard_colors, custom_colors, colorcube_colors, seaborn_colors, bucknerlab_colors

% DAT.colors = scn_standard_colors(length(DAT.conditions));
% DAT.colors = custom_colors(cm(1, :), cm(end, :), length(DAT.conditions));
% DAT.contrastcolors = custom_colors([.2 .2 .8], [.2 .8 .2], length(DAT.contrasts));

mycolors = colorcube_colors(length(DAT.conditions) + size(DAT.contrasts, 1));

DAT.colors = mycolors(1:length(DAT.conditions));
DAT.contrastcolors = mycolors(length(DAT.conditions) + 1:length(mycolors));


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


