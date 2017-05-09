mysignature =   {'NPS', 'NPSpos', 'NPSneg', 'SIIPS'};   % 'NPS' 'NPSpos' 'NPSneg' 'SIIPS' etc.  See load_image_set('npsplus')
scalenames =    {'raw'};                                % or scaled
simnames =      {'cosine_sim'};                         % or 'dotproduct'


% Format: The prep_4_apply_signatures_and_save script extracts signature responses and saves them.
% These fields contain data tables:
% DAT.SIG_conditions.(data scaling).(similarity metric).(signaturename)
% DAT.SIG_contrasts.(data scaling).(similarity metric).(signaturename)
%
% signaturenames is any of those from load_image_set('npsplus')
% (data scaling) is 'raw' or 'scaled', using DATA_OBJ or DATA_OBJsc
% (similarity metric) is 'dotproduct' or 'cosine_sim'
%
% Each of by_condition and contrasts contains a data table whose columns
% are conditions or contrasts, with variable names based on DAT.conditions
% or DAT.contrastnames, but with spaces replaced with underscores.
%
% Convert these to numerical arrays using table2array:
% table2array(DAT.SIG_contrasts.scaled.dotproduct.NPSneg)

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    %docontrasts = false;
    npanels = 1;
else
    %docontrasts = true;
    npanels = 2;
end


%% Signature Response
% ------------------------------------------------------------------------

% Loop through signatures, create one plot per contrast
% -------------------------------------------------------------------------
for s = 1:length(mysignature)
    
    conditiondata = table2array(DAT.SIG_conditions.(scalenames{1}).(simnames{1}).(mysignature{s}));
    contrastdata = table2array(DAT.SIG_contrasts.(scalenames{1}).(simnames{1}).(mysignature{s}));

    printhdr(sprintf('%s responses: Scale = %s Metric = %s', mysignature{s}, scalenames{1}, simnames{1}));
    
    % ------------------------------------------------------------------------
    
    figtitle = sprintf('%s response %s %s', mysignature{s}, scalenames{1}, simnames{1});
    create_figure(figtitle, 1, npanels);
    
    % First plot
    printstr(['Conditions: ' figtitle])
    printstr(dashes)
    
    barplot_columns(conditiondata, figtitle, 'colors', DAT.colors, 'dolines', 'nofig', 'names', DAT.conditions);
    title('Conditions');
    ylabel(figtitle);
    
    if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
        % skip
        return
    end
    % ------------------------------------------------------------------------
    
    % Second plot
    
    subplot(1, npanels, 2)
    
    printstr(['Contrasts: ' figtitle])
    printstr(dashes)
    
    barplot_columns(contrastdata, figtitle, 'colors', DAT.contrastcolors, 'nofig', 'names', DAT.contrastnames);
    title('Contrasts');
    ylabel(figtitle);
    
    plugin_save_figure;
    close
    
end % signature
