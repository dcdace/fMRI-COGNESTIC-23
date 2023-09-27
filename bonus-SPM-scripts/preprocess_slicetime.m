function preprocess_slicetime(param, sub, prfx)

disp(['Slice-time acquisition correcting sub-' sub ' functional images.'])

subjDir = fullfile(param.outpth, ['sub-' sub]);
outdir = fullfile(subjDir, 'func');
cd(outdir);

% get list of all BOLD files that need to be slice-time corrected
boldFiles = cellstr(spm_select('FPList', outdir, ['^' prfx '.*bold\.nii$']));

% get the number of runs
nrun = numel(boldFiles);

% Loop through each run and add functional scans to the datafiles
for run = 1:nrun
    tmp = cellstr(spm_select('expand', boldFiles{run}));
    datafiles{run} = tmp(param.dummy+1:end);
end

% Do the slice-time correction
matlabbatch{1}.spm.temporal.st.scans    = datafiles;
matlabbatch{1}.spm.temporal.st.nslices  = param.nslices;
matlabbatch{1}.spm.temporal.st.tr       = param.TR;
matlabbatch{1}.spm.temporal.st.ta       = param.TA;
matlabbatch{1}.spm.temporal.st.so       = param.sorder;
matlabbatch{1}.spm.temporal.st.refslice = param.rslice;
matlabbatch{1}.spm.temporal.st.prefix   = 'a';
% Run batch
spm_jobman('run', matlabbatch);
% Save batch
timenow = fix(clock);
save(fullfile(outdir, ['PreProcess_SlicetimeCorrection_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');
clear matlabbatch