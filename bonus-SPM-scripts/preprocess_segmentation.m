function preprocess_segmentation(param, sub)

 disp(['Segmenting sub-' sub ' T1w image.'])

subjDir = fullfile(param.outpth, ['sub-' sub]);
outdir = fullfile(subjDir, 'anat');
cd(outdir);

% get the anatomical scan
T1w = spm_select('FPList', outdir, '^sub-.*_T1w.nii');
% 
% segmentation, also generates Dartel import files
matlabbatch{1}.spm.spatial.preproc.channel.vols     = {T1w};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg  = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write    = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm    = {fullfile(spm('Dir'),'tpm','TPM.nii,1')};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus  = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm    = {fullfile(spm('Dir'),'tpm','TPM.nii,2')};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus  = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm    = {fullfile(spm('Dir'),'tpm','TPM.nii,3')};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus  = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm    = {fullfile(spm('Dir'),'tpm','TPM.nii,4')};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus  = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm    = {fullfile(spm('Dir'),'tpm','TPM.nii,5')};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus  = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm    = {fullfile(spm('Dir'),'tpm','TPM.nii,6')};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus  = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf         = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup     = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg         = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg      = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm        = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp        = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write       = [0 1];
matlabbatch{1}.spm.spatial.preproc.warp.write       = [1 1];
% Run batch
spm_jobman('run', matlabbatch);
% Save batch
timenow = fix(clock);
save(fullfile(outdir, ['PreProcess_Segmentation_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');
clear matlabbatch