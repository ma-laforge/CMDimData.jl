# `CMDimData.EasyPlot` Configuration/defaults

<a name="InlinePlots"></a>
### Inline plots/defaults

`EasyPlot.Plot` objects can be rendered inline (ex: IJulia notebooks) by configuring `defaults`:

	EasyPlot.defaults.renderdisplay = EasyPlotMPL.PlotDisplay(guimode=false)

If SVG inline plots are undesired (ex: for performance reasons), they can be suppressed as follows:

	EasyPlot.defaults.rendersvg = false

<a name="Defaults"></a>
### Defaults & backend initialization

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

