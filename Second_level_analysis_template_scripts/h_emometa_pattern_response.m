emomask = which('Buhle_Silvers_2014_Emotion_Regulation_Meta_thresh.img'); % not 1/0

% emomask = fmri_data(emomask, 'noverbose');
% emomask = threshold(emomask, [2.68 Inf], 'raw-between', 'k', 75); % p < .005 equivalent, extent thresholded  0.05 FWE-corr

clear mycon

for i = 1:kc
        
        mycon{i} = apply_mask(DATA_OBJ_CON{i}, emomask, 'pattern_expression', 'ignore_missing');  % weighted average, z-scores are weights
        
end

%%

figtitle = 'Emotion regulation pattern response from 2014 emo meta';
create_figure('emometa', 1, 2);

barplot_columns(mycon, figtitle, 'colors', DAT.contrastcolors, 'nofig');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);

subplot(1, 2, 2);
barplot_columns(mycon, figtitle, 'colors', DAT.contrastcolors, 'nofig', 'noviolin', 'noind');
set(gca, 'XTickLabel', DAT.contrastnames, 'XTickLabelRotation', 45);


drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);
%%
printhdr('Emotion meta-analysis pattern response');

print_matrix(cat(2, mycon{:}), DAT.contrastnames, {});

