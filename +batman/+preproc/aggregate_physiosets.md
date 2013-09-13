aggregate_physiosets
====

Aggregates physiosets according to experimental conditions

## Usage synopsis

````matlab
import batman.preproc.aggregate_physiosets;
[physArray, condIDs, condNames] = aggregate_physiosets('key', value, ...)
````

Where

`physArray` is a 2x2x2 cell array. Each cell corresponds to a given 
experimental condition and contains all data `.pseth` files that are 
associated with that condition.

`condIDs` is a 2x2x2 cell array with condition IDs (strings).

`condNames` is a 2x2x2 cell array with condition names (strings).


## Optional key/value arguments

### `Subjects`

__Class:__ `numeric` array

__Default:__ `[1,2,3,4,7,9,10]`

The numeric IDs of the subjects that should be considered for the 
aggregation.


### `DataPath`

__Class:__ `char` array

__Default:__ `'/data1/projects/batman/analysis/cleaning'`

The root path where the relevant `.pseth` files can be found.

