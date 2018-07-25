
for i=1:length(files_on_disk)
    
    study_string=strfind(files_on_disk{i},'Study');
    subject_string=strfind(files_on_disk{i},'Subject');
    nii_string=strfind(files_on_disk{i},'.nii');
    
    Study(i)=str2double(files_on_disk{i}(study_string+5:subject_string-1)); 
    Subject(i)=str2double(files_on_disk{i}(subject_string+7:nii_string-1)); 
    
    
end

[~,reorder]=sort(Study);
Study=Study(reorder);
Subject=Subject(reorder);
FullDataSet.dat=FullDataSet.dat(:,reorder);
FullDataSet.fullpath(reorder,:)=FullDataSet.fullpath(reorder,:);
FullDataSet.image_names(reorder,:)=FullDataSet.image_names(reorder,:);