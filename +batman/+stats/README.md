Statistical Analysis
===

Note that the description below assumes that [meegpipe][meegpipe] has been
installed and succesfully initialized using:

[meegpipe]: http://germangh.com/meegpipe

````matlab
meegpipe.initialize
`````

## Resting state power features

The effects of the experimental manipulations on EEG power spectra were
assessed using [Fieldtrip][ftrip]. The outcome of this assessment were
topographies showing clusters of EEG sensors were the effects were significant
(at the `p<0.05` level). The whole analysis can be reproduced running the code
snippet below:

````matlab
import batman.stats;

% Statistics for main effects
ft_freqstatistics_main_effects
% Statistics for interaction effects
ft_freqstatistics_interaction_effects

% Plot topographies and significant clusters of EEG sensors
ft_clusterplot
````

[ftrip]: http://fieldtrip.fcdonders.nl/


### Main effects

The main effects of light, posture and temperature on resting state
[power features][power_features] was assessed using a dependent samples
T-statistic, as computed internally in Fieldtrips's
[ft_statistics_montecarlo][ft_statistics_montecarlo]. The subjects variable was
used as _unit of observation_ variable, as understood by Fieldtrip's
[ft_freqstatistics][ft_freqstatistics]. See the code of
[ft_freqstatistics_main_effects][ft_freqstatistics_main_effects] for more
details.

[ft_freqstatistics]:  http://fieldtrip.fcdonders.nl/walkthrough#paired_comparison
[power_features]: ../+features/README.md
[ft_freqstatistics_main_effects]: ./ft_freqstatistics_main_effects.md
[ft_statistics_montecarlo]: http://fieldtrip.fcdonders.nl/reference/ft_statistics_montecarlo


### Interaction effects

Interaction effects between two independent variables (say, light and
temperature) were assesed by:

1. Computing the average effect of light across postures for the first.
   temperature level.

2. Computing the average effect of light across postures for the second
   temperature level.

3. Assessing the difference between 1. and 2 using a dependent samples T test.


Interaction effects between three independent variables were assesed by
assessing differences in two-way interactions across level of the third
variable. That is, to assess the interaction effect of light, posture and
temperature:

1. We computed the difference in the effect of posture across light levels for
   the first temperature level.

2. We computed the difference in the effect of posture across light levels for
   the second temperature level.

3. We assessed the difference between 1. and 2. using a dependent samples
   T test.


See the code of [ft_freqstatistics_interaction_effects][inteff] for more
details.

[inteff]: ./ft_freqstatistics_interaction_effects.md

