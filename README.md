# EasyPlot.jl

## Description

The EasyPlot.jl provides a high-level abstraction to describe plots.  The interface is optimized to write tiny extraction routines for investigative (circuit) design work.

The goal of the EasyPlot interface is to let the user focus on analyzing simulation results (extracting relevant circuit performance) by *keeping the necessary plotting code to a strict minimum*.  Also, to keep things portable, EasyPlot plots can be rendered on different backends - provided by external modules.

That being said, the EasyPlot.jl module is generic and will likely help to simplify plotting tasks in many scientific fields.

### Features/Highlights

 - Read/write plots to .hdf5 files using [EasyData.jl](https://github.com/ma-laforge/EasyData.jl).
 - Generate eye diagrams (even for backends without native support).
 - Plot multi-dimensional datasets (`T<:MDDatasets.DataMD`: `DataHR{Number}`, `DataHR{DataF1}`, `DataF1`).

## Sample Usage

Sample code to construct EasyPlot objects can be found [here](sample/).

## Configuration

### Displays

EasyPlot displays can be pushed onto the display stack, as can any `T<:Display` object:

	pushdisplay(EasyPlotGrace.PlotDisplay())

The topmost display will be used to render `EasyPlot.Plot` objects.


### Inline Plots/Defaults

`EasyPlot.Plot` objects can be rendered inline (ex: IJulia notebooks) by configuring `defaults`:

	EasyPlot.defaults.renderdisplay = EasyPlotMPL.PlotDisplay(guimode=false)

If SVG inline plots are undesired (ex: for performance reasons), they can be suppressed as follows:

	EasyPlot.defaults.rendersvg = false

### Initializing Defaults

Default settings can be initialized even *before* loading modules with the help of environment variables.  The following code describes how this can be done from the `.juliarc.jl` file.

To select the default EasyPlot display, add the following:

	ENV["EASYPLOT_DEFAULTDISPLAY"] = "Grace"

Currently supported displays are:
 - `None`: Do not auto-initialize default displays.
 - `Any`: First `import`ed module is used as the default.
 - `MPL`: (EasyPlotMPL)
 - `Grace`: (EasyPlotGrace)
 - `Qwt`: (EasyPlotQwt)
 - `Plots`: (EasyPlotPlots)

To display EasyPlot plots using inline graphics, add the following:

	ENV["EASYPLOT_RENDERONLY"] = "true"

**IMPORTANT:** If `ENV["EASYPLOT_RENDERONLY"] != "true"`, EasyPlot will automatically push the default display onto Julia's display stack.

To dissallow SVG inline plots, add the following:

	ENV["EASYPLOT_RENDERSVG"] = "false"

## Known Limitations

 - EasyPlot.jl mostly supports x/y graphs & basic plot attributes at the moment.
 - Does not support `DataTime` or `DataFreq`.

### Compatibility

Extensive compatibility testing of EasyPlot.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.2

## Disclaimer

The EasyPlot.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
