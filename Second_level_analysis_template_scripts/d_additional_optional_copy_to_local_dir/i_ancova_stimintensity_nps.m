% Behavioral variables
% -------------------------------------------------------------------------
% unpack variables
names = DAT.BETWEENPERSON.between_subject_design.Properties.VariableNames;
for i = 1:length(names)
    eval([names{i} ' = DAT.BETWEENPERSON.between_subject_design.' names{i} ';'])
end

disp(names)

% Groups
group = DAT.BETWEENPERSON.group; % empty for no variable to control/remove

wh1 = DAT.BETWEENPERSON.group > 0; % Patients
wh2 = DAT.BETWEENPERSON.group < 0; % Controls

% Get brain signature data
% -------------------------------------------------------------------------

mysignature = 'NPS';  % NPS, VPS, SIIPS, etc., etc.     
myscaling = 'raw';          % 'raw' or 'scaled'
mymetric = 'dotproduct';  % 'dotproduct' or 'cosine_sim'

printhdr(sprintf('%s responses: Scale = %s Metric = %s', mysignature, myscaling, mymetric));

% siipspressure = DAT.SIG_conditions.(myscaling).(mymetric).SIIPS.PressurePain;
% siipscold = DAT.SIG_conditions.(myscaling).(mymetric).SIIPS.ColdPain;

npspressure = DAT.SIG_conditions.(myscaling).(mymetric).(mysignature).PressurePain;
npscold = DAT.SIG_conditions.(myscaling).(mymetric).(mysignature).ColdPain;

% very small diffs - related to interpolation/voxel selection most likely...
% npspressure2 = DAT.npscontrasts{1};
% npscold2 = DAT.npscontrasts{3};

% Exploratory: combined measure
% npspressure = zscore(npspressure) + zscore(siipspressure);
% npscold = zscore(npscold) + zscore(siipscold);


%% FIGURE 1: PAIN X STIM INTENSITY
% -------------------------------------------------------------------------

figtitle = 'NPS x Stim intensity';
printhdr(figtitle)

create_figure(figtitle, 1, 2);

subplot(1, 2, 1)

var1 = pressure;
var2 = npspressure;
xname = 'Pressure';
yname = 'Pressure NPS';

plot_correlation_samefig(var1, var2);

clear pthan
pthan(1) = plot(var1(wh1), var2(wh1), 'o', 'MarkerSize', 8, 'Color', DAT.BETWEENPERSON.groupcolors{1} ./ 2, 'MarkerFaceColor', DAT.BETWEENPERSON.groupcolors{1});
pthan(2) = plot(var1(wh2), var2(wh2), 'o', 'MarkerSize', 8, 'Color', DAT.BETWEENPERSON.groupcolors{2} ./ 2, 'MarkerFaceColor', DAT.BETWEENPERSON.groupcolors{2});
legend(pthan, DAT.BETWEENPERSON.groupnames);
xlabel(xname)
ylabel(yname)
axis auto

subplot(1, 2, 2)

var1 = coldtemp;
var2 = npscold;
xname = 'Cold Temp (higher is colder)';
yname = 'Cold NPS';

plot_correlation_samefig(var1, var2);

clear pthan
pthan(1) = plot(var1(wh1), var2(wh1), 'o', 'MarkerSize', 8, 'Color', DAT.BETWEENPERSON.groupcolors{1} ./ 2, 'MarkerFaceColor', DAT.BETWEENPERSON.groupcolors{1});
pthan(2) = plot(var1(wh2), var2(wh2), 'o', 'MarkerSize', 8, 'Color', DAT.BETWEENPERSON.groupcolors{2} ./ 2, 'MarkerFaceColor', DAT.BETWEENPERSON.groupcolors{2});
legend(pthan, DAT.BETWEENPERSON.groupnames);
xlabel(xname)
ylabel(yname)
axis auto

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

%% Mediation: group -> pressure -> NPS
% -------------------------------------------------------------------------

printhdr('group -> pressure -> NPS Pressure');

[paths, stats2] = mediation(group, npspressure, pressure, 'plots', 'verbose', 'names', {'PatientControl', 'NPS', 'Pressure'}, 'boot', 'bootsamples', 10000); %'robust', 

% NPS increases as a function of pressure, and NPS increases for whiplash patients in proportion to pressure received.
% There is no group difference in NPS when controlling for pressure.
% Patients are not qualitatively different.

%% Mediation: group -> pressure -> NPS controlling for pain
% -------------------------------------------------------------------------

% May not be meaningful to control for pain, but try for completeness.
[paths, stats2] = mediation(group, npspressure, pressure, 'covs', pressurepain, 'plots', 'verbose', 'names', {'PatientControl', 'NPS', 'Pressure'}, 'boot', 'bootsamples', 10000); %'robust', 

%% Mediation: group -> cold -> NPS
% -------------------------------------------------------------------------

printhdr('group -> cold temp (lower is more intense) -> NPS Cold');

[paths, stats2] = mediation(group, npscold, coldtemp, 'plots', 'verbose', 'names', {'PatientControl', 'NPS', 'Cold Intensity'}, 'boot', 'bootsamples', 10000); %'robust', 


%% FIGURE 2: BARPLOTS OF PATIENT VS. CONTROL SCALING BY STIM INTENSITY
% -------------------------------------------------------------------------

figtitle = 'GROUP differences';
printhdr(figtitle)

create_figure(figtitle, 1, 2);

subplot(1, 2, 1)

var1 = npspressure;
var2 = pressure;
paneltitle = 'NPS per unit Pressure';

clear bardat
bardat{1} = var1(wh1) ./ var2(wh1);
bardat{2} = var1(wh2) ./ var2(wh2);

barplot_columns(bardat, 'title', paneltitle, 'nofig', 'names', DAT.BETWEENPERSON.groupnames, 'colors', DAT.BETWEENPERSON.groupcolors);


subplot(1, 2, 2)

var1 = npscold;
var2 = coldtemp;
paneltitle = 'NPS per unit Cold Temp';

clear bardat
bardat{1} = var1(wh1);
bardat{2} = var1(wh2);

barplot_columns(bardat, 'title', paneltitle, 'nofig', 'names', DAT.BETWEENPERSON.groupnames, 'colors', DAT.BETWEENPERSON.groupcolors);

drawnow, snapnow
savename = fullfile(figsavedir, [figtitle '.png']);
saveas(gcf, savename);

