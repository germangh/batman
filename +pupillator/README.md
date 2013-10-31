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


## The PUPILLATOR dataset

A description of the experimental protocol will be here at some point.


## Pre-requisites

The `pupillator` package depends on [meegpipe][meegpipe]. If you are 
working at the `somerengrid` then you only need to run this code in order 
to make `meegpipe`'s functionality available:

````matlab
close all; clear all; clear classes;
restoredefaultpath;
addpath(genpath('/data1/toolbox/meegpipe'));
meegpipe.initialize;
````
[meegpipe]: http://github.com/meegpipe/meegpipe

## What have we done with the pupillator dataset?

The table below lists all the analyses and processing tasks that have been
 perfomed on the pupillator dataset so far, roughly in chronological order.

What?                                                 | Documentation
----------------------------------------------------- | -------------
Heart Rate Variability (HRV) feature extraction       | [HRV.md][hrv]
Feature extraction from PVT task reaction times       | [PVT.md][pvt]
Pupil diameter (PD) feature extraction                | [PD.md][pd]
Merging PVT, HRV and PD features in a single table    | [modeling.md][modeling]

[hrv]: ./HRV.md
[pvt]: ./PVT.md
[pd]: ./PD.md
[modeling]: ./modeling.md
