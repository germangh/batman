Preprocessing: Stage 3
===

The last pre-processing stage consisted in the following steps:

* Downsampling to 250 Hz.

* Removal of powerline (50 Hz) noise

* Removal of MUX-related noise components

* Removal of ocular activity

Stage 3 is implemented in script [batman.preproc.stage3][stage3]. Thus, to
reproduce stage 3 simply run in MATLAB:

[stage2]: ./stage3.m

````matlab
batman.preproc.stage3
````

Of course, for the command above to work you should have completed 
successfully [stage 2][stage2-doc] of the pre-processing chain.

[stage2-doc]: ./stage2.md

Below you can find a detailed description of what is going on inside 
[stage3.m][stage3].

[stage3]: ./+batman/+preproc/stage3.m

## Import directives

These are required in order to be able to use short names to refer to 
some of the `meegpipe`'s components that are used within `stage1.m`:

````matlab
meegpipe.initialize; % required only once per MATLAB session

import meegpipe.node.*;

% Some basic file and string manipulation utilities
import meegpipe.node.*;
import somsds.link2files;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

% Some data selectors
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

% Bring to the current namespace all available BSS algorithms
import spt.bss.*;
````


## Analysis parameters

The first section of `meegpipe.preproc.stage3` defines several important
 processing parameters


````matlab
PIPE_NAME = 'stage3';

USE_OGE = true;

DO_REPORT = true;

switch lower(get_hostname)
    case 'somerenserver'
        ROOT_DIR = '/data1/projects/batman/analysis';
        INPUT_DIR = catdir(ROOT_DIR, 'stage2');
        
    case 'nin271',
        ROOT_DIR = 'D:\batman';
        INPUT_DIR = 'D:\data';
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

OUTPUT_DIR = catdir(ROOT_DIR, 'stage3');
```` 


## Build pipeline nodes

The first node of the pipeline will read the single-block files generated 
during [stage 2][stage2-doc] and create a corresponding 
[physioset][physioset] object. Recall that a [physioset][physioset] is the
 basic data structure used by the [meegpipe][meegpipe] toolbox. All data 
processing nodes (with the exception of the `physioset_import` node) expect
a `physioset` object at their input, and produce a `physioset` object at 
their output.

[physioset]: https://github.com/germangh/matlab_physioset
[meegpipe]: https://github.com/germangh/meegpipe



### Node 1: `physioset_import`

````matlab
% Initialize the list of processing nodes
nodeList = {};

% This importer object knows how to import pset/pseth files, which are the 
% kind of files natively used by the meegpipe toolbox. This is the format 
% of the files that were generated during stage 2.
myImporter = physioset.import.physioset('Precision', 'double');

% We use the importer object above to build a processing node that reads 
% pset/pseth files and produces an equivalent physioset object
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];
````

### Node 2: `copy`

This is a very important, but easy to forget step when using `meegpipe` to 
process a dataset in multiple stages. Stage 2 of the pre-processing chain
generated a set of native `pset/pseth` files that contain a binary 
representation of the `physioset` object produced by the pipeline used in
stage 2. The `physioset_import` node that we built above will simply load
 the `physioset` objects that are contained in those files. 

Recall that `physioset` objects loaded in MATLAB's workspace are just 
references to an underlying `.pset` file. Thus, if we do not implicitely 
copy the `physioset` object produced by the `physioset_import` node the 
following nodes of the pipeline will directly operate on the output files
produced by stage 2. This implies that if you run `batman.preproc.stage3` 
__the output of stage 2 will be modified__. 

We introduce a `copy` node in the pipeline in order to generate independent 
copies of the `physioset` objects that were produced during stage 2:

````matlab
myNode = copy.new;
nodeList = [nodeList {myNode}];
````

### Node 3: `resample`

This node will reduce the data sampling rate to 250 Hz:

````matlab
myNode = resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];
````

### Node 4: `bss_regr.pwl`

The [bss_regr node][bad_regr] node is a very flexible node that can be 
used to remove several types of artifacts. For convenience, the `meegpipe`
toolbox provides several _default configurations_ of the `bss_regr` node 
that are likely to work well for removing specific types of artifacts. For
instance, the `bss_regr.pwl` default configuration is a good starting point
for attempting to remove powerline noise.

[bad_regr]: https://github.com/germangh/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bbss_regr/README.md
[function_handle]: http://www.mathworks.nl/help/matlab/ref/function_handle.html

````matlab
myNode = bss_regr.pwl('IOReport', report.plotter.io);

nodeList = [nodeList {myNode}];
````

If you set property `IOReport` to `report.plotter.io` like we did above, 
the input and the output of the node will be compared in an additional 
report. This will slow down the processing but is quite useful when you
want to get some specific feedback on what exactly your node did to the 
data.

### Node 5: MUX noise removal using `bss_regr`

The BATMAN dataset is contaminated by noise produced by the multiplexer 
that is used to fit multiple temperature signals into a single slot of 
the PIB box. This noise is very specific to the BATMAN dataset and 
thus there is not a suitable default configuration of node `bss_regr` 
that is suitable to remove this kind of noise. After performing some 
tests (see [batman.preproc.mux_noise_test][mux_noise_test]) we came up with 
the following configuration that seems to work OK:

[mux_noise_test]: ./mux_noise_test.m

````matlab
% This is a data selector that will select only EEG data, and from that 
% only good data (i.e. will not select bad channels and bad data samples)
mySel = cascade(sensor_class('Class', 'EEG'), good_data);

% This criterion will rank components according to the ratio of power 
% in Band1 over power in Band2. It will then reject those components whose
% ratio is 4 MADs farther from the median ratio. It will also select any 
% component whose power ratio is greater than 50. At most (MaxCard) two 
% components will be selected by the criterion.
myCrit = spt.criterion.psd_ratio.new(...
    'Band1',    [12 16;49 51;17 19], ...
    'Band2',    [7 10], ...
    'MaxCard',  2, ...
    'Max',      @(x) min(median(x) + 4*mad(x), 50));

% We build a custom PCA object that will retain 99.5% of the data variance,
% with a minimum of 15 PCs and a maximum of 35 PCs
myPCA  = spt.pca.new(...
    'Var',          .995, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);

% We build a node that will use EFICA as BSS algorithm
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit, ...
    'PCA',              myPCA, ...
    'BSS',              efica.new, ...
    'Name',             'mux-noise', ...
    'IOReport',         report.plotter.io);

nodeList = [nodeList {myNode}];

````


### Node 5: `bss_regr.eog`

We remove ocular activity using the `eog` default configuration of the 
`bss_regr` node:

````matlab
myNode = bss_regr.eog('IOReport', report.plotter.io);
nodeList = [nodeList {myNode}];
````

## Build the pipeline

````matlab
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             'stage2' ...
    );
````


## Process the relevant data files


````matlab

regex = '_stage2\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);
% link2files works only under Mac OS X and Linux
link2files(files, OUTPUT_DIR);
regex = '_stage2\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});


````

