# `CMDimData.EasyPlot` Plotting interface

 1. [Description](#Description)
 1. [Main plot objects](#Objects)
    1. [Attributes & `AttributeChangeSpec`](#AttributeChangeSpec)
    1. [Axis scale identifiers](#AxisScaleIdentifiers)
    1. [Supported linestyles](#Linestyles)
    1. [Supported glyphs](#Glyphs)
 1. [Creating plots](#CreatingPlots)
 1. [Supported backends](EasyPlot_backends.md)
 1. [Julia display stack: Adding a default backend](#DisplayAddBackend)
 1. [Configuration/defaults](EasyPlot_config.md)
    1. [Default builders](EasyPlot_config.md#)
    1. [Inline plots](EasyPlot_config.md#InlinePlots)
    1. [Defaults & backend initialization](EasyPlot_config.md#Defaults)
 1. [Known limitations](#KnownLimitations)
    1. [Important note on `@includepkg`](#includepkg_Note)


## Description

`CMDimData.EasyPlot` provides a high-level abstraction to describe plots.  The interface is optimized to write compact extraction routines for investigative (circuit) design work.

The goal of the `CMDimData.EasyPlot` interface is to let the user focus on analyzing measurement/simulation results (extracting relevant circuit performance) by *keeping the necessary plotting code to a strict minimum*.  Also, to keep things portable, an `EasyPlot.Plot` object can be rendered on different backends.

That being said, the `CMDimData.EasyPlot` interface is relatively generic and should be adequate for many scientific fields.

<a name="Objects"></a>
## Main plot objects

 - `EasyPlot.PlotCollection`: A collection of plots to display simultaneously.
 - `EasyPlot.Plot`: A single plot.
 - `EasyPlot.Waveform`: Stores input data and attributes specifying how do display.
 - `EasyPlot.LineAttributes`: How to draw lines.
 - `EasyPlot.GlyphAttributes`: How to display glyphs (aka markers/symbols).

Note that objects are constructed using the `cons(...)` API to minimize namespace pollution (see [Creating Plots]()).

<a name="AttributeChangeSpec"></a>
### Attributes & `AttributeChangeSpec`
To simultaneously set multiple object attributes in a single command, `EasyPlot` uses `AttributeChangeSpec` objects.  These objecs are created with the `attributes()` function, for example:
```julia
lin_log = EasyPlot.attributes(
    xyaxes = set(xscale=:lin, yscale=:log)
)
```

In practice however, users should call the `cons(:attribute_list, ...)` function or one of its aliases (`:a`, `:attr`) created to reduce namespace pollution (objects are not all `export`ed):
```julia
#Aliases:
lin_log = cons(:a, xyaxes = set(xscale=:lin, yscale=:log) )
lin_log = cons(:attr, xyaxes = set(xscale=:lin, yscale=:log) )
lin_log = cons(:attribute_list, xyaxes = set(xscale=:lin, yscale=:log) )

#Direct call:
lin_log = EasyPlot.attributes( xyaxes = set(xscale=:lin, yscale=:log) )
```

Use Julia's help system for more examples on how to create `AttributeChangeSpec`s:

```julia-repl
help?> cons
help?> EasyPlot.attributes
help?> EasyPlot.Plot
help?> EasyPlot.PlotCollection
help?> EasyPlot.Waveform
```

<a name="AxisScaleIdentifiers"></a>
### Axis scale identifiers
X/Y-axis scales are specified using one of the following `Symbols`:

 - `:lin`
 - `:log10`, `:log` (= `:log10`)
 - `:ln`, `:log2` (not yet supported)
 - `:dB20`, `:dB10`
 - `:reciprocal`

<a name="Linestyles"></a>
### Supported linestyles
 - `:none`, `:solid`, `:dash`, `:dot`, `:dashdot`

<a name="Glyphs"></a>
### Supported glyphs (aka markers/symbols)
 - `:none`, `:square`, `:diamond`
 - `:uarrow`, `:darrow`, `:larrow`, `:rarrow` (usually triangles)
 - `:+`, `:cross`, `:x`, `:diagcross`
 - `:o`, `:circle`, `:*`, `:star`

TODO: :star4, :star5, ...??

<a name="CreatingPlots"></a>
## Creating plots

There are two steps to plotting with EasyPlot:

 1. Create the `Plot`/`PlotCollection` object
 2. Display the `Plot`/`PlotCollection` object

Note that you must choose a particular [plotting backend](EasyPlot_backends.md) on which the plot is to be displayed.

### Plot creation example: A simple plot
The following illustrates how to create plots with EasyPlot:

```julia
using CMDimData
using MDDatasets #Create multi-dim data (DataF1)
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotInspect #Display plots with InspectDR

#Generate some data:
x = DataF1(-2:.1:2)

#`cons`truct a backend-agnositc EasyPlot.Plot object:
plot = cons(:plot, title="Simple plot", legend=true,
    labels = set(xaxis="x-value", yaxis="y-value")
)

#Add some data:
push!(plot,
    cons(:wfrm, x^2, label="x^2"),
    cons(:wfrm, x^3, label="x^3"),
)

#Display plot on selected backend:
EasyPlot.displaygui(:InspectDR, plot)
```

### Plot creation example: A stacked, multi-*strip* plot
`EasyPlot.Plot` supports "multi-strip" plots with a common x-axis and multiple stacked y-axes.
"Multi-strip" plots are ideal for plotting data with widely differing y-value ranges.

```julia
using CMDimData
using MDDatasets #Create multi-dim data (DataF1)
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotInspect #Display plots with InspectDR

#Generate data with differing y-value ranges:
T = 1/60; ΔT = T/20 #sec
C = 480e-6 #F
t = DataF1(0:ΔT:8T) #sec
v = (120*sqrt(2)) * sin(t*(2π/T)) #V
    dv_dt = (2π/T) * cos(t*(2π/T)) #Calculate (more exact)
i = C * dv_dt

#Create a multi-strip plot:
plot = cons(:plot, nstrips=2, title="Multi-strip plot", legend=true,
    ystrip1 = set(axislabel="Voltage [V]"),
    ystrip2 = set(axislabel="Current [A]"),
    xaxis = set(label="Time [s]"),
)

#Add some data:
push!(plot,
    cons(:wfrm, v, label="cap", strip=1),
    cons(:wfrm, i, label="cap", strip=2),
)

#Display plot on selected backend:
EasyPlot.displaygui(:InspectDR, plot)
```

### Plot creation example: Bode plot (Another multi-*strip* plot)
```julia
# ...

#Create a multi-strip plot:
plot = cons(:plot, nstrips=2, title="Bode plot", legend=true,
    ystrip1 = set(axislabel="|G(s)| [dB]"),
    ystrip2 = set(axislabel="∠G(s) [°]"),
    xaxis = set(label="Frequency [Hz]"),
)

# ...
```

### Plot creation example: A multi-*plot* collection

```julia
pcoll = cons(:plot_collection, title="A multiplot object", ncolumns=2)

push!(pcoll,
    cons(:plot, title="1st plot"),
    cons(:plot, title="2nd plot"),
)

EasyPlot.displaygui(:InspectDR, pcoll)
```

## [Supported backends (link)](EasyPlot_backends.md)

<a name="DisplayAddBackend"></a>
## Julia display stack: Adding a default backend

It is also possible to use the Julia display stack to specify an default backend for rendering plots. Simply push an instance of the desired backend's `<:AbstractPlotDisplay` object to the top of Julia's display stack:

```julia
using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotInspect

pushdisplay(EasyPlot.GUIDisplay(:InspectDR)); #Semicolon: inhibit object dump to REPL
```

NOTE: `EasyPlot.GUIDisplay(:InspectDR, args...; kwargs...)` returns a GUI-enabled `<:AbstractPlotDisplay`/plot builder for the `InspectDR` backend.

With an `<:AbstractPlotDisplay` object on Julia's display stack, it is no longer necessary to use `EasyPlot.displaygui()`:

```julia
#Display plot using the top-most (most recently pushed) `AbstractPlotDisplay` object:
display(plot)
```

Actually, the Julia `REPL`, implicitly calls `display()` if you evaluate `plot`:
```julia
julia> plot
```

<a name="KnownLimitations"></a>
## Known limitations

 - `EasyPlot` supports mostly x/y graphs & basic plot attributes at the moment.
 - `EasyPlot` does not support `DataTime` or `DataFreq`.
 - The `CMDimData.@includepkg [backend]` macro evaluates the interfacing code at run time to circumvent having to add backends as dependencies of `CMDimData`.  They consequenly do not take advantage of Julia's pre-compilation cache.

<a name="includepkg_Note"></a>
### Important note on `@includepkg`

`@includepkg` includes the module code that implements the `EasyPlot` interface (ex: `EasyPlotInspect`) in whichever module it is called.  It also imports the plotting backend module (ex: `InspectDR`).

These modules will therefore only be accessible from within that scope.  Consequently, your Julia environment must ensure it can resolve where the backend module resides.  This can be done by adding the backend module to the active julia "project".  For example, you can add the InspectDR backend to the active Julia project with the package add command:

```julia
]add InspectDR
```
