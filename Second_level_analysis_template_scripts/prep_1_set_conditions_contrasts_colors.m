%% Set up conditions 
% ------------------------------------------------------------------------

% conditions = {'C1' 'C2' 'C3' 'etc'};
% structural_wildcard = {'c1*nii' 'c2*nii' 'c3*nii' 'etc*nii'};
% functional_wildcard = {'fc1*nii' 'fc2*nii' 'fc3*nii' 'etc*nii'};
% colors = {'color1' 'color2' 'color3' etc}  One per condition

fprintf('Image data should be in /data folder\n');

DAT = struct();

% Names of subfolders in /data
DAT.subfolders = {'s*' 's*' 's*' 's*'};

% Names of conditions
DAT.conditions = {'warm1' 'pain1' 'warm2' 'pain2'};

DAT.conditions = format_strings_for_legend(DAT.conditions);

DAT.structural_wildcard = {};
DAT.functional_wildcard = {'beta_0002_warm_run1.img' 'beta_0005_pain_run1.img' 'beta_0008_warm_run1.img' 'beta_0011_pain_run2.img'};

% Set Contrasts
% ------------------------------------------------------------------------

% Vectors across conditions
DAT.contrasts = [-1 1 -1 1; 1 1 -1 -1];
    
DAT.contrastnames = {'Pain-Warm' 'Run1-Run2'};

DAT.contrastnames = format_strings_for_legend(DAT.contrastnames);


% Set Colors
% ------------------------------------------------------------------------

% Default colors: Use Matlab's default colormap
% Other options: custom_colors, seaborn_colors, bucknerlab_colors

DAT.colors = custom_colors([.8 .7 .2], [.5 .2 .8], length(DAT.conditions));

DAT.contrastcolors = {[.2 .2 .8] [.2 .8 .2]};

% colors = colormap; % default list of n x 3 color vector
% colors = mat2cell(colors, ones(size(colors, 1), 1), 3)';
% DAT.colors = colors;
% clear colors
%close

disp('SET up conditions, colors, contrasts in DAT structure.');



