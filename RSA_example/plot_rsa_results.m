function plot_rsa_results(stats)

figure;imagesc(stats.RDM); colorbar; 
xlabel 'Subject Number'; title 'Brain RDM'

%show bootstrap distribution for generalization indices
figure;
subplot(3,1,1)
distributionPlot(stats.bs_gen_index(:,2:19));
title 'Study'
ylabel 'Generalization Index'

subplot(3,1,2)
distributionPlot(stats.bs_gen_index(:,20:28));
title 'Subdomain'
ylabel 'Generalization Index'

subplot(3,1,3)
distributionPlot(stats.bs_gen_index(:,29:31));
title 'Domain'
ylabel 'Generalization Index'
set(gca,'XTickLabel', {'Pain','Cognitive Control','Negative Emotion'});
set(gca,'XTickLabelRotation',45)
set(gcf,'Units','Inches')
set(gcf,'Position',[0 0 5 7])