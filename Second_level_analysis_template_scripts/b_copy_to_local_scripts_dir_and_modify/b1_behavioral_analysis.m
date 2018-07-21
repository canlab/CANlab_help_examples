% Behavioral analyses

% unpack variables
names = DAT.BETWEENPERSON.between_subject_design.Properties.VariableNames;
for i = 1:length(names)
    eval([names{i} ' = DAT.BETWEENPERSON.between_subject_design.' names{i} ';'])
end

disp(names)

% Groups
wh1 = DAT.BETWEENPERSON.group > 0; % Patients
wh2 = DAT.BETWEENPERSON.group < 0; % Controls

%% FIGURE 1: PAIN X STIM INTENSITY

figtitle = 'Pain x Stim intensity';

create_figure(figtitle, 1, 2);

subplot(1, 2, 1)

var1 = pressure;
var2 = pressurepain;
xname = 'Pressure';
yname = 'Pressure Pain';

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
var2 = coldpain;
xname = 'Cold Temp (higher is colder)';
yname = 'Cold Pain';

plot_correlation_samefig(var1, var2);

clear pthan
pthan(1) = plot(var1(wh1), var2(wh1), 'o', 'MarkerSize', 8, 'Color', DAT.BETWEENPERSON.groupcolors{1} ./ 2, 'MarkerFaceColor', DAT.BETWEENPERSON.groupcolors{1});
pthan(2) = plot(var1(wh2), var2(wh2), 'o', 'MarkerSize', 8, 'Color', DAT.BETWEENPERSON.groupcolors{2} ./ 2, 'MarkerFaceColor', DAT.BETWEENPERSON.groupcolors{2});
legend(pthan, DAT.BETWEENPERSON.groupnames);
xlabel(xname)
ylabel(yname)
axis auto

plugin_save_figure;
close               % to save memory


%% FIGURE 2: BARPLOTS OF PATIENT VS. CONTROL IN STIM INTENSITY

figtitle = 'GROUP differences';

create_figure(figtitle, 1, 2);

subplot(1, 2, 1)

var1 = pressure;
paneltitle = 'Pressure';

clear bardat
bardat{1} = var1(wh1);
bardat{2} = var1(wh2);

barplot_columns(bardat, 'title', paneltitle, 'nofig', 'names', DAT.BETWEENPERSON.groupnames, 'colors', DAT.BETWEENPERSON.groupcolors);


subplot(1, 2, 2)

var1 = coldtemp;
paneltitle = 'Cold Temp (lower is colder)';

clear bardat
bardat{1} = var1(wh1);
bardat{2} = var1(wh2);

barplot_columns(bardat, 'title', paneltitle, 'nofig', 'names', DAT.BETWEENPERSON.groupnames, 'colors', DAT.BETWEENPERSON.groupcolors);

plugin_save_figure;
close               % to save memory

