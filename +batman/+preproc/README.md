Preprocessing the BATMAN dataset
======

The pre-processing of the BATMAN dataset was organized into three stages, 
which are described below in detail.

## Stage 1

The first stage consisted in splitting whole-experiment `.mff` files into 
smaller and easier to handle single-block files. The splitting operation 
was complicated by errors and unexpected breaks during the experimental
protocol that led to missing events and other inconsistencies in the
 generated `.mff` files. 