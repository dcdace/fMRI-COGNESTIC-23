function BIDS_copy_and_unzip(param, sub)

% ======================================================================
% dace.apsvalka@mrc-cbu.cam.ac.uk (2023)
% Based on https://www.frontiersin.org/articles/10.3389/fnins.2019.00300/full
%
% Copy and unzip imaging files from BIDS dataset to SPM derivatives to be
% preprocessed and analysed with SPM
%
% INPUT:
%
% param - a struct containing:
%   param.BIDS: path to BIDS dataset; string
%
%   param.outpth: output path; string (e.g., fullfile(param.BIDS,
%   'derivatives', 'SPM12')
%
%   param.modalities: which modalities to copy; cellstr (e.g. {'anat', 
%   'fmap', 'func'})
%
%   param.task: name if the functional task, as in BIDS file names; string (e.g.,
%   facerecognition
%
%   param.trialtypes: which trial types to include in the events files;
%   cellstr (e.g., {'Famous','Unfamiliar','Scrambled'}
%
% sub - subject ID (e.g., '01')
%
% ======================================================================

% Create subject's output directory if it doesn't exist
subjDir = fullfile(param.outpth, ['sub-' sub]);
if ~exist(subjDir, 'dir')
    spm_mkdir(param.outpth, ['sub-' sub], param.modalities);
end

% Loop through modalities and copy and unzip the imaging (.gz) files
for m = 1:length(param.modalities)
    modality = param.modalities{m};
    
    % Select files to copy
    files = spm_BIDS(param.BIDS, 'data', 'sub', sub, 'modality', modality);
    
    % Filter files to copy only .gz files
    files = files(cellfun(@(x) contains(x, '.gz'), files));
    
    % Destination directory
    outdir = fullfile(subjDir, modality);
    
    % Check if files have already been copied
    alreadyCopied = cellfun(@(file) spm_existfile(spm_file(file, 'path', outdir, 'ext', '')), files);
    
    if any(~alreadyCopied)
        disp(['Copying and unzipping sub-' sub ' ' modality ' images']);
        
        % Copy and unzip files
        spm_copy(files(~alreadyCopied), outdir, 'gunzip', true);
    else
        disp(['sub-' sub ' ' modality ' images have been copied already']);
    end
end

%% Create SPM's multiple conditions files
disp([ 'Creating ' sub ' SPM''s multiple conditions files']);
% Get number of runs
runs = spm_BIDS(param.BIDS, 'runs', 'sub', sub, 'type', 'events', 'task', param.task);
nrun = numel(runs);
% For each run, get events .tsv file from BIDS and transfer data into conds
% structure and save the .mat file
for r = 1:nrun
    events = spm_load(char(spm_BIDS(param.BIDS,'data','modality','func','type','events','sub',sub,'run',runs{r})));
    clear conds
    for t = 1:numel(param.trialtypes)
        conds.names{t}      = param.trialtypes{t};
        conds.durations{t}  = 0;
        conds.onsets{t}     = events.onset(strcmpi(events.trial_type, param.trialtypes{t}));
    end
    save(fullfile(subjDir, 'func', sprintf('sub-%s_run-%s_spmdef.mat', sub, runs{r})), '-struct', 'conds');
end

disp(['sub-' sub ' files copied'])