Preprocessing the BATMAN dataset
======

The pre-processing chain consisted of two stages:

Stage                                             | Script
------------------------------------------------- | -------------
[Splitting data files][splitting]                 | [+batman/+preproc/splitting.m][splitting]
[Data cleaning][cleaning]                         | [+batman/+preproc/cleaning.m][cleaning]


[splitting]: ./splitting.m
[cleaning]: ./cleaning.m

## Usage synopsis

To process newly acquired data files through the BATMAN pre-processing 
chain simply place the files (or symbolic links to the files) under:

````
/data1/projects/batman/analysis/splitting
````

Note that in order to be able to write to the `splitting` directory you 
need to be a member of the `meegpipe` group. If you are not already a
member, ask [me][me] to add you.

If you are working at `somerengrid` or at any other system where the 
raw input files are managed by [somsds][somsds] then you should always 
use `somsds_link2rec` to add new symbolic links to the `splitting` 
directory. For instance, if you just acquired data from subjects 15 to 20
then you should run in a terminal:

````
cd /data1/projects/batman/analysis
somsds_link2rec batman --subjects 15..20 --modality eeg --folder splitting
````

[somsds]: http://germangh.com/somsds


## Assessing processing progress

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

If `qstat -u meegpipe` does not display your splitting jobs a few 
minutes after you placed the files in `OUTPUT_DIR` then there is something
wrong. In the troubleshooting section at the end of this document you 
may find the solution to the problem. 


## Processing results

The splitting results are stored under:

````
/data1/projects/batman/analysis/splitting
```

The cleaning results are stored under:

````
/data1/projects/batman/analysis/cleaning
````


## Troubleshooting

There are two major reasons for new data files to not be successfully 
submitted to the grid for processing:

* There is already a `.meegpipe` directory within `OUTPUT_DIR` that 
corresponds to the `.mff` file(s) that you want to be pre-processed. If 
you are trying to re-do the pre-processing of a given file then you must
delete the corresponding `.meegpipe` directory from `OUTPUT_DIR`. Note that
`OUTPUT_DIR` refers to `analysis/splitting` or `analysis/cleaning` 
depending on whether you want to re-do the splitting or the cleaning
stages (or both) for a given file.


* The splitting or the cleaning service is not running. You can test 
whether this is the case by running in a terminal:

````
ps aux | grep start_batman
````

which should display something like this:

````
meegpipe 17689  0.4  0.1 1131388 164172 pts/8  Sl   11:37   0:09 /usr/local/MATLAB/R2012b/bin/glnxa64/MATLAB -nodisplay -r run('~/start_batman_splitting')
meegpipe 17825 33.8  0.1 1256924 227956 pts/8  Sl   11:37  11:28 /usr/local/MATLAB/R2012b/bin/glnxa64/MATLAB -nodisplay -r run('~/start_batman_cleaning')
````

If either the splitting or cleaning MATLAB sessions are not running then 
you can re-start them yourself (provided you are a member of the `meegpipe`
group) by typing in a terminal:

````
/home/meegpipe/start_batman_cleaning.sh
/home/meegpipe/start_batman_splitting.sh
````

## The pre-processing chain

Here will come a description of the steps that the pre-processing chain 
involves.


[me]: mailto:g@germangh.com

