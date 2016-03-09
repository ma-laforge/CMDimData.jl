# EasyPlotPlots.jl

## Description

EasyPlotPlots.jl implements multiple [EasyPlot](https://github.com/ma-laforge/EasyPlot.jl) backends using [Plots.jl](https://github.com/tbreloff/Plots.jl).

### Supported Backends
 - **:Plots\_MPL**: Through Plots.jl/[PyPlot.jl](https://github.com/stevengj/PyPlot.jl) (Matplotlib) libraries.
 - **:Plots\_Gadfly**: Through Plots.jl/[Gadfly.jl](https://github.com/dcjones/Gadfly.jl) libraries.
 - **:Plots\_Bokeh**: Through Plots.jl/[Bokeh.jl](https://github.com/bokeh/Bokeh.jl) libraries.
 - **:Plots\_Qwt**: Through Plots.jl/[Qwt.jl](https://github.com/tbreloff/Qwt.jl) libraries.
 - **:Plots\_GR**: Through Plots.jl/[GR.jl](https://github.com/jheinen/GR.jl) libraries.

## Known Limitations

EasyPlotPlots.jl will *not* auto-install "backend" modules.  The `REQUIRES` file only registers the main Plots.jl module for installation.

It appears the different backends do not all operate seamlessly.  Unsurprisingly, there appears to be varying levels of difficulty in getting the backends installed \& working properly.

Consequently, not all backends have been fully tested (if at all).  Please visit corresponding websites (above) for help installing the core libraries used as backends.

### Compatibility

Extensive compatibility testing of EasyPlotPlots.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.0

## Disclaimer

The EasyPlotPlots.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
