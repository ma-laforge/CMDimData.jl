# EasyPlot.jl

## Description

The EasyPlot.jl provides a high-level abstraction to describe plots.  The interface is optimized to write tiny extraction routines for investigative (circuit) design work.

The goal of the EasyPlot interface is to let the user focus on analyzing simulation results (extracting relevant circuit performance) by *keeping the necessary plotting code to a strict minimum*.  Also, to keep things portable, EasyPlot plots can be rendered on different backends - provided by external modules.

That being said, the EasyPlot.jl module is generic and will likely help to simplify plotting tasks in many scientific fields.

### Features/Highlights

 - Read/write plots to .hdf5 files using [EasyData.jl](https://github.com/ma-laforge/EasyData.jl).
 - Generate eye diagrams (even for backends without native support).
 - Plot multi-dimensional datasets (`T<:MDDatasets.DataMD`: `DataHR{Number}`, `DataHR{DataF1}`, `DataF1`).

## Sample Usage

Sample code to construct EasyPlot objects can be found [here](sample/).

## Known Limitations

 - EasyPlot.jl mostly supports x/y graphs & basic plot attributes at the moment.
 - Does not support `DataTime` or `DataFreq`.

### Compatibility

Extensive compatibility testing of EasyPlot.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.2

## Disclaimer

The EasyPlot.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
