Preprocessing: Stage 1
===

The first processing stage splits whole-experiment `.mff` files into 
easier to handle single-block files. The splitting operation 
was complicated by errors and unexpected breaks during the experimental
protocol that led to some missing events in the
 generated `.mff` files. This is why the code necessary to produce the 
splitting is also more complex than one would expect.

The data splitting is implemented in script [batman.preproc.stage1][stage1].
To reproduce stage 1 simply run in MATLAB:

````matlab
batman.preproc.stage1
````

Some details of what is going on inside [batman.preproc.stage1][stage1] are
given below. 

[stage1]: ./+batman/+preproc/stage1.m

## Import directives

These are required in order to be able to use short names to refer to 
some of the `meegpipe`'s components that are used within `stage1.m`:

````matlab
import meegpipe.node.*;
import physioset.import.mff;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;
````

For instance, the first directive above will allow us write:

````matlab
% Create a processing node that removes the data mean
myNode = center.new
````

instead of writing the more verbose:

````matlab
myNode = meegpipe.node.center.new
````

## Analysis parameters

The first section of `stage1.m` defines several important analysis 
parameters


````matlab
% The set of subjects to be processed
SUBJECTS = 1:7;

% Should the processing jobs be submitted to the grid engine, if available?
USE_OGE = true;

% Should a data processing report (in HTML format) be generated?
DO_REPORT = true;

% This switch can be used to set the locations of the data depending on the 
% machine that you are using to perform the data processing
switch lower(get_hostname),

    case 'somerenserver',
        OUTPUT_DIR = '/data1/projects/batman/analysis/stage1';

    case 'nin271'
        OUTPUT_DIR = 'D:/batman';
        
    otherwise,
        % do nothing
        
end
```` 


## Build pipeline nodes


### Node 1: `physioset_import`

First we will need a processing node that will read the raw data from an 
`.mff` file and create a [physioset][physioset] object out of it. A 
[physioset][physioset] is the basic data structure used by the 
[meegpipe][meegpipe] toolbox.

[physioset]: https://github.com/germangh/matlab_physioset
[meegpipe]: https://github.com/germangh/meegpipe


````matlab
% Initialize the list of processing nodes
nodeList = {};

% This object is able to create a physioset from an .mff file
myImporter = mff('Precision', 'double');

% This node uses the provided importer to read a disk file and generate an 
% equivalent physioset object
myNode = physioset_import.new('Importer', mff);

% Add the node to the list of nodes
nodeList = [nodeList {myNode}];
````

### Node 2: `split`


The [split node][split] included in the `meegpipe` toolbox requires several 
parameters to understand how you want the splitting to be performed, and 
how the generated files should be named. The file naming policy is 
specified with the following [function handle][function_handle]:

[split]: https://github.com/germangh/meegpipe/blob/master/+meegpipe/+node/+split/README.md
[function_handle]: http://www.mathworks.nl/help/matlab/ref/function_handle.html

````matlab
namingPolicyRS = @(d, ev, idx) batman.preproc.naming_policy(d, ev, idx, 'rs');
````

The function handle above defines an inline function that takes three 
argument:

* `d`: the physioset object that contains the relevant data split
* `ev`: the event from the original (non-splitted) dataset that was used 
to produce the relevant data split
* `idx`: the index of the event `ev` within the list of all data-splitting 
events that were found in the raw dataset.

The output of function `namingPolicyRS` is a string with the name of the 
file that will contain the relevant data split. See 
[batman.preproc.naming_policy.m][naming_policy] for more details.

[naming_policy]: ./naming_policy.m

We also need to specify how the events that are present in the raw data 
file should be used to determine the onset and durations of the data splits.
This is done using an appropriate [event selector][ev_selector], that 
will select the first PVT stimulus event within each block. The actual 
implementation of such an event selector is in 
[batman.preproc.pvt_selector][pvt_selector]. Then, we are ready to define
our `split` node as follows:

````matlab
mySel       = batman.preproc.pvt_selector;

thisNode = split.new(...
    'EventSelector',        mySel, ...
    'Offset',               7*60, ...
    'Duration',             5*60, ...
    'SplitNamingPolicy',    namingPolicyRS);

nodeList = [nodeList {thisNode}];
````

The `Offset` and `Duration` arguments indicate that the data split should 
start 7 minutes after the occurrence of the first PVT stimulus, and should
have a duration of 5 minutes.

[pvt_selector]: ./pvt_selector.m
[ev_selector]: https://github.com/germangh/matlab_physioset/blob/master/+physioset/+event

## Build the pipeline

````matlab
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'stage1', ...
    'Queue',            'long.q@somerenserver.herseninstituut.knaw.nl');
````

The argument `Queue` is used to indicate the grid engine that the 
processing jobs should be sent to the `long.q` queue, which is especialized
in processing large jobs that require lots of memory and time to finalize.
Of course this only applies if you are running the processing at the 
`somerengrid`.


## Process the relevant data files


````matlab

switch lower(get_hostname),
    
    case 'somerenserver',
        
        % command lin2rec will use the somsds data management system to 
        % generate symbolic links to the relevant data files. The links 
        % will be placed within OUTPUT_DIR. The output of this command is 
        % a cell array with the names of all the generated symbolic links
        files = link2rec('batman', 'file_ext', '.mff', ...
            'subject', SUBJECTS, 'folder', OUTPUT_DIR);
        
    case 'nin271',
        
        % This applies to my windows PC. I leave it here so that you can 
        % see how you would run stage 1 without the help of somsds.  This 
        % assumes that the raw data files are under D:/data
        if numel(SUBJECTS) > 1, 
            subjList = join('|', SUBJECTS);
        else
            subjList = num2str(SUBJECTS);
        end
        regex = ['batman_0+(' subjList ')_eeg_all.*\.mff$'];
        files = regexpi_dir('D:/data', regex);
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});
````

