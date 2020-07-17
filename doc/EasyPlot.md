# `CMDimData.EasyPlot` Plotting Interface

## Description

`CMDimData.EasyPlot` provides a high-level abstraction to describe plots.  The interface is optimized to write compact extraction routines for investigative (circuit) design work.

The goal of the `CMDimData.EasyPlot` interface is to let the user focus on analyzing measurement/simulation results (extracting relevant circuit performance) by *keeping the necessary plotting code to a strict minimum*.  Also, to keep things portable, an `EasyPlot.Plot` object can be rendered on different backends.

That being said, the `CMDimData.EasyPlot` interface is relatively generic and should be adequate for many scientific fields.

## Plotting with EasyPlot

There are two steps to plotting with EasyPlot:

 1. Create the `Plot` object
 2. Display the `Plot` object

Note that you must choose a particular backend on which the plot is to be displayed.  To achieve this, you must specify a subtype of `EasyPlot.EasyPlotDisplay` that corresponds to a [plotting backend](EasyPlot_backends.md).

### Displaying a Simple Plot

Here is a simple example showing how to display a plot with EasyPlot:

	#Import CMDimData/EasyPlot facilities
	using CMDimData
	using CMDimData.EasyPlot
	CMDimData.@includepkg EasyPlotInspect #To render plots with InspectDR

	#Create an object to tell EasyPlot how to render plots (with InspectDR backend)
	pdisp = EasyPlotInspect.PlotDisplay() #<:EasyPlotDisplay

	#Create a backend-agnositc EasyPlot.Plot object:
	plot = EasyPlot.new(title = "Sample Plot")

	#Display the plot on the selected backend:
	display(pdisp, plot)

### [Supported Backends (link)](EasyPlot_backends.md)

### Important note on `@includepkg`

`@includepkg` includes the module code that implements the `EasyPlot` interface (ex: `EasyPlotInspect`) in whichever module it is called.  It also imports the plotting backend module (ex: `InspectDR`).

These modules will therefore only be accessible from within that scope.  Consequently, your Julia environment must ensure it can resolve where the backend module resides.  This can be done by adding the backend module to the active julia "project".  For example, you can add the InspectDR backend to the active Julia project with the package add command:

	]add InspectDR

### Sample Usage

More elaborate examples of creating `EasyPlot.Plot` objects can be found in the [sample/EasyPlot](../sample/EasyPlot/) folder.

### Specifying an Active Backend

It is also possible to use the Julia display stack to specify an active backend for rendering plots. Simply push an instance of the desired backend's `EasyPlotDisplay` object to the top of Julia's display stack:

	pushdisplay(EasyPlotInspect.PlotDisplay())

With a `<:EasyPlotDisplay` object on Julia's display stack, it is no longer necessary to specify `pdisp` when calling `display`:

	#Display plot using the top-most (most recently pushed)
	#EasyPlotDisplay object:
	display(plot)

## Configuration

### Inline Plots/Defaults

`EasyPlot.Plot` objects can be rendered inline (ex: IJulia notebooks) by configuring `defaults`:

	EasyPlot.defaults.renderdisplay = EasyPlotMPL.PlotDisplay(guimode=false)

If SVG inline plots are undesired (ex: for performance reasons), they can be suppressed as follows:

	EasyPlot.defaults.rendersvg = false

### Initializing Defaults

Default settings can be initialized even *before* importing the `CMDimData` module with the help of environment variables.  The following code describes how this can be done from the `~/.julia/config/startup.jl` file.

To select the default `EasyPlot.Plot` display, add the following key before importing `CMDimData`:

	ENV["EASYPLOT_DEFAULTDISPLAY"] = "EasyPlotInspect"

To import and initialize said user-selected display module once `EasyPlot` is loaded, simply execute the following:

	CMDimData.EasyPlot.@initbackend()

Currently supported options for `EASYPLOT_DEFAULTDISPLAY` are:
 - `None`: Do not auto-initialize default displays.
 - `Any`: First `import`ed module is used as the default.
 - `EasyPlotInspect`: (InspectDR)
 - `EasyPlotGrace`: (GracePlot)
 - `EasyPlotMPL`: (PyPlot/Matplotlib)
 - `EasyPlotQwt`: (Qwt)
 - `EasyPlotPlots`: (Plots.jl)

To display EasyPlot plots using inline graphics, add the following key before importing `CMDimData`:

	ENV["EASYPLOT_RENDERONLY"] = "true"

**IMPORTANT:** If `ENV["EASYPLOT_RENDERONLY"] != "true"`, `EasyPlot` will automatically push the default display onto Julia's display stack.

To dissallow SVG inline plots, following key before importing `CMDimData`:

	ENV["EASYPLOT_RENDERSVG"] = "false"

## Known Limitations

 - `EasyPlot` supports mostly x/y graphs & basic plot attributes at the moment.
 - `EasyPlot` does not support `DataTime` or `DataFreq`.
 - The `CMDimData.@includepkg [backend]` macro evaluates the interfacing code at run time to circumvent having to add backends as dependencies of `CMDimData`.  They consequenly do not take advantage of Julia's pre-compilation cache.

