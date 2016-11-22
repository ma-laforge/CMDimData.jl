# EasyPlotGrace.jl

## Description

EasyPlotGrace.jl implements `EasyPlot.EasyPlotDisplay` using Grace/xmgrace (GracePlot.jl).

## Configuration

By default, EasyPlotGrace.jl renders inline plots at 75 dpi.  To specify a different value, set the `EASYPLOTGRACE_RENDERDPI` environment variable.

The value of `EASYPLOTGRACE_RENDERDPI` can therefore be set from `.juliarc.jl` with the following:

	ENV["EASYPLOTGRACE_RENDERDPI"] = "200"

## Known Limitations

### Compatibility

Extensive compatibility testing of EasyPlotGrace.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.5.0

## Disclaimer

The EasyPlotGrace.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
