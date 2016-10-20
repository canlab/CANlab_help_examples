k = length(DAT.conditions);


%% NPS Response
% ------------------------------------------------------------------------

printhdr('NPS responses by condition');
% ------------------------------------------------------------------------

% Raw/Unscaled data NPS responses

clear npsresponse

figtitle = 'NPS response raw data';
create_figure('nps');

for i = 1:k
    
    DAT.npsresponse(i) = apply_nps(DATA_OBJ{i}, 'noverbose', 'notables');
    
end

disp(DAT.conditions)
barplot_columns(DAT.npsresponse, figtitle, 'colors', DAT.colors, 'dolines', 'nofig');
set(gca, 'XTickLabel', DAT.conditions, 'XTickLabelRotation', 45, 'FontSize', 14);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);


% CSF-adjusted data NPS responses
% ------------------------------------------------------------------------

disp(' ')
printhdr('NPS responses by condition - CSF-adjusted images');

clear npsresponse

figtitle = 'NPS response CSF-adjusted data';
create_figure('nps');

for i = 1:k
    
    DAT.npsresponsesc(i) = apply_nps(DATA_OBJsc{i}, 'noverbose', 'notables');
    
end

disp(DAT.conditions)
barplot_columns(DAT.npsresponsesc, figtitle, 'colors', DAT.colors, 'dolines', 'nofig');
set(gca, 'XTickLabel', DAT.conditions, 'XTickLabelRotation', 45, 'FontSize', 14);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

%% NPS Contrasts
% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end
% ------------------------------------------------------------------------

printhdr('NPS contrasts - unscaled data');

% cell sizes
% sz = cellfun(@size, DAT.npsresponse, repmat({1}, 1, size(DAT.npsresponse, 2)), 'UniformOutput', false); 
% sz = cat(1, sz{:});
k = length(DAT.conditions);

DAT.npscontrasts = {};

% npsdat = cat(2, DAT.npsresponse{:}); DAT.npscontrasts = npsdat * DAT.contrasts';
% Apply contrasts a different way, allowing for differences across number of images in different sets
for c = 1:size(DAT.contrasts, 1)
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    DAT.npscontrasts{c} = cat(2, DAT.npsresponse{wh}) * mycontrast(wh)';
end

figtitle = 'NPS contrasts unscaled data';
create_figure('nps');

barplot_columns(DAT.npscontrasts, figtitle, 'colors', DAT.contrastcolors, 'nofig');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

% ------------------------------------------------------------------------
printhdr('NPS contrasts - CSF-adjusted images data');

% npsdat = cat(2, DAT.npsresponse{:}); DAT.npscontrasts = npsdat * DAT.contrasts';
% Apply contrasts a different way, allowing for differences across number of images in different sets
for c = 1:size(DAT.contrasts, 1)
    mycontrast = DAT.contrasts(c, :);
    wh = find(mycontrast);
    
    DAT.npscontrasts{c} = cat(2, DAT.npsresponse{wh}) * mycontrast(wh)';
end

figtitle = 'NPS contrasts - CSF-adjusted images';
create_figure('nps');

barplot_columns(DAT.npscontrasts, figtitle, 'colors', DAT.contrastcolors, 'nofig');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45, 'FontSize', 16);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

%% Correlations between NPS contrasts and global gray, white, CSF

if ~isfield(DAT, 'gray_white_csf_contrasts') || isempty(DAT.gray_white_csf_contrasts)
    % skip
    return
end

printhdr('Correlations between NPS and global gray, white, CSF');
disp('Systematic non-zero values indicate global signal contamination');

k = size(DAT.contrasts, 1);

clear r

for i = 1:k

    r(i, :) = corr(DAT.npscontrasts{i}, DAT.gray_white_csf_contrasts{i});
    
end

print_matrix(r, {'Gray' 'White' 'CSF'}, DAT.contrastnames);

%% Save results
% ------------------------------------------------------------------------
savefilename = fullfile(resultsdir, 'image_names_and_setup.mat');
save(savefilename, '-append', 'DAT');
    

