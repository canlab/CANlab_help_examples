

%% Wedge plot, table, and lateralization for 17 Yeo et al. networks
% --------------------------------------------------------------------

try
    test = load_atlas('yeo17networks');
    
catch
    
   disp('Unable to run load_atlas(''yeo17networks'')');
   disp('To run, you need Neuroimaging_Pattern_Masks repository on your path')
   disp('with subfolders. Skipping this analysis.');
   return
   
end


kc = size(DAT.contrasts, 1);

for c = 1:kc

    
    printstr(DAT.contrastnames{c});
    printstr(dashes)
       
    figtitle = sprintf('Wedge_plot_17networks %s', DAT.contrastnames{c});
    
    if c == 1
    [roi_table, subj_dat] = ttest_table_and_lateralization_test(DATA_OBJ_CON{c});
    
    else
        % no montage
        [roi_table, subj_dat] = ttest_table_and_lateralization_test(DATA_OBJ_CON{c}, 'nomontage');
        
    end
    
    drawnow, snapnow
    
    % Save figure
    ff = findobj('Tag', 'wedge overall importance');
    figure(ff)
    set(ff, 'Tag', figtitle);
    
    plugin_save_figure;
    
end

