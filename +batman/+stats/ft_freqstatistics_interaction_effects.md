ft_freqstatistics_interaction_effects
====

Fieldtrip-based spectral power statistics, interaction effects

## Usage synopsis:

````matlab
import batman.stats.ft_freqstatistics_interaction_effects;
[out, effect] = ft_freqstatistics_interaction_effects;
[out, effect] = ft_freqstatistics_interaction_effects('key', value, ...)
````

Where `out` is a 1x6 cell array with the information related to the
statistics related to a given set of interaction effects. The latter are
listed in the output variable `effect`:

````matlab
effect = {'PxT_L', 'LxT_P', 'LxP_T', 'LxP', 'PxL', 'TxL'}
````

where `PxT_L` denotes the effect of light on the interaction between 
posture and temperature, and `PxL` denotes the interaction effect of
posture and temperature.

## Optional arguments

Optional arguments can be provided as key/value pairs.

### `SaveToFile`

__Default:__
`/data1/projects/batman/analysis/cluster_stats_interaction_effects.mat`

__Class:__ 'char array'

The full path to the `.mat` file where the structures produced by
Fieldtrip's [ft_freqstatistics][ft_freqstatistics] and related
meta-information will be stored. This file contains everything that 
[batman.stats.ft_cluterplot][ft_clusterplot] needs to plot the
topographies of significant clusters of EEG sensors. 

[ft_freqstatistics]: http://fieldtrip.fcdonders.nl/reference/ft_freqstatistics
[ft_clusterplot]: ./ft_clusterplot.md


### `Bands`

__Default:__ `batman.eeg_bands`

__Class:__ `mjava.hash`

An [associative array][wiki-aarray] array that maps spectral band names
to their actual definition in terms of spectral boundaries (in Hz). To
retrieve the default definition for the alpha band:

````matlab
myBands = batman.eeg_bands;
myBands('alpha')
````

which will display `[8 13]` as being the start and end frequencies of the
`alpha` band. To run `ft_freqstatistics_main_effects` with an alternative
definition of `alpha` (and to run it __only__ for the alpha band) you
could do:

````matlab
myBands = mjava.hash;
myBands('alpha') = [9 12];
batman.stats.ft_freqstatistics_main_effects('Bands', myBands);
````

[wiki-aarray]: http://en.wikipedia.org/wiki/Associative_array

### `RerefMatrix`

__Default:__ `meegpipe.node.reref.avg_matrix`

__Class:__ `numeric` matrix or `function_handle` or `[]`

The re-referencing matrix. Leave empty if no re-referencing should be 
performed.

## More information

See the [source code][source] for more information.

[source]: ./ft_freqstatistics_interaction_effects.m