Preprocessing the BATMAN dataset
======

During development and optimization of the pre-processing chain, the 
pre-processing of the BATMAN dataset was organized into four stages: 

Stage                                             | Script
------------------------------------------------- | -------------
[Splitting data files][stage1]                    | [+batman/+preproc/stage1.m][stage1]
[Basic pre-processing][stage2]                    | [+batman/+preproc/stage2.m][stage2]
[PWL and MUX-related artifact correction][stage3] | [+batman/+preproc/stage3.m][stage3]
[Removal of cardiac and ocular artifacts][stage4] | [+batman/+preproc/stage3.m][stage4]

After the main parameters of the pre-processing pipeline were fixed, these
four stages were then grouped into just two:

Stage                                             | Script
------------------------------------------------- | -------------
[Splitting data files][splitting]                 | [+batman/+preproc/splitting.m][splitting]
[Data cleaning][cleaning]                         | [+batman/+preproc/stage2.m][cleaning]

Thus, to reproduce the whole pre-processing chain from the raw data you 
need to execute in MATLAB:

````matlab
batman.setup; % Installs meegpipe and/or adds it to the path
batman.splitting;
batman.cleaning;
````

The whole process can cake a long time depending on the number of data
 files to be splitted and cleaned. 

[stage1]: ./stage1.md
[stage2]: ./stage2.md
[stage3]: ./stage3.md
[stage4]: ./stage4.md
[splitting]: ./splitting.m
[cleaning]: ./cleaning.m


