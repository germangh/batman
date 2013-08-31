EEG features
======


## Resting state features

Spectral features are automatically extracted from every file that have 
been fed to the BATMAN pipeline. The extracted features and the 
corresponding HTML report can be found under:

````
/data1/projects/batman/rs
````

### Aggregating all features in a single file

An aggregated features file that contains all features for all files can 
be generated running in MATLAB:

````matlab
batman.features.rs_aggregate;
````

which will generate the files:

````
features_power_ratios_absref.csv
features_power_absref.csv
features_power_ratios_avgref.csv
features_power_avgref.csv
features_power_ratios_linkedref.csv
features_power_linkedref.csv
````

under `/data1/projects/batman/rs`. The first file of each pair contains
 normalized power features in different bands (normalized over the average
power in the band from 0 to 100 Hz). The second file contains average power 
values in the same bands. There is a pair of files for each of the spectral
analysis pipelines considered: one for absolute reference, one for average
reference and one for linked reference. These files can be easily imported
 in R for further statistical analyses.


### Aggregating topographies for individual features


__NOTE:__ This does not work yet!

Run in MATLAB:

````
batman.rs_aggregate_topos;
````

which will generate the following files:


