%% get data for Kragel et al. 2018 from neurovault
[files_on_disk, url_on_neurovault, mycollection, myimages] = retrieve_neurovault_collection(3324);
FullDataSet=fmri_data(files_on_disk);
%% Extract information about study (1-18) and subject number
reorder_studies_and_subjects;

%% Get masks from brainnetome atlas
bn_atlas=load_atlas('brainnetome');
dACC=select_atlas_subset(bn_atlas,{'CG_L_7_5_24cd_' 'CG_R_7_5_24cd_'});
vmPFC=select_atlas_subset(bn_atlas,{'OrG_L_6_1_14m_' 'OrG_R_6_1_14m_'});


dACC_masked_dat=apply_mask(FullDataSet,dACC);
vmPFC_masked_dat=apply_mask(FullDataSet,vmPFC);

%% Create design matrix - this will partition differences in the similarity of brain activity based on study, subdomain, and domain

% Convert nominal vectors to binary matrices
studyInds=condf2indic(Study);
subdomainInds=condf2indic(ceil(Study/2));
domainInds=condf2indic(ceil(Study/6));

%collapse to single variable
X=[studyInds subdomainInds domainInds];


%% run RSA on data masked in dACC and vmPFC
dACC_stats=rsa_regression(dACC_masked_dat,X,Study);
vmPFC_stats=rsa_regression(vmPFC_masked_dat,X,Study);

%% plot results in dACC
plot_rsa_results(dACC_stats)
orthviews(dACC)
%% plot results in vmpfc
plot_rsa_results(vmPFC_stats)
orthviews(vmPFC)