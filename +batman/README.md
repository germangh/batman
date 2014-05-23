batman
======

## The BATMAN dataset

A description of the experimental protocol will be here at some point.



## Extracted signal features

The table below lists all the features that have been so far extracted 
from the BATMAN dataset:

Feature set                                           | Relevant MATLAB package
----------------------------------------------------- | -------------
Arterial blood pressure (ABP)                         | [+abp](./+abp)
Heart Rate Variability (HRV)                          | [+hrv](./+hrv)
PVT reaction times                                    | [+pvt](./+pvt)
Resting state spectral power                          | [+rs_eeg](./+rs_eeg)

Typically, all features are extracted for all files by running the
relevant `main` script. Then all features are aggregated into a single 
feature table using the relevant `aggregate` script. That is, to extract 
and aggregate all `pvt` features simply run:

````matlab
pvt.main
pvt.aggregate
````
All feature types can be merged together into a single table using the
 relevant `merge_[RECID]_features.R` script, where `[RECID]` is the 
recording ID. For instance, to merge all features from the `batman` 
recording you should open shell window and run:

````
cd /data1/projects/batman/scripts/batman
./merge_batman_features.R
````

## Analyses performed

Analysis                                              | Documentation
----------------------------------------------------- | -------------
Statistical analysis of effects on EEG power features | [./+stats/README.md][stats]
