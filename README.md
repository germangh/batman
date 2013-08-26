batman
======

This repository contains the code and instructions necessary to reproduce
the data analyses of the [STW][stw]-funded project [BATMAN][batman]. 

In the following we will assume that the analysis are to be reproduced 
under directory `/data1/projects/batman/analysis`, and that the necessary 
code is to be stored under `/data1/project/batman/scripts`. For convenience
we will refer to these two directories as `ADIR` and `SDIR`. We will also 
assume that the analysis are to be performed under Linux, and that the 
raw data files are available through the [somsds][somsds] data management
system.

[somsds]: https://github.com/germangh/somsds


## The BATMAN dataset

A description of the experimental protocol will be here at some point.



## List of performed analyses

The table below lists all the analyses that have been perfomed on the 
BATMAN dataset so far, in chronological order.

Analysis                                    | Documentation
------------------------------------------- | -------------
Pre-processing                              | [+batman/+preproc/README.md][preproc]
Spectral analysis of resting state data     | [+batman/+rs/README.md][rs]

[preproc]: ./+batman/+preproc/README.md
[rs]: ./+batman/+rs/README.md    