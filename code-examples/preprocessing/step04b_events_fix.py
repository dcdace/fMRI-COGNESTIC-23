from cmath import nan
import os
import glob
import pandas as pd

path_bids = '/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition/data/bids'

path_events = os.path.join(path_bids, '*', 'func', '*_events.tsv')

# get all fieldmap files in the data-set:
files_events = glob.glob(path_events)
# loop over all event files:
for file_path in files_events:
    # read in the event file
    events = pd.read_table(file_path)
    # rename the column
    events.rename(columns={"stim_type": "trial_type"}, inplace=True)
    # fill empty trial type as REST
    events["trial_type"].replace(nan, 'REST', inplace=True)
    # save the updated file
    events.to_csv(file_path, sep="\t", index=False)
    print(file_path, " updated")