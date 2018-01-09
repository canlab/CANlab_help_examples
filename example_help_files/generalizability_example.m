% this script runs through an analysis testing whether patterns of brain
% activity generalize across different psychological domains

%load data, this contains an fmri data object called 'obj', a 'design' matrix
%specifying group membership of each image in the data object (columns 1-18
%indicate study, columns 19:27 indicate subdomain, and columns 28:30 indicate 
%domain), and a vector called 'study' which is integer coded to indicate study 
%membership. 

%For detailed explanation of the method, see full text at https://tinyurl.com/ybkkuvz5

%% load  data
load(which('MFC_fMRIDataObject_Krageletal2018.mat')) 
%% reorder data to make plots clearer
[study,shuffle]=sort(study,'ascend');
obj.dat=obj.dat(:,shuffle);
design=design(shuffle,:);

%% create labels for plots
label=cell(30,1); %initialize label variable
 
%create labels for study
for s=1:18
label{s}=['Study ' num2str(s)];
end

%create labels for subdomain
label(19:27)={'Thermal' 'Visceral' 'Mechanical' 'WM' 'RS' 'RC' 'Visual' 'Social' 'Auditory'};

%create labels for domain
label(28:30)={'Pain' 'Cognitive Control' 'Negative Emotion'};


%plot design matrix to show groupings - each row is an image, each column
%is a grouping variable (e.g., the first image is from the first study, 
%which used thermal stimulation, and is in the domain of 'pain'
figure;subplot(1,2,1); imagesc(design); colormap(gray); %plot on left of figure in graay
set(gca,'XTick',1:30,'XTickLabel',label(1:30),'XTickLabelRotation',90)
ylabel 'Subject Number'
%% perform stats

[stats] = test_generalizability(obj,design,study); %call main function
subplot(1,2,2); %plot on right of figure
hold on; plot([0 32],[0 0],'k-')
boxplot(stats.bs_gen_index(:,2:end),label,'notch','on'); %show bootstrap distributions
set(gcf,'Units','Inches')
set(gcf,'Position',[0 0 12 5]);
set(gca,'Position',[ 0.5794    0.2363    0.3256    0.6887])
set(gca,'XTickLabelRotation',90)
ylabel 'Generalization Index'

%% show table of results
FDRsignificant=stats.sig(2:end)';
generalizationIndex=stats.gen_index(2:end);
zScore=stats.Z(2:end)';
pValue=stats.p(2:end)';
results=table(label,significant,generalizationIndex,zScore,pValue) %#ok<NOPTS>