# EasyPlotPlots.jl

## Description

EasyPlotPlots.jl implements `EasyPlot.EasyPlotDisplay` using [Plots.jl](https://github.com/tbreloff/Plots.jl).

### Supported Displays
EasyPlotPlots.jl tries to support all plot rendering tools (backends) supported by Plots.jl itself.  A few tested backends are listed below:

 - **:pyplot**: Through Plots.jl/[PyPlot.jl](https://github.com/stevengj/PyPlot.jl) (Matplotlib) libraries.
 - **:gadfly**: Through Plots.jl/[Gadfly.jl](https://github.com/dcjones/Gadfly.jl) libraries.
 - **:gr**: Through Plots.jl/[GR.jl](https://github.com/jheinen/GR.jl) libraries.

## Sample Usage

The following returns a `T<:Display` object that can render `EasyPlot.Plot` objects:

	pdisp = EasyPlotPlots.PlotDisplay(:pyplot)

A `plot::EasyPlot.Plot` object is therefore diplayed using:

	display(pdisp, plot)

More sample code can be found [here](sample/).

## Configuration

### Defaults

To specify the default Plots.jl plot rendering tool, add the following to your `.juliarc.jl` file:

	ENV["EASYPLOTPLOTS_RENDERINGTOOL"] = "gr"

See main [Plots.jl](https://github.com/tbreloff/Plots.jl) module for supported backends.

## Known Limitations

EasyPlotPlots.jl will *not* auto-install "backend" modules.  The `REQUIRES` file only registers the main Plots.jl module for installation.

It appears the different backends do not all operate seamlessly.  Unsurprisingly, there appears to be varying levels of difficulty in getting the backends installed \& working properly.

Consequently, not all backends have been fully tested (if at all).  Please visit corresponding websites (above) for help installing the core libraries used as backends.

### Compatibility

Extensive compatibility testing of EasyPlotPlots.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.2

## Disclaimer

The EasyPlotPlots.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
