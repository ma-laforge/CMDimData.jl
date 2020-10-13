# `CMDimData.EasyPlot` backends

<a name="SupportedBackends"></a>
## Supported backends

The following is a list of modules implementing the `EasyPlot` interface, along with their corresponding plotting backends:

 - `EasyPlotInspect`: (InspectDR.jl)
 - `EasyPlotMPL`: (PyPlot.jl/Matplotlib)
 - `EasyPlotPlots`: (Plots.jl)
 - BROKEN `EasyPlotQwt`: (PyCall.jl/`guiqwt` Python library)
 - `EasyPlotGrace`: (GracePlot.jl)

## Choosing a backend

NOTE: The term "load time" is used loosely below to indicate time to first plot.

 - **InspectDR.jl**: One of the fastest supported backends with the second shortest load times (second to `xmgrace`).  InspectDR provides good interactivity. Very responsive, even with moderately-sized (~200k points) datasets.
   - Confirmed to handle 2GB datsets with reasonable speed on older desktop running Windows 10 (drag+pan of data area highly discouraged).
 - **Grace/xmgrace**: Short load times and fast when dealing with small datasets.  GUI feels a bit dated and unfamiliar, but one can readily fine tune almost any visual element to generate publication-quality plots.
 - **Matplotlib/PyPlot.jl**: Longer load times (connects to Python-based `matplotlib.pyplot` library).  Faster than Grace/xmgrace solution when dealing with moderately-sized datasets (~200k points).
 - **Qwt/guiqwt**: Longer load times (connects to Python-based `guiqwt` library).  Faster than Matplotlib/PyPlot.jl solution when dealing with moderately-sized datasets (~200k points).
   - Though efficient with moderately-sized datasets, `guiqwt` appears slow when plotting large a *number of traces* (ex: eye diagram of a long transient dataset split into many individual traces).
 - **Plots.jl/(\*.jl)**: Uniform plotting interface supporting multiple backends.

<a name="ImportingBackends"></a>
## Importing backends

Before importing any backend, `CMDimData.EasyPlot` must already be imported.

To import a specific interface module for a given plotting backend, as listed in [Supported Backends](#SupportedBackends), you must use the `@includepkg macro`:

	#Import base CMDimData/EasyPlot facilities
	using CMDimData
	using CMDimData.EasyPlot

	#Import a specific EasyPlot interface, and its associated backend module:
	CMDimData.@includepkg EasyPlotInspect #To render plots with InspectDR

	#Now ready to create `EasyPlotInspect.PlotDisplay()` objects to render plots.

## Configuring backends

### EasyPlotInspect

By default, `EasyPlotInspect` renders inline plots with a data display area of x x y pixels??.  To specify a different value, set the `EASYPLOTINSPECT_RENDERW/H` environment variables **NOT YET IMPLEMENTED**.

The values of `EASYPLOTINSPECT_RENDERW/H` can therefore be set from ~/.julia/config/startup.jl` with the following:

	ENV["EASYPLOTINSPECT_RENDERW"] = "300"
	ENV["EASYPLOTINSPECT_RENDERH"] = "200"

### EasyPlotMPL

To specify the default Matplotlib/PyPlot backend (i.e. GUI toolkit), add the following to your `~/.julia/config/startup.jl` file:

	ENV["EASYPLOTMPL_DEFAULTBACKEND"] = "gtk"

See main [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl) module for supported backends.

### EasyPlotPlots

To specify the default Plots.jl plot rendering tool, add the following to your `~/.julia/config/startup.jl` file:

	ENV["EASYPLOTPLOTS_RENDERINGTOOL"] = "gr"

See [Plots.jl `Backends` documentation page](http://docs.juliaplots.org/latest/backends/) for more information on supported backends.

### EasyPlotQwt

### EasyPlotGrace

By default, `EasyPlotGrace` renders inline plots at 75 dpi.  To specify a different value, set the `EASYPLOTGRACE_RENDERDPI` environment variable:

The value of `EASYPLOTGRACE_RENDERDPI` can therefore be set from `~/.julia/config/startup.jl` with the following:

	ENV["EASYPLOTGRACE_RENDERDPI"] = "200"

## Additional information: EasyPlotPlots

### Supported "sub"-backends
EasyPlotPlots.jl should support all plot rendering tools (backends) supported by Plots.jl itself.

 - Backends without display capabilities: `:hdf5`
 - Text/terminal-based backends: `:unicodeplots`
 - Image-only backends: `:pgfplotsx`
 - GUI-enabled backends: `:gr`, `:inspectdr`, `:pyplot`
 - Python-based backends: `:pyplot`
 - Browser-enabled? backends: `:plotly`, `:plotlyjs`

See [Plots.jl `Backends` documentation page](http://docs.juliaplots.org/latest/backends/) for more information on supported backends & how to install them.

### Sample usage

The following returns a `T<:Display` object that can render `EasyPlot.Plot` objects:

	pdisp = EasyPlotPlots.PlotDisplay(:pyplot)

A `plot::EasyPlot.Plot` object is therefore diplayed using:

	display(pdisp, plot)

More sample code can be found [here](../sample/EasyPlotPlots).

## Known limitations

 - It appears the different backends of `EasyPlotPlots` do not all operate seamlessly.  Unsurprisingly, there appears to be varying levels of difficulty in getting the backends installed \& working properly.  Consequently, not all backends have been fully tested (if at all).

 - `EasyPlotPlots` will *not* auto-install "backend" modules.  The `EasyPlotPlots/Project.toml` file only registers the main Plots.jl module for installation (or rather *will* do this, if ever it is converted to a proper package).
