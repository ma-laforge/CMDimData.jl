# CMDimData.jl: Parametric Analysis +Plotting +Continuous <math>f(x)</math>

 - ***"Focus the analysis itself, not how to manipulate data"***
 - ***"The hardest part of data analysis should be annotating the plots!"***

[![Build Status](https://travis-ci.org/ma-laforge/CMDimData.jl.svg?branch=master)](https://travis-ci.org/ma-laforge/CMDimData.jl)

## Description

CMDimData.jl provides a high-level abstraction to manipulate multi-dimensional data, and automatically interpolate intermediate values as if it was a continuous function.

The goal is to provide analysis tools that lead to minimal code, written in a *natural*, and *readable* fashion.

### Features/Highlights

 1. Seamlessly handle multi-dimensional datasets with [MDDatasets.jl](https://github.com/ma-laforge/MDDatasets.jl)
    - Perform the same operation on all elements (usually) without having to write explicit loops.
    - Results of data reductions (ex: `minimum()`, integrations, ...) are handled the same as any other data.
 1. Easily plot multi-dimensional results with [`EasyPlot` module](doc/EasyPlot.md).
    - Quickly organize and plot the results in a way that sheds light on the studied phenomenon.
    - Support for multiple [backends](doc/EasyPlot_backends.md)
    - Generate eye diagrams (even for backends without native support).
 1. Read/write plots to HDF5 files with [`EasyData` module](doc/EasyData.md).

## Table of Contents

 1. [`CMDimData.EasyPlot` Plotting Interface](doc/EasyPlot.md)
    1. [`CMDimData.EasyPlot` Backends](doc/EasyPlot_backends.md)
 1. [`CMDimData.EasyData` {Data/Plot} &hArr; HDF5 file](doc/EasyData.md)
 1. [Installation](#Installation)
 1. [Known Limitations](#KnownLimitations)

<a name="Installation"></a>
## Installation

CMDimData.jl is registered with Julia's **General** registry. It can be installed using Julia's built-in package manager:
```
]add CMDimData
```

<a name="KnownLimitations"></a>
## Known Limitations

### [TODO](TODO.md)

### Compatibility

Extensive compatibility testing of CMDimData.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-1.3.1

## Disclaimer

The CMDimData.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
