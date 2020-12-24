# `CMDimData.EasyPlot` Configuration/defaults

## Default builders
```julia
EasyPlot.defaults.guibuilder #Uses a backend to build plot GUIs.
EasyPlot.defaults.filebuilder #Uses a backend to write directly to file (no GUI, typically an image file).
EasyPlot.defaults.mimebuilder #Uses a backend to write to a MIME output (no GUI, typically image data).
```

<a name="InlinePlots"></a>
## Inline plots

`EasyPlot.Plot` objects can be rendered inline (ex: IJulia notebooks) by configuring `defaults`:

```julia
EasyPlot.defaults.mimebuilder = ...
```

TODO: Provide details/examples.

If SVG inline plots are undesired (ex: for performance reasons), `mimebuilder` can inhibit SVG output with the following:

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

