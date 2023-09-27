function preprocess_normalisation(param, sub, prfx)

 disp(['Normalising sub-' sub ' functional images to MNI space.'])

subjDir = fullfile(param.outpth, ['sub-' sub]);
outdir = fullfile(subjDir, 'func');
cd(outdir);

% get list of all BOLD files that need to be normalised
boldFiles = cellstr(spm_select('FPList', outdir, ['^' prfx '.*bold\.nii$']));

T1_yfile = spm_select('FPList', fullfile(subjDir, 'anat'), '^y.*\.nii$');

matlabbatch{1}.spm.spatial.normalise.write.subj.def         = {T1_yfile};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample    = boldFiles;
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb      = [-78 -112 -70
                                                                78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox     = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp  = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix  = 'w';

% Run batch
spm_jobman('run', matlabbatch);
% Save batch
timenow = fix(clock);
save(fullfile(outdir, ['PreProcess_Normalisation_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');
clear matlabbatch

% get list of all BOLD files that need to be normalised
norm_boldFiles = cellstr(spm_select('FPList', outdir, ['^w' prfx '.*bold\.nii$']));

matlabbatch{1}.spm.spatial.smooth.data      = norm_boldFiles;
matlabbatch{1}.spm.spatial.smooth.fwhm      = param.smooth_fwhm;
matlabbatch{1}.spm.spatial.smooth.dtype     = 0;
matlabbatch{1}.spm.spatial.smooth.im        = 0;
matlabbatch{1}.spm.spatial.smooth.prefix    = 's';

% Run batch
spm_jobman('run', matlabbatch);
% Save batch
timenow = fix(clock);
save(fullfile(outdir, ['PreProcess_Smoothing_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');
clear matlabbatch



