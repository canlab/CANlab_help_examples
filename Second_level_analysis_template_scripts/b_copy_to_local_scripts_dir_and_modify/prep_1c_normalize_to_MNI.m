
% this script takes anatomical files specified in DAT structure and warps
% them to MNI space (using IXI template from CAT toolbox and SPM's
% segmentation routine). This script assumes functional and anatomical data
% are coregistered. 

anat_path=fullfile(datadir, DAT.structural_folder, DAT.structural_wildcard);
anat_files=dir(anat_path{1});
spm_jobman('initcfg');
for s=1:length(anat_files)
    clear matlabbatch
    anat_file=fullfile(datadir,DAT.structural_folder,anat_files(s).name);
    matlabbatch{1}.spm.spatial.preproc.channel.vols = anat_file;
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[which('Template_6_IXI555_MNI152.nii') ',1']};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[which('Template_6_IXI555_MNI152.nii') ',2']};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
    
    ci=1;
    for i = 1:length(DAT.conditions)
        func_str = fullfile(datadir, DAT.subfolders{i}, DAT.functional_wildcard{i});
        func_dir = fullfile(datadir, DAT.subfolders{i});
        func_files=dir(func_str);

        func_comparison_cell={func_files(:).name};
        anat_comparison_string=anat_file{1}(end-7:end-4);
        
        results = false(1,length(func_comparison_cell));
        for j = 1:length(func_comparison_cell)
            if ~isempty(strfind(func_comparison_cell{j},anat_comparison_string))
                results(j) = true;
            end
        end
        
        if any(results)
         ci=ci+1;
        matlabbatch{ci}.spm.util.defs.comp{1}.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
        matlabbatch{ci}.spm.util.defs.out{1}.pull.fnames = fullfile(func_dir,func_comparison_cell(results));
        matlabbatch{ci}.spm.util.defs.out{1}.pull.savedir.saveusr = {fullfile(func_dir)};
        matlabbatch{ci}.spm.util.defs.out{1}.pull.interp = 4;
        matlabbatch{ci}.spm.util.defs.out{1}.pull.mask = 1;
        matlabbatch{ci}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
        matlabbatch{ci}.spm.util.defs.out{1}.pull.prefix = 'w';
        matlabbatch{ci}.spm.util.defs.comp{2}.id.space(1) = fullfile(func_dir,func_comparison_cell(results));

        end
    end
   spm_jobman('run',matlabbatch) 
end