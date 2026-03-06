imFile = 't1_se_sag.nii.gz';
metaData = niftiinfo(imFile);
vol = niftiread(metaData);

tform = metaData.Transform.T';  % this is a little diff from below, as cols 1-2 are switched, and 1,4 is different

% https://www.mathworks.com/help/medical-imaging/ug/end-to-end-workflow-for-ai-based-segmentation-and-analysis-of-brain-mri-scan.html?utm_source=chatgpt.com
medVolMRI = medicalVolume(imFile);
volshow(medVolMRI,RenderingStyle="SlicePlanes")
volshow(medVolMRI,RenderingStyle="Isosurface")
slice(double(medVolMRI.Voxels), 5, 5, 5)

montage(medVolMRI)

orthosliceViewer(double(medVolMRI.Voxels))

medVolResampled = resample(medVol,R,Name=Value)
R = medicalref3d(volumeSize,tform)


Matlab Examples: 
Create medicalref3d Object Using Volume Size and Geometric Transformation
Resample Medical Image Volume to Target Voxel Size

% Get voxel-to-world transformation matrix, an affine matrix
origRef = medVolMRI.VolumeGeometry;
origMapping = intrinsicToWorldMapping(origRef); % affinetform3d class 
tform = origRef.A;

%%
% TW: Key functions:
% B = IMRESIZE3(V, [NUMROWS NUMCOLS NUMPLANES]) resizes the 3-D image (image proc toolbox), with cubic or lanczos3 interpolation and anti-aliasing
% alignData = alignBrainCANDIVolume(data,aff,affRef).  uses permute and flip to reorient data if needed (could be dangerous to use blindly maybe).
% Uses rescale.m to scale the top/bottom 99.5% of input data to 1 and 0 range
% try plot(net);

resample = false;
cropSize = 192;
[volProc,cropIdx,imSize] = preProcessBrainCANDIData(vol,metaData,cropSize,resample);

inputSize = size(volProc);
% Convert the preprocessed MRI volume into a formatted deep learning array with the SSSCB (spatial, spatial, spatial, channel, batch) format by using dlarray.
volDL = dlarray(volProc,"SSSCB");

volProc = double(vol);
volDL = dlarray(volProc,"SSSCB");

%%

cd('/Users/f003vz1/Documents/MATLAB/Examples/R2024b/images_deeplearning/BrainMRISegmentationUsingTrained3DUNetExample')
g = genpath(pwd); addpath(g);

%%

predictIm = predict(net,volDL);


