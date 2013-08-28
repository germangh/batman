Preprocessing: Stage 4
===

The last pre-processing stage consisted in the following steps:

* Removal of cardiac artifacts

* Removal of (obvious) EOG artifacts using their topography

* Removal of less obvious EOG and other noise components with low-frequency 
  characteristics.

Stage 4 is implemented in script [batman.preproc.stage4][stage4]. Thus, to
reproduce stage 4 simply run in MATLAB:

[stage2]: ./stage4.m

````matlab
batman.setup;
batman.preproc.stage4;
````

For the command above to work you should have completed 
successfully [stage 3][stage3-doc] of the pre-processing chain.

[stage3-doc]: ./stage3.md

Below you can find a detailed description of what is going on inside 
[stage4.m][stage4].

[stage3]: ./+batman/+preproc/stage3.m


## Analysis parameters

The first section of `meegpipe.preproc.stage3` defines several important
 processing parameters. You may have to edit the locations of the
results directories produced by [stage 2][stage2].


````matlab
PIPE_NAME = 'stage4';

USE_OGE = true;

DO_REPORT = true;

INPUT_DIR = '/data1/projects/batman/analysis/stage3_gherrero_130823-175358';
OUTPUT_DIR = ['/data1/projects/batman/analysis/stage4_', get_username '_' ...
    datestr(now, 'yymmdd-HHMMSS')];

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';

```` 

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


## Build pipeline nodes


### Node 1: `physioset_import`

````matlab
nodeList = {};
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];
````

### Node 2: `copy`

We introduce a `copy` node in the pipeline in order to generate independent 
copies of the `physioset` objects that were produced during stage 2:

````matlab
myNode = copy.new;
nodeList = [nodeList {myNode}];
````

### Node 3: `bss_regr.ecg`

This node will attempt to identify cardiac components and will reject them 
from the data. The node is built using the `ecg` configuration of the 
[bss_regr][bss_regr] node. 

````matlab
myNode = bss_regr.ecg;
nodeList = [nodeList {myNode}];
````

### Node 4: `bss_regr.eog`

We use the `eog` configuration of the `bss_regr` node to identify and 
reject ocular components. However, the default `eog` configuration uses 
a criterion based on the spectra of the estimated spatial components to 
identify ocular components. Such a criterion works generally well and is 
independent of the spatial arrangement of the EEG sensors. But if
we know the coordinates of each sensor and we know in which sensors ocular
activity is most prominent then it is usually a good idea to try to reject
the most obvious ocular components using such a-priori knowledge regarding
their topographies. 

Criterion `topo_ratio` implements this rationale and lets you define a set
 of sensors where you expect ocular activity to be most prominent, and an
alternative set of sensors where ocular activity is expected to be much 
weaker. For the EGI's HCGSN v1.0 net with 256 sensors, there is a 
pre-defined configuration that uses a `topo_ratio` criterion with suitable 
selections for these two sets of channels:

````matlab
myNode = bss_regr.eog_egi256_hcgsn1('MinCard', 2, 'MaxCard', 5);
nodeList = [nodeList {myNode}];
````

If you want to learn the specifics of how this node is defined, type in 
MATLAB:

````matlab
edit bss_regr.eog_egi256_hcgsn1
````


### Node 5: `bss_regr.eog`

The BATMAN dataset contains a large number of noisy components with 
low-frequency characteristics, but without characteristic topographies. 
Some of these, but definitely not all, are of ocular origin. To minimize
the effects of these noisy sources we reject components that have 
spectral characteristics similar to those of EOG sources:

````matlab
myCrit = spt.criterion.mrank.eog(...
    'MaxCard', 5, ...
    'MinCard', 1, ...
    'Max',     0.9, ...
    'Percentile', 90);
myNode = bss_regr.eog('Criterion', myCrit, 'Name', 'low-freq-noise');
nodeList = [nodeList {myNode}];
````

Criterion `spt.criterion.mrank.eog` combines two criteria that are 
directly or indirectly related with the spectral properties of the 
time-series under assessment. Slowly-varying components with 
abnormally "simple" temporal activations tend to be ranked highly by this
criterion.


###  Node 6: `chan_interp`

We interpolate the activity patters of channels that were marked as bad 
in order to ensure that spectral features can be extracted reliably from
any channel, and not only from the good channels.

````matlab
myNode = chan_interp.new;
nodeList = [nodeList {myNode}];
````

### Build the pipeline

````matlab
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             PIPE_NAME ...
    );
````

## Process the relevant data files


````matlab

% Halt execution until there are no jobs running from stage3. Otherwise
% we may miss some links in the output directory of stage4.
oge.wait_for_grid('stage3');

regex = '_stage3\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
regex = '_stage3\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});


````

