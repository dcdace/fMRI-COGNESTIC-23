#!/bin/bash

# ============================================================
# This script used PyDefae to remove 'faces' from T1 anatomical images. 
# It requires PyDeface package and several dependencies https://github.com/poldracklab/pydeface 
# One of the dependencies is FSL. In this script it is assumed that FSL is avalable as a module on a system. 
# 
# Alternatively to installing PyDeface and its depenencies, a good de-facing tool is 'bidsonym'.
# bidsonym is available as a Docker image: docker pull peerherholz/bidsonym
# An example script for using bidsonym Docker image is provided at the bottom of this script in comments. 
# ============================================================

module load fsl

# Define the project root directory
project_dir=/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition

# Find all T1w files
T1w_LIST=($(eval echo "$project_dir"/data/bids/sub-*/anat/*T1w.nii.gz))

# Deface, rewriting the original files
for file in "${T1w_LIST[@]}"
do
    pydeface "$file" --outfile "$file" --force &
done

wait

module unload fsl

# ============================================================
# An example of using bidsonym Docker image to de-face T1 images
# ============================================================

# # Define the location of the BIDS dataset
# BIDS=/mnt/z/Imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition/data/bids

# # Run bidsonym on the BIDS dataset
# docker run -i --rm \
#            -v "$BIDS":/bids_dataset \
#            peerherholz/bidsonym \
#            /bids_dataset  \
#            group \
#            --skip_bids_validation \
#            --deid pydeface \
#            --brainextraction bet \
#            --bet_frac 0.5
#            #--del_meta 'InstitutionAddress'