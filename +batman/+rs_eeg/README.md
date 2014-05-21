Feature extraction
======


## Resting state EEG features

Resting stage EEG power features can be extracted from the output of the
[preprocessed data files][preproc] using:

[preproc]: ../+preproc/README.md

````
% Still to be written!!!
batman.rs_eeg.main
````

The extracted features and the corresponding HTML reports for each data file
will be stored under:

````
/data1/projects/batman/spectral_analysis
````

### Aggregating all features in a single file

An aggregated features file that contains all features for all files can
be generated running in MATLAB:

````matlab
batman.features.aggregate;
````

which will generate the files:

````
features_alpha.csv
features_beta1.csv
features_beta2.csv
features_delta.csv
````

### Aggregating topographies for individual features

Run in MATLAB:

````
batman.rs_eeg.aggregate_topos;
````

