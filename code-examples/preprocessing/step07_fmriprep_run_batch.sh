#!/bin/bash

#-----------------------------------------------------------
# Define paths
#-----------------------------------------------------------
# Define the project root directory
PROJECT_PATH=/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition

#-----------------------------------------------------------
# Where to output jobs
#-----------------------------------------------------------
JOB_DIR="$PROJECT_PATH"/data/work/fmriprep/jobs
mkdir -p "$JOB_DIR"
cd "$JOB_DIR" || exit

#-----------------------------------------------------------
# Call to the _fmriprep_define script for each subject with 1 minute delay
#-----------------------------------------------------------
for d in "$PROJECT_PATH"/data/bids/sub-*/; do
    sid=$(basename "$d")    
    sbatch --job-name=fmriprep --time=7-00:00 --cpus-per-task=16 "$PROJECT_PATH"/code/preprocessing/step07_fmriprep_define.sh "${PROJECT_PATH}" "${sid}"
    sleep 1m   # Fmriprep: Workaround for running subjects in parallel https://neurostars.org/t/updated-fmriprep-workaround-for-running-subjects-in-parallel/6677
done