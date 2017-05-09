signatures_to_plot = {'NPS' 'NPSpos' 'NPSneg'};  % NPS, VPS, SIIPS, etc., etc.     
myscaling = 'raw';          % 'raw' or 'scaled'
mymetric = 'dotproduct';    % 'dotproduct' or 'cosine_sim'

% Controlling for group admin order covariate (mean-centered by default)

group = [];
if isfield(DAT, 'BETWEENPERSON') && isfield(DAT.BETWEENPERSON, 'group')
    group = DAT.BETWEENPERSON.group; % empty for no variable to control/remove
    
    printstr('Controlling for data in DAT.BETWEENPERSON.group');
end

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
%
% DAT.SIG_conditions.raw.dotproduct = apply_all_signatures(DATA_OBJ, 'conditionnames', DAT.conditions);
% DAT.SIG_contrasts.raw.dotproduct = apply_all_signatures(DATA_OBJ_CON, 'conditionnames', DAT.conditions);

k = length(DAT.conditions);
nplots = length(signatures_to_plot);
mysignames = strcat(signatures_to_plot{:});

%% Signature Response - conditions
% ------------------------------------------------------------------------

figtitle = sprintf('%s conditions %s %s', mysignames, myscaling, mymetric);
printhdr(figtitle);

create_figure(figtitle, 1, nplots);


for n = 1:nplots
    
    subplot(1, nplots, n);
    
    mysignature = signatures_to_plot{n};
    mydata = table2array(DAT.SIG_conditions.(myscaling).(mymetric).(mysignature));
    
    barplot_columns(mydata, 'title', mysignature, 'colors', DAT.colors, 'dolines', 'nofig', 'names', DAT.conditions, 'covs', group, 'wh_reg', 0);
    
end


plugin_save_figure;
close


%% Signature Response - contrasts
% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end
% ------------------------------------------------------------------------


figtitle = sprintf('%s contrasts %s %s', mysignames, myscaling, mymetric);
printhdr(figtitle);

create_figure(figtitle, 1, nplots);

for n = 1:nplots
    
    subplot(1, nplots, n);
    
    mysignature = signatures_to_plot{n};
    mydata = table2array(DAT.SIG_contrasts.(myscaling).(mymetric).(mysignature));

    barplot_columns(mydata, 'title', mysignature, 'colors', DAT.contrastcolors, 'nofig', 'names', DAT.contrastnames, 'covs', group, 'wh_reg', 0);

end


plugin_save_figure;
close


