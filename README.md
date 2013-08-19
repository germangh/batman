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

The first thing you need to do is to clone the batman repository. Open a
terminal and type:

````bash
cd /data1/projects/batman/scripts
git clone https://github.com/germangh/batman
```` 

Next you need to install [meegpipe][meegpipe]. Note that you may need to 
install some third-party dependencies as described in 
[meegpipe's documentation][meegpipe]. If you are working at `somerenserver` 
all the depencies have been already installed and you just need to follow
the simple instructions below.

Open a terminal and type:

````bash
cd /data1/projects/batman/scripts
mkdir meegpipe-root
cd meegpipe-root
git clone https://github.com/germangh/meegpipe
````

Then open MATLAB and type:

````matlab
cd /data1/projects/batman/scripts/meegpipe-root/meegpipe
submodule_update([], true);
````

After `submodule_update` has downloaded all the necessary modules you are
ready to perform any of the analyses described below. To minimize the 
possibility of name clashes between `meegpipe` and other MATLAB toolboxes, 
it is best that you always run the following commands just before 
attempting to reproduce any of the analyses:

````matlab
restoredefaultpath;
addpath(genpath('/data1/projects/batman/scripts'));
````


[meegpipe]: http://germangh.com/meegpipe

[batman]: http://www.neurosipe.nl/project.php?id=23&sess=6eccc41939665cfccccd8c94d8e0216f
[stw]: http://www.stw.nl/en/

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