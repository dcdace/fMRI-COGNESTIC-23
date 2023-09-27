function preprocess_coregister(param, sub, prfx)

disp(['Co-registering sub-' sub ' functional images to the T1w.'])

subjDir = fullfile(param.outpth, ['sub-' sub]);
outdir = fullfile(subjDir, 'func');
cd(outdir);


% get the anatomical scan
T1w = spm_select('FPList', fullfile(subjDir, 'anat'), '^sub-.*_T1w.nii');

% get the mean functional image
meanFunc = spm_select('FPList', outdir, '^mean.*\.nii$');

% get the list of all BOLD files that need to be co-registered
boldFiles = cellstr(spm_select('FPList', outdir, ['^' prfx '.*bold\.nii$']));

% Coregister 
matlabbatch{1}.spm.spatial.coreg.estimate.ref               = {T1w};
matlabbatch{1}.spm.spatial.coreg.estimate.source            = {meanFunc};
matlabbatch{1}.spm.spatial.coreg.estimate.other             = boldFiles;
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

% Run batch
spm_jobman('run', matlabbatch);

% Save batch
timenow = fix(clock);
save(fullfile(outdir, ['PreProcess_Coregister_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');

clear matlabbatch