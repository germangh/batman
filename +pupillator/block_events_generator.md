`block_events_generator`
====

An events generator that generates block onset events based on the step changes
in one of the physiology channels recorded by the pupillator.

## Usage synopsis

````matlab
import physioset.import.edfplus;
import pupillator.block_events_generator;
data = import(edfplus, 'myfile.edf');
ev   = generate(block_events_generator, data);
add_event(data, ev);
````

## Construction

````matlab
obj = pupillator.block_events_generator('key', value, ...)
````

## Construction arguments


### `DiffFilter`

__Class__: `numeric vector`

__Default__: `[0.1 0 0 0 0 0 0 0 -0.1]`


The differentiating filter used to identify step changes in the
annotation channel.


### `DiffThreshold`

__Class__: `positive scalar`

__Default__: `0.05`

The threshold that will be applied to the output of the differentiting
filter to determine the onsets of each condition.


### `MinDuration`

__Class__: `natural scalar`

__Default__: `3000`

Minimum duration of each condition (in data samples).


### `Discard`

__Class__: `positive integer scalar`

__Default__: `1000`

The number of samples that should be ignored at the beginning of the
annotation channel. This parameter can be used to ignore transient
periods at the beginning of a recording where the annotation channel may
contain erroneous values.


### `NbBlocks`

__Class__: `natural scalar`

__Default__: `5`

Number of experimental blocks (light conditions).
