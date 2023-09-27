# Bonus materials - SPM analysis scripts

Example SPM12 scripts for analysing the same dataset as in the main workshop materials where we use Nilearn. These scripts are based on https://www.frontiersin.org/articles/10.3389/fnins.2019.00300/full. 

Assumes that dataset is formated according to [BIDS](https://bids.neuroimaging.io/). 

Follows the following steps: 

1. Preprocesing `step01_preprocessing.m`

    Calls the following sub-functions

    * Copying and unzipping files from BIDS dataset to SPM derivatives folder `BIDS_copy_and_unzip.m`
    * Realignment (motion-correction) `preprocess_realign.m`
    * Slice-time correction `preprocess_slicetime.m`
    * Segmentation of the structural (T1w) image  `preprocess_segmentation.m`
    * Co-registering all BOLD images to the structural image `preprocess_coregister.m`
    * Normalising BOLD images to MNE space and applying smoothing `preprocess_normalisation.m`

2. Checking head-motion (realignment parameters) `step02_check_movement.m`
3. Subject-level (first-level) analysis `step03_first_level_analysis.m`

    Calls sub-function `do_first_level.m`

4. Group-level analysis `step04_group_analysis.m`