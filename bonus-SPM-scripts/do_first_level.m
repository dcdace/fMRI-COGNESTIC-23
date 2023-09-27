function do_first_level(param, sub)

outpth = fullfile(param.outpth, sub);
if ~exist(outpth,'dir')
    mkdir(outpth);
end
disp(['Creating ' sub ' 1st level results in ' outpth]);

%% DESIGN
% directory where functional scans are located
funcDir = fullfile(param.datadir, sub, 'func');
% get list of all BOLD files
boldFiles = cellstr(spm_select('FPList', funcDir, '^swar.*bold\.nii$'));
% get list of all realignment files
movementFiles = cellstr(spm_select('FPList', funcDir, '^rp_.*\.txt$'));
% get list of all event files
onsetFiles = cellstr(spm_select('FPList', funcDir, '.*spmdef\.mat$'));

% for each run
nruns = size(boldFiles, 1);
for run = 1 : nruns
    movementFile = movementFiles{run};
    
    tmp = cellstr(spm_select('expand', boldFiles{run}));
    scans = tmp(param.nDummy+1:end);
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans        = scans;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond         = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi        = onsetFiles(run);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress      = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg    = {movementFile};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf          = param.hpf;
end

matlabbatch{1}.spm.stats.fmri_spec.timing.units     = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT        = param.TR ;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t    = param.nslices;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0   = param.ref_slice;
matlabbatch{1}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = param.hrf_derivs;
matlabbatch{1}.spm.stats.fmri_spec.volt             = 1;
matlabbatch{1}.spm.stats.fmri_spec.global           = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh          = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask             = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi              = 'AR(1)';
matlabbatch{1}.spm.stats.fmri_spec.dir              = {outpth};

% ESTIMATE
matlabbatch{2}.spm.stats.fmri_est.spmmat            = {fullfile(outpth, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals   = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical  = 1;

%% RUN AND SAVE
% Run batch
spm_jobman('run', matlabbatch);
% Save batch
timenow = fix(clock);
save(fullfile(outpth, ['stats_FirstLevel_DesignAndEstimate_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');
clear matlabbatch

%% CONTRASTS
matlabbatch{1}.spm.stats.con.spmmat = {fullfile(outpth, 'SPM.mat')};

for con = 1 : length(param.contrasts)
    matlabbatch{1}.spm.stats.con.consess{con}.tcon.name = param.contrast_names{con};
    matlabbatch{1}.spm.stats.con.consess{con}.tcon.weights = param.contrasts{con};
    matlabbatch{1}.spm.stats.con.consess{con}.tcon.sessrep = 'repl';
end

matlabbatch{1}.spm.stats.con.consess{con+1}.fcon.name = 'effects of interest';
matlabbatch{1}.spm.stats.con.consess{con+1}.fcon.weights = param.eof_contrast;
matlabbatch{1}.spm.stats.con.consess{con+1}.fcon.sessrep = 'repl';

matlabbatch{1}.spm.stats.con.delete = 1;

%% RUN AND SAVE
% Run batch
spm_jobman('run', matlabbatch);
% Save batch
timenow = fix(clock);
save(fullfile(outpth, ['stats_FirstLevel_Contrasts_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');
clear matlabbatch