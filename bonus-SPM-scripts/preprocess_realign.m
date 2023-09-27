function preprocess_realign(param, sub, prfx)

disp(['Realigning sub-' sub ' functional images (motion-correction).'])

subjDir = fullfile(param.outpth, ['sub-' sub]);
outdir = fullfile(subjDir, 'func');
cd(outdir);

% get list of all BOLD files that need to be realigned
boldFiles = cellstr(spm_select('FPList', outdir, ['^' prfx '.*bold\.nii$']));

% get the number of runs
nrun = numel(boldFiles);

% Loop through each run and add functional scans to the datafiles
for run = 1:nrun
    tmp = cellstr(spm_select('expand', boldFiles{run}));
    datafiles{run} = tmp(param.dummy+1:end);
end
% Do the realignment
matlabbatch{1}.spm.spatial.realign.estwrite.data                = datafiles;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality    = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep        = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm       = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm        = 1; % 0-register to first; 1-register to mean
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp     = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap       = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight     = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which      = [2 1]; % reslice all and the mean images
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp     = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap       = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask       = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix     = 'r';
% Run batch
spm_jobman('run', matlabbatch);
% Save batch
timenow = fix(clock);
save(fullfile(outdir, ['PreProcess_Realignment_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');
clear matlabbatch
