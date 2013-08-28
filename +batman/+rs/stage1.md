Resting state analysis: Stage 1
===

The first stage of the resting state analysis consists in extracting 
several spectral features from the files produced by 
[batman.preproc.stage4][preproc-stage4].

[preproc-stage4]: ../+preproc/stage4.md


## Analysis parameters



````matlab
PIPE_NAME = 'rs-stage1';

USE_OGE = true;

DO_REPORT = true;

INPUT_DIR = '/data1/projects/batman/analysis/stage4_gherrero_130827-151810';
OUTPUT_DIR = ['/data1/projects/batman/analysis/' PIPE_NAME '_', ...
    get_username '_' datestr(now, 'yymmdd-HHMMSS')];

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';

```` 


## Import directives

These are required in order to be able to use short names to refer to 
some of the `meegpipe`'s components that are used within `stage1.m`:

````matlab
meegpipe.initialize;

import batman.*;
import meegpipe.node.*;
import somsds.link2files;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
````


## Build pipeline nodes


### Node 1: `physioset_import`

````matlab
nodeList = {};
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];
````

### Node 2: `spectra`

The [spectra node][spectra-node] computes spectral features from one or 
more user-defined _channel sets_. A _channel set_ may be a single 
channel or may consists of multiple channels. When a channel set contains 
more than one channel, the spectral features will be extracted from the 
average spectra produced by aggregating the spectra of the channels within
the channel set.

By default, the `spectra` node defines one plus the number of EEG channels 
in the input physioset. There is a channel set for each EEG channel and 
there is a channel set that contains all EEG channels. That means that 
the spectral features will be computed for the spectra of individual 
channels and for the average (across all channels) spectra. To learn more
see the documentation of the [spectra node][spectra-node].

Apart from computing spectral features, the `spectra` node can also plot 
the spectra (and the extracted features) for a user-defined set of 
channel sets. For instance, the node that we define below specifies that 
the spectra should be plotted for 9 individual EEG channels and for the
 result of aggregating the spectra across all EEG channels. 

[spectra-node]: https://github.com/germangh/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bspectra/README.md

````matlab
myNode = spectra.new(...
    'Channels2Plot', ...
    {...
    '^EEG 69$',  '^EEG 202$', '^EEG 95$', ... % T3, T4, T5
    '^EEG 124$', '^EEG 149$', '^EEG 137$', ... % O1, O2, Oz
    '^EEG 41$',  '^EEG 214$', '^EEG 47$', ... % F3, F4, Fz
    '.+' ...
    }, 'Name', 'power-ratios' ...
    );

nodeList = [nodeList {myNode}];
````

### Node 3: `spectra`

The default spectral features produced by the `spectra` node are power 
ratios. See the documentation of the [spectra node][spectra-node] for 
details.

In order to extract raw power values in specific bands we need to modify 
the default configuration of the `spectra` node. The relevant configuration
property is the `ROI` property. By default, the value of such a property is
set to the following _hash_ object:

````matlab
defROIs = spectra.eeg_bands

defROIs =

	mjava.hash with 5 keys

	key(value): gamma(1x2 cell), theta(1x2 cell), beta(1x2 cell), alpha(1x2 cell), delta(1x2 cell)
````

You can query the names of the default spectral features using:

````matlab
spectralFeatNames = keys(defROIs)

spectralFeatNames = 

    'gamma'    'theta'    'beta'    'alpha'    'delta'
````

And you can query the specific definition of the `alpha` feature using:

````matlab
alphaDef = defROIs('alpha')
````

The definition of a spectral feature is given by a `1x2` cell array. The 
first element of the cell array defines the _target band_ (i.e. the band 
whose power will be at the numerator of the power ratio). The second 
cell array element defines the _reference band_, i.e. the band whose power
will be placed at the denominator of the power ratio. See:

````matlab
>> alphaDef{1}

ans =

     8
    13

>> alphaDef{2}

ans =

     0
   100
````

which clearly shows that the `alpha` feature is defined as the ratio 
of power in the band from 8 to 13 Hz over the power in the band from 
0 to 100 Hz. 

An empty _reference band_ can be used to indicate that the `spectra` node
should produce raw power values instead of power ratios. Thus, the 
following code snippet will create a `spectra` node that computes the raw
power in the standard EEG bands:

````matlab
myROIs = spectra.eeg_bands;

% We modify the default spectral features so that they become raw power
% values instead of power ratios
bandNames = keys(myROIs);
for bandItr = 1:numel(bandNames)
    % The current feature specfication: {targetBand;refBand}
    this = myROIs(bandNames{bandItr});
    % Make the refBand empty, which means: return raw power in targetBand
    this{2} = [];
    myROIs(bandNames{bandItr}) = this;
end

myNode = spectra.new(...
    'Channels2Plot', ...
    {...
    '^EEG 69$',  '^EEG 202$', '^EEG 95$', ... % T3, T4, T5
    '^EEG 124$', '^EEG 149$', '^EEG 137$', ... % O1, O2, Oz
    '^EEG 41$',  '^EEG 214$', '^EEG 47$', ... % F3, F4, Fz
    '.+' ...
    }, ...
    'ROI', myROIs, 'Name', 'raw-power' ...
    );
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
