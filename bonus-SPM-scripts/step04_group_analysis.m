% ======================================================================
% dace.apsvalka@mrc-cbu.cam.ac.uk (2023)
% Based on https://www.frontiersin.org/articles/10.3389/fnins.2019.00300/full
%
% Performing group-level analysis 
%
% =========================================================

% Add path to SPM12 
addpath('/imaging/local/software/spm_cbu_svn/releases/spm12_latest/')

% =========================================================
% DEFINE PATHS PARAMETERS
% =========================================================

% Overall results directory
inputdir  = '/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition/results/SPM12';
% Location of the first-level results
firstleveldir = fullfile(inputdir, 'first_level', 'model01');
% Where to save the output
outpth = fullfile(inputdir, 'group_level', 'model01');
if ~exist(outpth, 'dir')
    mkdir(outpth);
end

% =========================================================


%% DESIGN

conditions = {'Famous','Unfamiliar','Scrambled'};
ncond = length(conditions);

matlabbatch{1}.spm.stats.factorial_design.dir = {outpth};

% Get all subject IDs
subs = cellstr(spm_select('List', firstleveldir, 'dir', '^sub-'));
nsub = numel(subs);

% Get the first-level contrast estimates for each condition of interest
for i = 1:nsub
    
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i).scans = {
        fullfile(firstleveldir, subs{i}, 'con_0001.nii');  % Familiar
        fullfile(firstleveldir, subs{i}, 'con_0002.nii');  % Unfamiliar
        fullfile(firstleveldir, subs{i}, 'con_0003.nii')}; % Scrambled
    
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i).conds = [1 2 3];
end

% SPM default parameters
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.dept           = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.variance       = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.gmsca          = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.ancova         = 0;
matlabbatch{1}.spm.stats.factorial_design.cov                       = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov                 = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none        = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im                = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em                = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit            = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no    = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm           = 1;

%% ESTIMATE
matlabbatch{2}.spm.stats.fmri_est.spmmat            = {fullfile(outpth, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals   = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical  = 1;

% Save matlabbatch for later inspection
spm_jobman('run', matlabbatch);
timenow = fix(clock);
save(fullfile(outpth, ['stats_GroupLevel_DesignAndEstimate_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');
clear matlabbatch


%% CONTRASTS
% Familiar Unfamiliar Scrambled
matlabbatch{1}.spm.stats.con.spmmat                     = {fullfile(outpth, 'SPM.mat')};
matlabbatch{1}.spm.stats.con.consess{1}.fcon.name       = 'Effects of Interest';
matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights    = [eye(ncond) repmat(1/nsub, ncond, nsub)];
matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep    = 'none';

matlabbatch{1}.spm.stats.con.consess{2}.tcon.name       = 'Faces > Scrambled';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights    = [0.5 0.5 -1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep    = 'none';

matlabbatch{1}.spm.stats.con.consess{3}.tcon.name       = 'Scrambled > Faces';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights    = [-0.5 -0.5 1];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep    = 'none';

matlabbatch{1}.spm.stats.con.consess{4}.tcon.name       = 'Familiar > Unfamiliar';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights    = [1 -1 0];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep    = 'none';

matlabbatch{1}.spm.stats.con.consess{5}.tcon.name       = 'Unfamiliar > Familiar';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights    = [-1 1 0];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep    = 'none';

matlabbatch{1}.spm.stats.con.delete = 1;

% Save matlabbatch for later inspection
spm_jobman('run', matlabbatch);
timenow = fix(clock);
save(fullfile(outpth, ['stats_GroupLevel_Contrasts_' date '_' num2str(timenow(4)) '_' num2str(timenow(5)) '.mat']), 'matlabbatch');
clear matlabbatch

%% REPORT (all contrasts)
spm('defaults','fmri');
spm_jobman('initcfg'); 

matlabbatch{1}.spm.stats.results.spmmat                     = {fullfile(outpth, 'SPM.mat')};
matlabbatch{1}.spm.stats.results.conspec(1).titlestr        = '';
matlabbatch{1}.spm.stats.results.conspec(1).contrasts       = Inf;
matlabbatch{1}.spm.stats.results.conspec(1).threshdesc      = 'FWE';
matlabbatch{1}.spm.stats.results.conspec(1).thresh          = 0.05;
matlabbatch{1}.spm.stats.results.conspec(1).extent          = 30;
matlabbatch{1}.spm.stats.results.conspec(1).mask.none       = 1;
matlabbatch{1}.spm.stats.results.export{1}.binary.basename  = 'fwe05_k30';
matlabbatch{1}.spm.stats.results.units                      = 1;
matlabbatch{1}.spm.stats.results.print                      = 'jpg';
matlabbatch{1}.spm.stats.results.write.none                 = 1;

spm_jobman('run', matlabbatch);
