#!/bin/bash
#
#SBATCH --job-name=heudiconv
#SBATCH --nodes=2
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=1:00:00

# ============================================================
# This script will process subjects in parallel using slurm
# To run this script, use this command (adjust for the nunber of subjects): 
#
# sbatch --array=0-15 ./step02_heudiconv_run.sh
#
# ============================================================

#-----------------------------------------------------------
# Define paths
#-----------------------------------------------------------
# Define the project root directory
PROJECT_PATH=/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition
# Define the path to DICOM files under the project directory
DICOM_PATH=$PROJECT_PATH/data/dicom
# Define the path where to save  the output data
OUTPUT_PATH=$PROJECT_PATH/data/bids

#-----------------------------------------------------------
# Get a list of subjects from the dicom directory
#-----------------------------------------------------------
# Which subject to process
SUBJECT_LIST=()  # Initialize the array

for d in "$DICOM_PATH"/*; do
    sub_id=$(basename "$d")
    SUBJECT_LIST+=("$sub_id")
done

#-----------------------------------------------------------
# Index each subject per job array (adjusting for one-based indexing)
sid=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID} - 1]}

#-----------------------------------------------------------
# Do the conversion using heudiconv
#-----------------------------------------------------------
heudiconv \
    -d $DICOM_PATH/{subject}/*/*/*/*.dcm \
    -o $OUTPUT_PATH \
    -f $PROJECT_PATH/code/preprocessing/heudiconv_heuristic.py \
    -s $sid \
    -c dcm2niix \
    -b \
    --overwrite