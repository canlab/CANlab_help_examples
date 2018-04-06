%% Set up conditions 
% ------------------------------------------------------------------------

% conditions = {'C1' 'C2' 'C3' 'etc'};
% structural_wildcard = {'c1*nii' 'c2*nii' 'c3*nii' 'etc*nii'};
% functional_wildcard = {'fc1*nii' 'fc2*nii' 'fc3*nii' 'etc*nii'};
% colors = {'color1' 'color2' 'color3' etc}  One per condition

fprintf('Image data should be in /data folder\n');

DAT = struct();

% Names of subfolders in /data
DAT.subfolders = {'carfentanil' 'madam' 'raclopride'};

% Names of conditions
DAT.conditions = {'Mu-opioid' '5HT1A' 'Dopamine_D2'};

DAT.conditions = format_strings_for_legend(DAT.conditions);

DAT.structural_wildcard = {};
DAT.functional_wildcard = {'w*nii' 'w*nii' 'w*nii'};

% Set Colors
% ------------------------------------------------------------------------

% There are several options for defining colors for conditions and
% contrasts, or enter your own in a cell array of length(conditions) for
% DAT.colors
% Some options: scn_standard_colors, custom_colors, colorcube_colors, seaborn_colors, bucknerlab_colors

% DAT.colors = scn_standard_colors(length(DAT.conditions));
% DAT.colors = custom_colors(cm(1, :), cm(end, :), length(DAT.conditions));
% DAT.contrastcolors = custom_colors([.2 .2 .8], [.2 .8 .2], length(DAT.contrasts));

mycolors = colorcube_colors(length(DAT.conditions));

disp('SET up conditions, colors, contrasts in DAT structure.');
