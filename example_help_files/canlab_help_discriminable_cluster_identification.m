%% Discriminable Cluster Identification
% Multi-way classification yields n class labels, but these may not all be
% statistically distinguishable from one another. For example, a 20-way
% emotion classification from a neural network may yield signficant 20-way
% classification performance, but not all of these categories may be
% meaningfully distinguished from one another.  
%
% Discriminable Cluster Identification uses hierarchical clustering to
% group the classes into equivalence groups, where within group the classes
% are not distinguishable, but each group is significantly distinguishable from each other group.
% 
% [K, stats] = cluster_confusion_matrix(pred_label,true_label,varargin)
% Given a set of inferred and true multi-class category labels (e.g., from classification)
% group categories into clusters such that each cluster is statistically distinguishable
% from each other cluster.

%% Generate simulated data

tl=randi(20,300,1); %create ground truth labels

% Generate predicted class labels (pl), which is a random permutation
% of the true labels.  This is effectively what is done repeatedly during
% permutation testing.
pl=tl; %create perfect match predictions
randvec=randperm(300); %create a random ordering of predictions
num_scrambled=200; %number of labels to 'corrupt'
pl(randvec(1:num_scrambled))=randi(20,1,num_scrambled); %assign random values

% Create category labels:
categories = {}; for i = 1:20, categories{i} = sprintf('Cat%d', i); end

%% Run the clustering and confusion matrix, generate a plot

[k,stats] = cluster_confusion_matrix(pl,tl,'dofig','method','complete');

%% Run the full analysis with permutation and bootstrapping for inference

% Run the full analysis with ward linkage - bootstrap CI, permutation test for inference, and plot of results:
[k,stats] = cluster_confusion_matrix(pl,tl,'labels', categories, 'dofig', 'method', 'ward', 'perm', 'bootstrap');
