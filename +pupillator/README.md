BATMAN: pupillator analyses
======

The `pupillator` package contains all the instructions and code necessary
to reproduce the data analyses performed on the pupillator dataset. The
pupillator project is a sub-project within [STW][stw]-funded project
[BATMAN][batman].

In the documentation that follows we will assume a Linux-like OS, and that
the BATMAN dataset is managed by [somsds][somsds] data management system.
This is the case if you are trying to reproduce the data analyses at
the `somerengrid` (our lab's private computing grid).

[somsds]: https://germangh.com/somsds
[batman]: http://www.neurosipe.nl/project.php?id=23&sess=6eccc41939665cfccccd8c94d8e0216f
[stw]: http://www.stw.nl/en/


## Experimental datasets

A description of the experimental protocol(s) will be here at some point.


## Pre-requisites

The `pupillator` package depends on [meegpipe][meegpipe]. If you are
working at the `somerengrid` then you only need to run this code in order
to make `meegpipe`'s functionality available:

````matlab
close all; clear all; clear classes;
restoredefaultpath;
addpath(genpath('/data1/toolbox/matlab'));
addpath(genpath('/data1/toolbox/meegpipe'));
meegpipe.initialize;
````
[meegpipe]: http://github.com/meegpipe/meegpipe


## What features can we extract from a pupillator recording?

The table below lists all the features that we have extracted from the 
pupillator recordings.


What?                                                 | Documentation
----------------------------------------------------- | -------------
Heart Rate Variability (HRV) features                 | [+hrv][hrv]
PVT task reaction times                               | [+pvt][pvt]
Pupil diameter (PD) features                          | [+pd][pd]

[hrv]: ./+hrv/README.md
[pvt]: ./+pvt/README.md
[pd]: ./+pd/README.md

## Merging all features into a single table

To merge all relevant features into a single data table (in `.csv`) format
you can use the corresponding `merge_[RECID]_features.R` script, where 
`[RECID]` is the recording ID (usually a 4-letters code). For instance, 
to merge all features extracted from the `psvu` recording,  open a shell 
window and type:

````
cd /data1/projects/psvu/scripts/batman
./merge_psvu_features.R
````




