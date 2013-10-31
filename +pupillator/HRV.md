Extraction of HRV features
======

Assuming you are working at the `somerengrid`, you only need to run the 
following code to perform the HRV feature extraction:

````
% Make meegpipe functionality available
close all; clear all; clear classes;
restoredefaultpath;
addpath(genpath('/data1/toolbox/meegpipe'));
meegpipe.initialize;

% Run the HRV feature extraction script
pupillator.main_hrv;
````

The feature extraction is implemented as a [meegpipe][meegpipe] pipeline. 
The actual pipeline is defined in [pupillator.pipes.hrv_analysis][hrv-pipe]. 

[meegpipe]: http://github.com/meegpipe/meegpipe
[hrv-pipe]: ./+pipes/hrv_analysis.m

The HRV features are extracted with the help of the [HRV toolkit][hrv-toolkit]. 
See the corresponding [documentation][hrv-toolkit] for a description of all 
extracted features.

[hrv-toolkit]: http://physionet.org/tutorials/hrv-toolkit/
