batman
======

This repository contains the code and instructions necessary to reproduce
the data analyses of the [STW][stw]-funded project [BATMAN][batman]. The 
BATMAN project also involves several side projects, e.g. the `psvu` and 
`ontj` studies. 

In the documentation that follows we will assume a Linux-like OS, and that
the BATMAN dataset is managed by [somsds][somsds] data management system.
This is the case if you are trying to reproduce the data analyses at
the `somerengrid` (our lab's private computing grid).

The BATMAN project has three main experimental setups that produce very 
different datasets. Because of that the code in this repo is organized in
three relatively independent packages:

* The [+batman](./+batman/README.md) package contains all the code necessary
  to pre-process and extract features from the recordings acquired in the 
  main laboratory setup of the BATMAN project. Such a setup involves 
  simultaneous measurement of hdEEG, body temperature, ECG, respiration, 
  and alertness (via a reaction time task).

* The [+pupillator](./+pupillator/README.md) package contains all the code 
  necessary to pre-process and extract features from the recordings 
  acquired with the Wisse&Joris pupillator. 

* The [+ambulatory]() package will contain all the code necessary to 
  pre-process and extract features from the ambulatory recordings.

[somsds]: https://germangh.com/somsds
[batman]: http://www.slaapencognitie.nl/stwbatman
[stw]: http://www.stw.nl/en/
