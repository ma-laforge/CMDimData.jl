# EasyPlotInspect.jl

## Description

EasyPlotInspect.jl implements `EasyPlot.EasyPlotDisplay` using InspectDR.jl.

## Configuration

By default, EasyPlotInspect.jl renders inline plots with a data display area of x x y pixels??.  To specify a different value, set the `EASYPLOTINSPECT_RENDERW/H` environment variables **NOT YET IMPLEMENTED**.

The values of `EASYPLOTINSPECT_RENDERW/H` can therefore be set from `.juliarc.jl` with the following:

	ENV["EASYPLOTINSPECT_RENDERW"] = "300"
	ENV["EASYPLOTINSPECT_RENDERH"] = "200"

## Known Limitations

### Compatibility

Extensive compatibility testing of EasyPlotInspect.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-1.1.1

## Disclaimer

The EasyPlotInspect.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
