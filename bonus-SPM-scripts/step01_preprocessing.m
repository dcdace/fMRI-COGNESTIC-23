% ======================================================================
% dace.apsvalka@mrc-cbu.cam.ac.uk (2023)
% Based on https://www.frontiersin.org/articles/10.3389/fnins.2019.00300/full
%
% Preprocessing fMRI data. Assumes that data is in BIDS standard. 
%
% =========================================================

% Add path to SPM12 and preprocessing scripts
addpath('/imaging/local/software/spm_cbu_svn/releases/spm12_latest/')
addpath('/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition/code/spm')

% =========================================================
% DEFINE PARAMETERS
% =========================================================
% Location of the BIDS dataset
param.BIDS = '/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition/data/bids/';
% Where to save the outut
param.outpth = fullfile(param.BIDS, 'derivatives', 'SPM12');
% Define modalities that you need for the analysis
param.modalities = {'anat', 'func'};
% Which functional task
param.task = 'facerecognition';
% Which trial types to include in events files
param.trialtypes = {'Famous','Unfamiliar','Scrambled'}; 
% How many dummy volumes there are that need to be discarded
param.dummy = 0;
% Smoothing kernel for normalised images
param.smooth_fwhm = [8 8 8];
% Keep or delete intermediate files
keepdata = false; % If false, only the normalised and smoothed images will be kept

% Number of workers for distributed computing
numworkers = 12; % 12 is max at the CBU
if numworkers
    parpool(numworkers); 
end

% =========================================================
% ADDITIONAL PARAMETERS FROM BIDS METADATA
% =========================================================

% Get subject IDs from the BIDS dataset
subs = spm_BIDS(param.BIDS, 'subjects');
% How many subject are there
nsub = numel(subs);


% Retrieve the metadata
metadata = spm_BIDS(param.BIDS,'metadata', 'sub', subs{1}, 'run', '01', 'task', param.task, 'type', 'bold');

% Get the parameters
param.TR        = metadata.RepetitionTime;
param.nslices   = numel(metadata.SliceTiming);
param.TA        = param.TR-param.TR/param.nslices;
param.sorder    = metadata.SliceTiming;
param.rslice    = param.TR/2;

% =========================================================
% PREPROCESS ALL SUBJECTS
% =========================================================

% Loop through subjects
parfor (s = 1:nsub, numworkers)
    
    sub = subs{s};
   
    % COPY AND UNZIP files from BIDS dataset to SPM derivatives folder
    BIDS_copy_and_unzip(param, sub);
    
    % REALIGNMENT
    preprocess_realign(param, sub, 'sub-');
    
    % SLICE TIMING CORRECTION
    preprocess_slicetime(param, sub, 'rsub-');
    
    % SEGMENTATION
    preprocess_segmentation(param, sub);

    % COREGISTRATION (EPI to anatomical)
    preprocess_coregister(param, sub, 'arsub-');
    
    % NORMALISATION
    preprocess_normalisation(param, sub, 'arsub-');
    
    % DELETE INTERMEDIATE FILES
    if ~keepdata
        disp(['Deleting sub-' sub ' intermediate files'])
        subjDir = fullfile(param.outpth, ['sub-' sub]);
        outdir = fullfile(subjDir, 'func');

        files_to_delete = cellstr(spm_select('FPList', outdir, '^sub-.*bold\.nii$'));
        spm_unlink(files_to_delete {:});
        
        files_to_delete  = cellstr(spm_select('FPList', outdir, '^rsub-.*bold\.nii$'));
        spm_unlink(files_to_delete {:});
        
        files_to_delete  = cellstr(spm_select('FPList', outdir, '^arsub-.*bold\.nii$'));
        spm_unlink(files_to_delete {:});
        
        files_to_delete  = cellstr(spm_select('FPList', outdir, '^warsub-.*bold\.nii$'));
        spm_unlink(files_to_delete {:});

        files_to_delete  = cellstr(spm_select('FPList', outdir, '^meansub-.*bold\.nii$'));
        spm_unlink(files_to_delete {:});
    end
    
    disp(['sub-' sub ' preprocessing done.'])
end
