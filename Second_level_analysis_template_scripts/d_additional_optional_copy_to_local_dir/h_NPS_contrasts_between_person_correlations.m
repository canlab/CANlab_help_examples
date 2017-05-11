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

kc = length(DAT.contrastnames);
nfigures = length(signatures_to_plot);
mysignames = strcat(signatures_to_plot{:});

covtables = DAT.BETWEENPERSON.contrasts;

%% Signature Response - contrasts
% ------------------------------------------------------------------------

if ~isfield(DAT, 'contrasts') || isempty(DAT.contrasts)
    % skip
    return
end
% ------------------------------------------------------------------------

for n = 1:nfigures
    
    mysignature = signatures_to_plot{n};
    
    mydata = table2array(DAT.SIG_contrasts.(myscaling).(mymetric).(mysignature));
    
figtitle = sprintf('%s contrasts %s %s', mysignature, myscaling, mymetric);
create_figure(figtitle);
printhdr(figtitle);

create_figure(figtitle, 1, kc); % one panel for each contrast

    for i = 1:kc
        
    subplot(1, kc, i);
    
    % Get brain data of interest for this contrast
    braindata = mydata(:, i); 
    
    % Get covariates - single cov of interest is first is array
    mycovs = table2array(covtables{i});
    whid = strcmp(covtables{i}.Properties.VariableNames, 'id');
    mycovs(:, whid) = [];
    mycovs = [mycovs group];
    wh_of_interest = 1;
    xname = covtables{i}.Properties.VariableNames(~whid);
    xname = format_strings_for_legend(xname{1}); % ONLY 1 ALLOWED FOR NOW!
    
    [covresid, brainresid,r,p,se,meany,stats] = partialcor(mycovs, braindata, wh_of_interest, true, false);
    
    % Partial correlation scatterplot
    plot_correlation_samefig(covresid, brainresid);
    xlabel(xname);
    ylabel(mysignature);
    
    end % contrast
    
end % figures/signatures

drawnow, snapnow

savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);


