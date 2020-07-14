# CMDimData.jl

[![Build Status](https://travis-ci.org/ma-laforge/CMDimData.jl.svg?branch=master)](https://travis-ci.org/ma-laforge/CMDimData.jl)

## Description

The CMDimData.jl provides a high-level abstraction to manipulate multi-dimensional data, and automatically interpolate intermediate values as if it was a continuous function.

TODO: Merge in [MDDatasets.jl](https://github.com/ma-laforge/MDDatasets.jl), and copy description here.

### Features/Highlights

 - Read/write plots to .hdf5 files using [EasyData.jl](https://github.com/ma-laforge/EasyData.jl).
 - [Plotting:](doc/plotting.md) Plot multi-dimensional datasets (`T<:MDDatasets.DataMD`: `DataHR{Number}`, `DataHR{DataF1}`, `DataF1`).
   - Support for multiple [backends](doc/backends.md)
   - Generate eye diagrams (even for backends without native support).

## Known Limitations

[TODO](TODO.md)

### Compatibility

Extensive compatibility testing of CMDimData.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-1.3.1

## Disclaimer

The CMDimData.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
