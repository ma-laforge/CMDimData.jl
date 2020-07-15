# `CMDimData.EasyPlot` Backends

<a name="SupportedBackends"></a>
## Supported Backends

The following is a list of modules implementing the `EasyPlot` interface, along with their corresponding plotting backends:

 - `EasyPlotInspect`: (InspectDR.jl)
 - `EasyPlotMPL`: (PyPlot.jl/Matplotlib)
 - BROKEN `EasyPlotPlots`: (Plots.jl)
 - BROKEN `EasyPlotQwt`: (Qwt.jl)
 - `EasyPlotGrace`: (GracePlot.jl)

## Importing Backends

Before importing any backend, `CMDimData.EasyPlot` must already be imported.

To import a specific interface module for a given plotting backend, as listed in [Supported Backends](#SupportedBackends), you must use the `@includepkg macro`:

	#Import base CMDimData/EasyPlot facilities
	using CMDimData
	using CMDimData.EasyPlot

	#Import a specific EasyPlot interface, and its associated backend module:
	CMDimData.@includepkg EasyPlotInspect #To render plots with InspectDR

	#Now ready to create `EasyPlotInspect.PlotDisplay()` objects to render plots.

## Configuring Backends

### EasyPlotInspect

By default, `EasyPlotInspect` renders inline plots with a data display area of x x y pixels??.  To specify a different value, set the `EASYPLOTINSPECT_RENDERW/H` environment variables **NOT YET IMPLEMENTED**.

The values of `EASYPLOTINSPECT_RENDERW/H` can therefore be set from `.juliarc.jl` with the following:

	ENV["EASYPLOTINSPECT_RENDERW"] = "300"
	ENV["EASYPLOTINSPECT_RENDERH"] = "200"

### EasyPlotMPL

To specify the default Matplotlib/PyPlot backend (i.e. GUI toolkit), add the following to your `.juliarc.jl` file:

	ENV["EASYPLOTMPL_DEFAULTBACKEND"] = "gtk"

See main [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl) module for supported backends.

### EasyPlotPlots

To specify the default Plots.jl plot rendering tool, add the following to your `.juliarc.jl` file:

	ENV["EASYPLOTPLOTS_RENDERINGTOOL"] = "gr"

See main [Plots.jl](https://github.com/tbreloff/Plots.jl) module for supported backends.

### EasyPlotQwt

### EasyPlotGrace

By default, `EasyPlotGrace` renders inline plots at 75 dpi.  To specify a different value, set the `EASYPLOTGRACE_RENDERDPI` environment variable:

The value of `EASYPLOTGRACE_RENDERDPI` can therefore be set from `.juliarc.jl` with the following:

	ENV["EASYPLOTGRACE_RENDERDPI"] = "200"

## Additional Information: EasyPlotPlots

### Supported Displays
EasyPlotPlots.jl tries to support all plot rendering tools (backends) supported by Plots.jl itself.  A few tested backends are listed below:

 - **:pyplot**: Through Plots.jl/[PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl) (Matplotlib) libraries.
 - **:gadfly**: Through Plots.jl/[Gadfly.jl](https://github.com/GiovineItalia/Gadfly.jl) libraries.
 - **:gr**: Through Plots.jl/[GR.jl](https://github.com/jheinen/GR.jl) libraries.

### Sample Usage

The following returns a `T<:Display` object that can render `EasyPlot.Plot` objects:

	pdisp = EasyPlotPlots.PlotDisplay(:pyplot)

A `plot::EasyPlot.Plot` object is therefore diplayed using:

	display(pdisp, plot)

More sample code can be found [here](../sample/EasyPlotPlots).

## Known Limitations

EasyPlotPlots.jl will *not* auto-install "backend" modules.  The `EasyPlotPlots/Project.toml` file only registers the main Plots.jl module for installation.

It appears the different backends do not all operate seamlessly.  Unsurprisingly, there appears to be varying levels of difficulty in getting the backends installed \& working properly.

Consequently, not all backends have been fully tested (if at all).  Please visit corresponding websites (above) for help installing the core libraries used as backends.

