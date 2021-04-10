# `CMDimData.EasyPlot` Configuration/defaults

## Default builders
```julia
EasyPlot.defaults.guibuilder #Uses a backend to build plot GUIs.
EasyPlot.defaults.filebuilder #Uses a backend to write directly to file (no GUI, typically an image file).
EasyPlot.defaults.mimebuilder #Uses a backend to write to a MIME output (no GUI, typically image data).
```

<a name="InlinePlots"></a>
## Inline plots

`EasyPlot.PlotCollection` objects can be rendered inline (ex: IJulia notebooks)
by configuring `defaults`. For example, rendering inline plots with the
InspectDR backend can be achived with the following:

```julia
CMDimData.@includepkg EasyPlotInspect
EasyPlot.defaults.mimebuilder = EasyPlot.getbuilder(:image, :InspectDR)

#Can only display PlotCollection objects at the moment:
pcoll = push!(cons(:plot_collection), plot)
display(pcoll) #Jupyter should now render plot using InspectDR.
```

If SVG inline plots are undesired (ex: for performance reasons), it is possible
to inhibit `defaults.mimebuilder` from generating SVG outputs by changing the
`defaults.rendersvg` setting:

```julia
EasyPlot.defaults.rendersvg = false
```

<a name="Defaults"></a>
## Defaults & backend initialization

Default settings can be initialized even *before* importing the `CMDimData` module with the help of environment variables.  The following code describes how this can be done from the `~/.julia/config/startup.jl` file.

TODO: Figure out how to do backend initialization.  Not sure it is pratical anymore.

To dissallow SVG inline plots, set the following `ENV[]` variable before importing `CMDimData`:

```julia
ENV["EASYPLOT_RENDERSVG"] = "false"
```

