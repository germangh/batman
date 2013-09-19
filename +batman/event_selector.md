cel_selector
===

This event selector can be used to select, among others, the following sets
 of events:

* All standard stimuli

* All deviant stimuli

* All standard stimuli followed by correct responses

* All deviant stimuli followed by correct responses



## Usage synopsis:

````
mySel = ssmd_auob.cel_selector('key', value, ...)
selEv = select(mySel, evArray)
````

Where

`evArray` is an array of event objects.

`selEv` is a subset of `evArray`


## Accepted key/value pairs:

### `StimType`

__Default:__ `stm+`

__Class:__    `char` array

The type of the events that mark the stimuli onsets.


### `RespType`

__Default:__ `RESP`

__Class:__ `char` array

The type of the events that mark the subject's responses.


### `TimingType`

__Default:__ `DIN `

__Class:__ `char` array

The type of the events associated with the `StimType` events that are
used to provide an accurate timing of the the stimulus presentation
onset. Properties `Sample` and `Time` of the extracted `StimType`
events will be modified to match those of the associated
`TimingType` event.


### `StimCel`

__Default:__ `[]`

__Class:__ `numeric`

Select only those `StimType` events whose `cel` property is equal to
`StimCel`. If no `StimCel` is provided, then the value of the `cel`
property will be ignored for event selection purposes.


### `RespValue`

__Default:__ `[]`

__Class:__ `numeric`

Select only those `StimType` events whose associated `RespType` event
has a `rsp` meta-property equal to `RespValue`. Use `[]` to ignore the value
of the `RespType` event's `rsp` property when selecting events.


### `Negated`

__Default:__ `false`

__Class:__ `logical`

If set to true, the event selector will negate its typical behavior
and select all those events that would not be normally selected.



See also: ssmd_auob
