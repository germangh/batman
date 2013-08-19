Preprocessing: Stage 2
===

The second pre-processing stage consisted in the following steps:

* Remove extremely large signal fluctuations using a [LASIP filter][lasip].

* Bad channel rejection

* Bad sample rejection

* Band-pass filtering between 0.5 and 70 Hz

[lasip]: http://www.cs.tut.fi/~lasip/

Stage 2 is implemented in script [batman.preproc.stage2][stage2]. Thus, to
reproduce stage 2 simply run in MATLAB:

[stage2]: ./stage2.m

````matlab
batman.preproc.stage2
````

Of course, for the command above to work you should have completed 
successfully [stage 1][stage1-doc] of the pre-processing chain.

[stage1-doc]: ./stage1.md
[stage1]: ./+batman/+preproc/stage1.m

Below you can find a detailed description of what is going on inside 
[stage2.m][stage2].


## Import directives

These are required in order to be able to use short names to refer to 
some of the `meegpipe`'s components that are used within `stage1.m`:

````matlab
meegpipe.initialize; % required only once per MATLAB session

import meegpipe.node.*;

% Some basic file and string manipulation utilities
import somsds.link2files;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

% Some data selectors that we will use later
import pset.selector.good_data;
import pset.selector.sensor_class;
import pset.selector.cascade;
````


## Analysis parameters

The first section of `stage1.m` defines several important analysis 
parameters


````matlab
SUBJECTS = 6;%1:7;

CONDITIONS = {'rs'};

BLOCKS = 1:5;%1:14;

USE_OGE = true;

DO_REPORT = true;

switch lower(get_hostname)
    case 'somerenserver'
        ROOT_DIR = '/data1/projects/batman/analysis';
        INPUT_DIR = catdir(ROOT_DIR, 'stage1');
 
    otherwise,
        error('The location of the batman dataset is not known');
        
end

OUTPUT_DIR = catdir(ROOT_DIR, 'stage2');
```` 


## Build pipeline nodes

The first node of the pipeline will read the single-block files generated 
during [stage 1][stage1-doc] and create a corresponding 
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
% of the files that were generated during stage 1.
myImporter = physioset.import.physioset('Precision', 'double');

% We use the importer object above to build a processing node that reads 
% pset/pseth files and produces an equivalent physioset object
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];
````

### Node 2: `copy`

This is a very important, but easy to forget step when using `meegpipe` to 
process a dataset in multiple stages. Stage 1 of the pre-processing chain
generated a set of native `pset/pseth` files that contain a binary 
representation of the `physioset` object produced by the pipeline used in
stage 1. The `physioset_import` node that we built above will simply load
 the `physioset` objects that are contained in those files. 

Recall that `physioset` objects loaded in MATLAB's workspace are just 
references to an underlying `.pset` file. Thus, if we do not implicitely 
copy the `physioset` object produced by the `physioset_import` node the 
following nodes of the pipeline will directly operate on the output files
produced by stage 1. This implies that if you run `batman.preproc.stage2` 
__the output of stage 1 will be modified__. 

We introduce a `copy` node in the pipeline in order to generate independent 
copies of the `physioset` objects that were produced during stage 1:

````matlab
myNode = copy.new;
nodeList = [nodeList {myNode}];
````

### Node 3: LASIP `tfilter`

This node implements the LASIP filtering step that we mentioned at the
beginning of this document:

````matlab
% setting the "right" parameters of the LASIP filter may involve quite a
% bit of trial and error...
myScales =  [20, 29, 42, 60, 87, 100, 126, 140, 182, 215, 264, 310, 382];

myFilter = filter.lasip(...
    'Decimation',       12, ...
    'GetNoise',         true, ... % Retrieve the filtering residuals
    'Gamma',            15, ...
    'Scales',           myScales, ...
    'WindowType',       {'Gaussian'}, ...
    'VarTh',            0.1);

% This selector object will restrict the processing to the EEG data
mySelector = pset.selector.sensor_class('Class', 'EEG');

myNode = tfilter.new(...
    'Filter',           myFilter, ...
    'Name',             'lasip', ...
    'DataSelector',     mySelector, ...
    'ShowDiffReport',   true ... % Just tuning the looks of the HTML report
    );

nodeList = [nodeList {myNode}];
````

### Node 4: `bad_channels`

The [bad_channels node][bad_channels] can use various criteria to identify
 bad channels. In this case, we use a criterion that will reject channels 
whose variance is below or above certain threshold. The actual thresholds 
are especified as [function handles][function_handle] that take as argument
a vector with the channel variances (in logarithmic scale).

[bad_channels]: https://github.com/germangh/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bbad_channels/README.md
[function_handle]: http://www.mathworks.nl/help/matlab/ref/function_handle.html

````matlab
minVal = @(x) median(x) - 20;
maxVal = @(x) median(x) + 15;
myCrit = bad_channels.criterion.var.new('Min', minVal, 'Max', maxVal);
myNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];
````

### Node 5: `bad_samples`

````matlab
myNode = bad_samples.new(...
    'MADs',         5, ...
    'WindowLength', @(fs) fs/4, ...
    'MinDuration',  @(fs) round(fs/4));
nodeList = [nodeList {myNode}];
````

### Node 6: band-pass `tfilter`

````matlab
myFilter    = @(sr) filter.bpfilt('fp', [0.5 70]/(sr/2));

mySelector  = cascade(...
    sensor_class('Class', 'EEG'), ...
    good_data ...
    );

myNode  = tfilter.new(...
    'Filter',       myFilter, ...
    'DataSelector', mySelector, ...
    'IOReport',     report.plotter.io);

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

switch lower(get_hostname),
    case 'somerenserver',
        % A regular expression that matches any file that ends with an 
        % underscore and one ore more digits, and has an extension equal to
        % .pset/.pseth
        regex = '_\d+\.pseth?$';

        % files is a cell array with the full path names of all the files
        % generated during stage 1
        files = finddepth_regex_match(INPUT_DIR, regex);

        % Create symbolic links to files generated in stage 1
        link2files(files, OUTPUT_DIR);

        % Now create a cell array with the full path names of all the 
        % pseth files, as those are what the physioset_import node is 
        % expecting
        regex = '_\d+\.pseth$';
        files = finddepth_regex_match(OUTPUT_DIR, regex);
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});

````

