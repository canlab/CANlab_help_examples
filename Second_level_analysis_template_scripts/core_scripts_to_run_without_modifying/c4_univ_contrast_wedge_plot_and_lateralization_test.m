% This script extracts averages for 16 networks based on rsfMRI connectivity, 
% based on a paper (Schaefer et al. 2018) and Github repo from Thomas Yeo?s lab.  
% It tests the average activity and, because each network can be divided into a 
% left and right hemisphere part, it tests for significant lateralization as well.  
%
% This script in the Canlab_help_examples Github repo wraps an
% image_vector method that does the core test, and is compatible with
% Matlab's publish command to produce HTML reports. 
%
% The core method to run on any fmri_data object is : 
% image_vector/ttest_table_and_lateralization_test
%
% You?ll need the Neuroimaging_Pattern_Masks repository from the Canlab Github repository set as well.
% https://github.com/canlab/Neuroimaging_Pattern_Masks

%% Wedge plot, table, and lateralization for 16 Yeo et al. networks
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
     
    figtitle = sprintf('Wedge_plot_17networks_%s', DAT.contrastnames{c});
    figstr = format_strings_for_legend(figtitle); 
    figstr = figstr{1};
    printhdr(figstr);
    
    if c == 1
    [roi_table, subj_dat] = ttest_table_and_lateralization_test(DATA_OBJ_CON{c});
    
    else
        % no montage
        [roi_table, subj_dat] = ttest_table_and_lateralization_test(DATA_OBJ_CON{c}, 'nomontage');
        
    end
    
    % drawnow, snapnow
    
    % Save figure
    ff = findobj('Tag', 'wedge overall importance');
    figure(ff);
    set(ff, 'Tag', figtitle);
    
    plugin_save_figure;  % and drawnow, snapnow
    close
    
end

