Preprocessing the BATMAN dataset
======

The pre-processing of the BATMAN dataset was organized into three stages, 
which are described in detail below.

## Stage 1

The first stage consisted in splitting whole-experiment `.mff` files into 
smaller and easier to handle single-block files. The splitting operation 
was complicated by errors and unexpected breaks during the experimental
protocol that led to missing events and other inconsistencies in the
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

### Import directives

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

### Analysis parameters

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
        
    otherwise,
        % do nothing
        
end
```` 


### Build the pipeline node by node

First we will need a processing node that will read the raw data from an 
`.mff` file and create a [physioset][physioset] object out of it. A 
[physioset][physioset] is the basic data structure used by the 
[meegpipe][meegpipe] toolbox.

[physioset]: https://github.com/germangh/matlab_physioset
[meegpipe]: https://github.com/germangh/meegpipe


__Node 1: physioset_import__

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

__Node 2: split__


The [split node][split] included in the `meegpipe` toolbox requires several 
parameters to understand how you want the splitting to be performed, and 
how the generated files should be named. The file naming policy is 
specified with the following [function handle][function_handle]:

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