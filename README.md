# EasyPlot.jl

## Description

The EasyPlot.jl provides a high-level abstraction to describe plots.  The interface is optimized to write tiny extraction routines for investigative (circuit) design work.

The goal of the EasyPlot interface is to let the user focus on analyzing simulation results (extracting relevant circuit performance) by *keeping the necessary plotting code to a strict minimum*.  Also, to keep things portable, EasyPlot plots can be rendered on different backends - provided by external modules.

That being said, the EasyPlot.jl module is generic and will likely help to simplify plotting tasks in many scientific fields.

Sample code to construct EasyPlot objects can be found [here](sample/)

## Known Limitations

 - EasyPlot mostly supports basic plot attributes at the moment.
 - Too much common functionnality is currently located in the rendering modules (EasyPlotGrace, EasyPlotMPL, EasyPlotQwt, ...).
  - Resultant color/glyph/linestyle/... are therefore not uniform across different backends.
  - Each rendering module requires custom support for different `T<:DataMD` types (`DataHR{Number}`, `DataHR{DataF1}`, `DataF1`, `DataTime`, `DataFreq`, ...).
  - Should consolidate more functionnality into EasyPlot.jl.

### Compatibility

Extensive compatibility testing of EasyPlot.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.0

## Disclaimer

The EasyPlot.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
