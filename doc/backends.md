# `CMDimData.EasyPlot` Backends

<a name="SupportedBackends"></a>
## Supported Backends

The following is a list of modules implementing the `EasyPlot` interface, along with their corresponding plotting backends:

 - `EasyPlotInspect`: (InspectDR.jl)
 - `EasyPlotGrace`: (GracePlot.jl)
 - BROKEN `EasyPlotMPL`: (PyPlot.jl/Matplotlib)
 - BROKEN `EasyPlotQwt`: (Qwt.jl)
 - BROKEN `EasyPlotPlots`: (Plots.jl)

## Importing Backends

Before importing any backend, `CMDimData.EasyPlot` must already be imported.

To import a specific interface module for a given plotting backend, as listed in [Supported Backends](#SupportedBackends), you must use the `@importbackend macro`:

	#Import base CMDimData/EasyPlot facilities
	using CMDimData
	using CMDimData.EasyPlot

	#Import a specific EasyPlot interface, and its associated backend module:
	EasyPlot.@importbackend EasyPlotInspect #To render plots with InspectDR

	#Now ready to create `EasyPlotInspect.PlotDisplay()` objects to render plots.

## Configuring Backends

### EasyPlotInspect

By default, `EasyPlotInspect` renders inline plots with a data display area of x x y pixels??.  To specify a different value, set the `EASYPLOTINSPECT_RENDERW/H` environment variables **NOT YET IMPLEMENTED**.

The values of `EASYPLOTINSPECT_RENDERW/H` can therefore be set from `.juliarc.jl` with the following:

	ENV["EASYPLOTINSPECT_RENDERW"] = "300"
	ENV["EASYPLOTINSPECT_RENDERH"] = "200"

### EasyPlotGrace

By default, `EasyPlotGrace` renders inline plots at 75 dpi.  To specify a different value, set the `EASYPLOTGRACE_RENDERDPI` environment variable:

The value of `EASYPLOTGRACE_RENDERDPI` can therefore be set from `.juliarc.jl` with the following:

	ENV["EASYPLOTGRACE_RENDERDPI"] = "200"
