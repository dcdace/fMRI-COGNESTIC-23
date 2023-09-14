#!/bin/bash

#-----------------------------------------------------------
# Define paths
#-----------------------------------------------------------
# Define the project root directory
PROJECT_PATH=/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition

# ======================================================================
# MRIQC with Singularity
# ======================================================================
singularity run --cleanenv -B "$PROJECT_PATH":/"$PROJECT_PATH" \
    /imaging/local/software/singularity_images/mriqc/mriqc-22.0.1.simg \
    "$PROJECT_PATH"/data/bids "$PROJECT_PATH"/data/bids/derivatives/mriqc/ \
    --work-dir "$PROJECT_PATH"/data/work/mriqc/ \
    group \
    --float32 \
    --n_procs 16 --mem_gb 24 \
    --ants-nthreads 16 \
    --modalities T1w bold \
    --no-sub