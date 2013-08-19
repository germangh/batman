Preprocessing the BATMAN dataset
======

The pre-processing of the BATMAN dataset was organized into three stages, 
which are described in detail below.

## Stage 1

The first stage consisted in splitting whole-experiment `.mff` files into 
smaller and easier to handle single-block files. The splitting operation 
was complicated by errors and unexpected breaks during the experimental
protocol that led to missing events and other inconsistencies in the
 generated `.mff` files. 

The data splitting is implemented in script [batman.preproc.stage1][stage1].
To reproduce stage 1 simply run in MATLAB:

````matlab
batman.preproc.stage1
````

Some details of what is going on inside [batman.preproc.stage1][stage1] are
given below. 


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
DO_REPORT = false;

% This switch can be used to set the locations of the data depending on the 
% machine that you are using to perform the data processing
switch lower(get_hostname),

    case 'somerenserver',
        OUTPUT_DIR = '/data1/projects/batman/analysis/stage1';
        
    otherwise,
        % do nothing
        
end
```` 

[stage1]: ./+batman/+preproc/stage1.m