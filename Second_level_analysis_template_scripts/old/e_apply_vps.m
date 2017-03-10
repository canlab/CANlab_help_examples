k = length(DAT.conditions);

vpsmask = which('bmrk4_VPS_unthresholded.nii');

%% VPS Response
% ------------------------------------------------------------------------

printhdr('VPS responses by condition');
% ------------------------------------------------------------------------

% Raw/Unscaled data VPS responses

clear vpsresponse

figtitle = 'VPS response raw data';
create_figure('vps');

% cell sizes
% sz = cellfun(@size, DAT.npsresponse, repmat({1}, 1, size(DAT.npsresponse, 2)), 'UniformOutput', false); 
% sz = cat(1, sz{:});
k = length(DAT.conditions);

for i = 1:k
    
    DAT.vpsresponse{i} = apply_mask(DATA_OBJ{i}, vpsmask, 'pattern_expression', 'ignore_missing');
    
end

disp(DAT.conditions)
barplot_columns(DAT.vpsresponse, figtitle, 'colors', DAT.colors, 'dolines', 'nofig');
set(gca, 'XTickLabel', DAT.conditions, 'XTickLabelRotation', 45, 'FontSize', 14);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);


% WM_CSF-adjusted data VPS responses
% ------------------------------------------------------------------------

disp(' ')
printhdr('VPS responses by condition - CSF-adjusted images');

clear vpsresponse

figtitle = 'VPS response CSF-adjusted data';
create_figure('vps');

for i = 1:k
    
    DAT.vpsresponsesc{i} = apply_mask(DATA_OBJsc{i}, vpsmask, 'pattern_expression', 'ignore_missing');
    
end

disp(DAT.conditions)
barplot_columns(DAT.vpsresponsesc, figtitle, 'colors', DAT.colors, 'dolines', 'nofig');
set(gca, 'XTickLabel', DAT.conditions, 'XTickLabelRotation', 45, 'FontSize', 14);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

%% VPS Contrasts
% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end
% ------------------------------------------------------------------------

k = length(DAT.contrasts);

printhdr('VPS contrasts - unscaled data');

% vpsdat = cat(2, DAT.vpsresponse{:}); DAT.vpscontrasts = vpsdat * DAT.contrasts';
% Apply contrasts a different way, allowing for differences across number of images in different sets
for c = 1:size(DAT.contrasts, 1)
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    DAT.vpscontrasts{c} = cat(2, DAT.vpsresponse{wh}) * mycontrast(wh)';
end

figtitle = 'VPS contrasts unscaled data';
create_figure('vps');

barplot_columns(DAT.vpscontrasts, figtitle, 'colors', DAT.contrastcolors, 'nofig');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

% ------------------------------------------------------------------------
printhdr('VPS contrasts - CSF-adjusted images data');

% vpsdat = cat(2, DAT.vpsresponsesc{:}); DAT.vpscontrasts = vpsdat * DAT.contrasts';
% Apply contrasts a different way, allowing for differences across number of images in different sets
for c = 1:size(DAT.contrasts, 1)
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    DAT.vpscontrastssc{c} = cat(2, DAT.vpsresponsesc{wh}) * mycontrast(wh)';
end

figtitle = 'VPS contrasts - CSF-adjusted images';
create_figure('vps');

barplot_columns(DAT.vpscontrastssc, figtitle, 'colors', DAT.contrastcolors, 'nofig');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45, 'FontSize', 16);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

%% Correlations between VPS contrasts and global gray, white, CSF

if ~isfield(DAT, 'gray_white_csf_contrasts') || isempty(DAT.gray_white_csf_contrasts)
    % skip
    return
end

printhdr('Correlations between VPS and global gray, white, CSF');
disp('Systematic non-zero values indicate global signal contamination');

k = size(DAT.contrasts, 1);

clear r

for i = 1:k

    r(i, :) = corr(DAT.vpscontrasts{i}, DAT.gray_white_csf_contrasts{i});
    
end

print_matrix(r, {'Gray' 'White' 'CSF'}, DAT.contrastnames);

%% Save results
% ------------------------------------------------------------------------
savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, '-append', 'DAT');