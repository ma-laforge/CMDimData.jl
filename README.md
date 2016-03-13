# EasyPlotMPL.jl

## Description

EasyPlotMPL.jl implements `EasyPlot.EasyPlotDisplay` using Matplotlib (PyPlot.jl).

## Configuration

### Defaults

To specify the default Matplotlib/PyPlot backend (i.e. GUI toolkit), add the following to your `.juliarc.jl` file:

	ENV["EASYPLOTMPL_DEFAULTBACKEND"] = "gtk"

See main [PyPlot.jl](https://github.com/stevengj/PyPlot.jl) module for supported backends.

### Compatibility

Extensive compatibility testing of EasyPlotMPL.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.2

## Disclaimer

The EasyPlotMPL.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
