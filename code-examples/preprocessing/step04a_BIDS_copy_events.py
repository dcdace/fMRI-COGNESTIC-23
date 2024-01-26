import os
import shutil

# Copy event information from Wakeman's ds000117 to my ExampleStudy
source = '/imaging/correia/da05/workshops/2022-09-COGNESTIC/Wakeman-ds/ds000117'
destination = '/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition/data/bids'

nsub = 16
nrun = 9

for i in range(1, nsub+1):
    sub = f'sub-{i:02d}'
    source_dir = os.path.join(source, sub, 'ses-mri', 'func')
    source_list = sorted([f for f in os.listdir(source_dir) if f.endswith('.tsv')])
    
    dest_dir = os.path.join(destination, sub, 'func')
    dest_list = sorted([f for f in os.listdir(dest_dir) if f.endswith('.tsv')])
    
    for f in range(nrun):
        f1 = os.path.join(source_dir, source_list[f])
        f2 = os.path.join(dest_dir, dest_list[f])
        shutil.copy2(f1, f2) 
        print(f"{sub} run {f} copied")