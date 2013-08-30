Preprocessing the BATMAN dataset
======

The pre-processing chain consisted of two stages:

Stage                                             | Script
------------------------------------------------- | -------------
[Splitting data files][splitting]                 | [+batman/+preproc/splitting.m][splitting]
[Data cleaning][cleaning]                         | [+batman/+preproc/stage2.m][cleaning]


[splitting]: ./splitting.m
[cleaning]: ./cleaning.m

## Splitting

The splitting stage consisted in splitting the large `.mff` files produced
by the BATMAN experimental protocol into single-epoch files. By epoch 
we mean a chunk of the data file that corresponds to a single 
experimental condition. At this point only the resting state (RS) epochs 
are splitted in this stage. The results of this stage are stored in  
directory:

````
/data1/projects/batman/analysis/splitting
````

To split a set of files, type the following in a terminal:

````
newgrp meegpipe
````

__NOTE:__ You need to be a member of the group `meegpipe` for the command
above to succeed. If you are not already a member, ask [me][me] to add you.

Then simply place the `.mff` files to be splitted (or symbolic links to 
those  files) within `OUTPUT_DIR` and they will be automatically processed 
with the splitting pipeline after a few seconds. 

You can test whether the splitting jobs were submitted to the grid by
running in a terminal at `somerengrid`:

```
qstat -u meegpipe
````

To output produced by a given splitting job is stored in the text file:

````
/home/meegpipe/[jobname].o[jobid]
````

where `[jobid]` is the ID of the job as displayed by `qstat`. You can get
the full name of a job running in a terminal:

````
qstat -j [jobid]
````

If `qstat -u meegpipe` does not display your splitting jobs a couple of 
minutes after you placed the files in `OUTPUT_DIR` then there can be 
two reasons for this:

* There is already a `.meegpipe` directory within `OUTPUT_DIR` that 
corresponds to the `.mff` file(s) that you want to be processed. These 
directories are probably leftovers from a previous splitting operation 
that you are now attempting to re-do. The solution is to delete the
 ofending `.meegpipe` directories. 


* The splitting service is not running. Ask [me][me] to restart it. If I 
am not available you can also create your own instance of the splitting 
service under your account, by running in MATLAB:

````
batman.preproc.splitting;
````

But be aware that the service instance that you just create will scan for 
new files (and will store the splitting results) in directory:

````
/data1/projects/batman/analysis/splitting_[username]
````

where `[username]` is __your user name__. Thus you will need to place the
files that you want to be splitted in that directory.

[me]: mailto:g@germangh.com


## Cleaning

As the splitting pipeline, the cleaning pipeline also works as a service.
It automatically cleans any data split that can be found within the 
`OUTPUT_DIR` of the splitting pipeline. If for whatever reason you want 
the cleaning pipeline to be re-applied on certain file then you just need
 to delete the corresponding `.meegpipe` directory from the output
directory of the cleaning pipeline, which is:

````
/data1/projects/batman/analysis/cleaning
````
