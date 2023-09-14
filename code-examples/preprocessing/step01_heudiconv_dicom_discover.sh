#!/bin/bash

# ============================================================
# To use HeudiConv, either install heudiconv and dcm2niix:
# pip install heudiconv==0.13.1
# conda install -c conda-forge dcm2niix
#
# Or use a Docker (or Apptainer/Singularity) image:
# docker pull nipy/heudiconv
#
# HeudiConv parameters:
# -d, --dicom_dir_template : dicom directory
# -o, --outdir : output directory
# -f, --heuristic : heuristics type/file
# -s, --subjects
# -c, --converter : dicom to nii converter
# -b, --bids
# ============================================================

# Define the project root directory
PROJECT_PATH='/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition'

# Define the path to DICOM files under the project directory
DICOM_PATH=$PROJECT_PATH/data/dicom

# Define the path where to save  the output data
OUTPUT_PATH=$PROJECT_PATH/data/work/dicom_discovery/

# Which subject to process
sid="01"

# Run the heudiconv
heudiconv \
    -d $DICOM_PATH/{subject}/*/*/*/*.dcm \
    -o $OUTPUT_PATH \
    -f convertall \
    -s $sid \
    -c none \
    -b \
    --overwrite