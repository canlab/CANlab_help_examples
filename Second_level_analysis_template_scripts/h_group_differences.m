% Define test conditions of interest
% -------------------------------------------------------------------------

mysignature =   {'NPS', 'NPSpos', 'NPSneg', 'SIIPS'};   % 'NPS' 'NPSpos' 'NPSneg' 'SIIPS' etc.  See load_image_set('npsplus')
scalenames =    {'raw'};                                % or scaled
simnames =      {'cosine_sim'};                         % or 'dotproduct'

% Define groups
% -------------------------------------------------------------------------
group = DAT.BEHAVIOR.between_subject_design.group;
groupnames = {'Control', 'Autism'};

% 1 is autism, 2 is control
% -1 is autism, 1 is control


% Loop through signatures, create one plot per contrast
% -------------------------------------------------------------------------
for s = 1:length(mysignature)
    
    % Get data
    % -------------------------------------------------------------------------
    conditiondata = table2array(DAT.SIG_conditions.(scalenames{1}).(simnames{1}).(mysignature{s}));
    contrastdata = table2array(DAT.SIG_contrasts.(scalenames{1}).(simnames{1}).(mysignature{s}));
    
    kc = size(contrastdata, 2);
    
    % Plot
    % -------------------------------------------------------------------------
    printhdr(sprintf('%s responses: Scale = %s Metric = %s', mysignature{s}, scalenames{1}, simnames{1}));
    
    figtitle = sprintf('%s group diffs %s %s', mysignature{s}, scalenames{1}, simnames{1});
    create_figure(figtitle, 1, kc);
    
    for i = 1:kc
        
        %y = {DAT.(myfield){i}(group > 0) DAT.(myfield){i}(group < 0)};
        y = {contrastdata(group > 0, i) contrastdata(group < 0, i)};
        
        subplot(1, 3, i)
        
        printstr(' ');
        printstr(sprintf('Group differences: %s, %s', mysignature{s}, DAT.contrastnames{i}));
        printstr(dashes)
        
        barplot_columns(y, 'nofig', 'colors', {[.3 .3 .5] [.5 .3 .5]}, 'names', groupnames);
        
        title(DAT.conditions{i})
        xlabel('Group');
        ylabel(sprintf('%s Response', mysignature{s}));
        
        printstr('Between-groups test:');
        
        [H,p,ci,stats] = ttest2_printout(y{1}, y{2});
        
        printstr(dashes)
        
    end % panels
    
    drawnow, snapnow
    
end % signature

%% Subregions - Pos

% which variables to use
mysubrfield = 'npspos_by_region_contrasts'; % 'npspos_by_region_cosinesim';     %'npspos_by_regionsc';
mysubrfieldneg = 'npsneg_by_region_contrasts'; % 'npsneg_by_region_cosinesim';  % 'npsneg_by_regionsc';

clear means p T

for i = 1:kc  % for each contrast
    
    mydat = DAT.NPSsubregions.(mysubrfield){i};
    k = size(mydat, 2);
    
    create_figure(sprintf('NPS subregions by group %s', DAT.contrastnames{i}), 1, k);
    pos = get(gcf, 'Position');
    pos(4) = pos(4) .* 2.5;
    set(gcf, 'Position', pos);
    
    clear means p T
    
    for j = 1:k  % for each subregion
        
        subplot(1, k, j);
        
        y = {mydat(group == 1, j) mydat(group == -1, j)};
        
        printhdr(posnames{j});
        
        barplot_columns(y, 'nofig', 'colors', {[.3 .3 .5] [.5 .3 .5]}, 'noviolin', 'noind', 'names', groupnames );
        
        title(posnames{j})
        xlabel('Group');
        if j == 1, ylabel('NPS Response'); end
        
        printstr('Between-groups test:');
        [H,p(j, 1),ci,stats] = ttest2_printout(y{1}, y{2});
        
        means(j, :) = stats.means;
        T(j, 1) = stats.tstat;
        
    end
    
    drawnow, snapnow
    
    % Print between-subject Table
    printhdr('Between-group tests');
    Region = posnames';
    regionmeans = table(Region, means, T, p);
    
    disp(regionmeans);
    
end % panels

%% Subregions - Neg

for i = 1:3
    
    mydat = DAT.NPSsubregions.(mysubrfieldneg){i};
    k = size(mydat, 2);
    
    create_figure(sprintf('NPS neg subregions by group %s', DAT.contrastnames{i}), 1, k);
    pos = get(gcf, 'Position');
    pos(4) = pos(4) .* 2.5;
    set(gcf, 'Position', pos);
    
    clear means p T
    
    for j = 1:k
        
        subplot(1, k, j);
        
        y = {mydat(group == 1, j) mydat(group == -1, j)};
        
        printhdr(negnames{j});
        
        barplot_columns(y, 'nofig', 'colors', {[.3 .3 .5] [.5 .3 .5]}, 'noviolin', 'noind', 'names', groupnames );
        
        title(negnames{j})
        xlabel('Group');
        if j == 1, ylabel('NPS Response'); end
        
        printstr('Between-groups test:');
        [H,p(j, 1),ci,stats] = ttest2_printout(y{1}, y{2});
        
        means(j, :) = stats.means;
        T(j, 1) = stats.tstat;
        
    end
    
    drawnow, snapnow
    
    % Print between-subject Table
    printhdr('Between-group tests');
    Region = negnames';
    regionmeans = table(Region, means, T, p);
    
    disp(regionmeans);
    
end


