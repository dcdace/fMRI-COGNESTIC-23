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
% DEFINE DATAPATHS PARAMETERS
% =========================================================

% Location of the BIDS dataset
BIDS = '/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition/data/bids/';
% Location of the preprocessed data
param.datadir = fullfile(BIDS, 'derivatives', 'SPM12');
% Where to save the results
param.outpth = fullfile('/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition/', 'results', 'SPM12', 'first_level', 'model01');

% =========================================================
% DEFINE FIRST-LEVEL MODEL PARAMETERS
% =========================================================

% Retrieve metadata
metadata = spm_BIDS(BIDS, 'metadata', 'sub', '01', 'run', '01', 'type', 'bold');

% Define parameters
param.TR         = metadata.RepetitionTime;
param.hpf        = 128;
param.hrf_derivs = [1 1]; % time and dispersion	derivatives
param.nDummy     = 0;

% If Slice-time correction was performed at preprocessing, need to specify
% the number of sclices and the reference slice.
% Reference slice was a slice that was acquired at the middle of TR
param.nslices   = length(metadata.SliceTiming);
[~, idx] = sortrows(metadata.SliceTiming); % get the slice acquisition order
param.ref_slice = idx(floor(param.nslices/2)); % finds the middle slice in time

% =========================================================
% DEFINE CONTRAST PARAMETERS
% =========================================================
param.conditions = {'Famous','Unfamiliar','Scrambled'};

param.contrast_names = {
    'Famous' ...
    'Unfamiliar' ...
    'Scrambled' ...
    'Faces > Scrambled'
    };

% Because we are adding time and dipersion derivatives, each condition
% has 2 extra regressors; and we are also adding 6 movement parameters.
%
param.contrasts = {
    [1   0 0    0   0 0      0 0 0    0 0 0 0 0 0] ... % Famous
    [0   0 0    1   0 0      0 0 0    0 0 0 0 0 0] ... % Unfamiliar
    [0   0 0    0   0 0      1 0 0    0 0 0 0 0 0] ... % Scrambled
    [0.5 0 0    0.5 0 0     -1 0 0    0 0 0 0 0 0] ... % Faces > Scrambled
    };

param.eof_contrast = [
    1 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 1 0 0 0 0 0 0 0 0]; % Effects of interest

% =========================================================
% Number of workers for distributed computing (
numworkers = 12; % 12 is max at the CBU
if numworkers
    parpool(numworkers);
end

% =========================================================
% FIRST-LEVEL ANALYSIS FOR ALL SUBJECTS
% =========================================================
% Get all subject IDs
subs = cellstr(spm_select('List',param.datadir, 'dir','^sub-'));
nsub = numel(subs);

% Loop through subjects
parfor (s = 1:nsub, numworkers)
    
    sub = subs{s};
    
    do_first_level(param, sub);
    
end

