#!/bin/bash
#
#SBATCH --job-name=mriqc
#SBATCH --nodes=2
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=8:00:00

# ============================================================
# This script will process subjects in parallel using slurm
# To run this script, use this command (adjust for the nunber of subjects): 
#
# sbatch --array=0-15 ./step05_mriqc_run.sh
#
# ============================================================
# This script uses MRIQC Singularity image
# To get the latest Docker image (or Singluarity/Apptainer) use: 
# docker pull nipreps/mriqc:latest
# ============================================================


#-----------------------------------------------------------
# Define paths
#-----------------------------------------------------------
# Define the project root directory
PROJECT_PATH=/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition

#-----------------------------------------------------------
# Get the list of subject for this project
#----------------------------------------------------------- 
SUBJECT_DIRS=("$PROJECT_PATH"/data/bids/sub-*)
SUBJECT_LIST=("${SUBJECT_DIRS[@]##*/}") 

#-----------------------------------------------------------
# Index each subject per job array (adjusting for one-based indexing)
subject=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID} - 1]}

# ======================================================================
# MRIQC with Singularity
# ======================================================================
singularity run --cleanenv -B "$PROJECT_PATH":/"$PROJECT_PATH" \
    /imaging/local/software/singularity_images/mriqc/mriqc-22.0.1.simg \
    "$PROJECT_PATH"/data/bids \
    "$PROJECT_PATH"/data/bids/derivatives/mriqc/ \
    --work-dir "$PROJECT_PATH"/data/work/mriqc/"$subject" \
    participant \
    --participant-label "${subject#sub-}" \
    --float32 \
    --n_procs 16 --mem_gb 24 --ants-nthreads 16 \
    --modalities T1w bold \
    --no-sub
# EACH LINE EXPLINED:
# attaching our project directory to the Singularity
# the Singularity file
# our BIDS data directory
# output directory
# --work-dir: path where intermediate results should be stored
# analysis_level (participant or group)
# --participant-label: a list of participant identifiers
# --float32: cast the input data to float32 if it’s represented in higher precision (saves space and improves perfomance)
# --n_procs 16 --mem_gb 24 --ants-nthreads 16: options to handle performance
# --modalities: filter input dataset by MRI type
# --no-sub: turn off submission of anonymized quality metrics to MRIQC’s metrics repository
# ======================================================================