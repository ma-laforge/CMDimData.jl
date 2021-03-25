#EasyPlot: docstring definitions
#-------------------------------------------------------------------------------

#==attributes()
===============================================================================#

@doc """`EasyPlot.attributes(...)`

Create a `AttributeChangeSpec[]` vector describing which plot attributes are
to be overwritten.

## Construct using function call:
```julia-repl
lin_log = EasyPlot.attributes(
    xyaxes = set(xscale=:lin, yscale=:log)
)
```

## Construct using function `cons()` interface:
```julia-repl
lin_log = cons(:a,
    xyaxes = set(xscale=:lin, yscale=:log)
)
```

## Alternative accepted symbols for `cons()` interface:
```julia-repl
cons(:attribute_list, args...; kwargs...) = EasyPlot.attributes(args...; kwargs...)
cons(:attr, args...; kwargs...) = EasyPlot.attributes(args...; kwargs...)
cons(:a, args...; kwargs...) = EasyPlot.attributes(args...; kwargs...)
```

# See also:
[`cons`](@ref),
[`EasyPlot.PlotCollection`](@ref), [`EasyPlot.Plot`](@ref), [`EasyPlot.Waveform`](@ref).
[`EasyPlot.TextAnnotation`](@ref), [`EasyPlot.vmarker`](@ref), [`EasyPlot.hmarker`](@ref),
""" attributes


@doc """`EasyPlot.Plot([attr]; title="TITLE", [attr_kwargs])`

Create an object that describes a plot.

Alternative construction using `cons()` interface:
```julia-repl
plot = cons(:plot, title="Plot Title",
	xyaxes=set(xscale=:lin, yscale=:lin)
	labels=set(xaxis="X-Axis Label", yaxis="Y-Axis Label")
)
```

The following are supported attribute keyword arguments (`attr_kwargs`):
 - `xyaxes=...`, `xaxis=...`, `nstrips=...`, `ystrip=...`, `xfolded=...`, `labels...`

Alternatively, `attr_kwargs` can be bundled into `AttributeChangeSpec` vectors with the [`EasyPlot.attributes`](@ref)
function call or its `cons(:a, ...)` alias. `attr=AttributeChangeSpec` vectors can then be passed to the constructor.

```julia-repl
linlin = cons(:a, xyaxes=set(xscale=:lin, yscale=:lin))
alabels = cons(:a, labels=set(xaxis="X-Axis Label", yaxis="Y-Axis Label"))

plot = cons(:plot, linlin, alabels, title="Plot Title")
```

# Supported attributes

## X/Y Axes (`xyaxes=`): Produce single y-strip.

The following example lists which attributes of x/y axes values can be overwritten:

TODO: List valid scales
```julia-repl
lin_log = cons(:a,
    xyaxes = set(xscale=:lin, yscale=:log)
)

axesattr = cons(:a,
    xyaxes = set(xscale=:lin, yscale=:log, xmin=3, xmax=5, ymin=0, ymax=10)
)
```

## X-Axis (`xaxis=`)

The following example shows how x-axis attributes can be overwritten:

TODO: List valid scales
```julia-repl
logscale = cons(:a, xaxis = set(scale=:log))

xattr = cons(:a,
	xaxis = set(scale=:log, min=-1, max=4, label="Frequency (Hz)")
)
```

## Multi-Y-Strips (`nstrips=`, `ystrip=`)
The following example lists which y-strip attributes can be overwritten:

TODO: List valid scales
```julia-repl
ystripattributes = cons(:a,
    nstrips = 3,
    ystrip1 = set(min=0, max=.5, scale=:lin, axislabel="Voltage", striplabel="Strip 1 Label"),
    #Leave defaults for strip #2
    ystrip3 = set(min=1, max=1000, scale=:log, striplabel="Strip 3 Label"),
)

#=Note:
kwargs `ystripi` are only supporte from i=1...9. To set properties for i>9, you
can set the base `ystrip=` parameter (only 1 can be set per call to attributes()):
=#
ystripattributes2 = cons(:a,
    nstrips = 15,
    ystrip = set(12, min=0, max=.5, scale=:lin, axislabel="Voltage", striplabel="Strip 12 Label"),
)
```

## Folded x-axis (`xfolded=`)
Folded x=axis overlays (folds) all x-data onto same x-values.
**Used to create eye diagrams.**

The following example lists which folded x-axis attributes can be overwritten:
```julia-repl
foldedxaxis = cons(:a,
    xfolded = set(1e-9, xstart=5e-9, xmin=-1e9, xmax=1e-9)
)
```

## Labels (`labels=`)
The following example lists which labels can be overwritten:
```julia-repl
axislabels = cons(:a,
    labels = set(title="Plot Title", xaxis="X-Axis Label", yaxis="Y-Axis Label")
)
```

# See also:
[`cons`](@ref), [`EasyPlot.attributes`](@ref),
[`EasyPlot.PlotCollection`](@ref), [`EasyPlot.Waveform`](@ref).
""" Plot


@doc """`EasyPlot.Waveform(data::DataMD, [attr]; [attr_kwargs], label="idstr")`

Creates a waveform from `data` from a multi-dimensional (`DataMD`) dataset.

Alternative construction using `cons()` interface:

```julia-repl
wfrm = cons(:wfrm, dataset1, line=set(style=:solid, color=:red), label="Dataset 1")
```

The following are supported attribute keyword arguments (`attr_kwargs`):
 - `line=...`, `glyph=...`

Alternatively, `attr_kwargs` can be bundled into `AttributeChangeSpec` vectors with the [`EasyPlot.attributes`](@ref)
function call or its `cons(:a, ...)` alias. `attr=AttributeChangeSpec` vectors can then be passed to the constructor.

```julia-repl
dfltline = cons(:a, line=set(style=:solid, color=:red))
dfltglyph = cons(:a, glyph=set(shape=:square, size=3))

wfrm = cons(:wfrm, dataset1, dfltline, dfltglyph, label="Dataset 1")
```

# Supported attributes

## Line Attributes (`line=`)
The following example lists which line attributes can be overwritten:

TODO: List valid styles
```julia-repl
lineattributes = cons(:a,
    line = set(style=:dash, width=3, color=:red)
)
```

## Glyph/Marker Attributes (`glyph=`)
The following example lists which glyph attributes can be overwritten:\r
TODO: List valid shapes
```julia-repl
glyphattributes = cons(:a,
    line = set(shape=:circle, size=3, color=:red, fillcolor=:white)
)
```

# See also:
[`cons`](@ref), [`EasyPlot.attributes`](@ref),
[`EasyPlot.PlotCollection`](@ref), [`EasyPlot.Plot`](@ref).
""" Waveform



@doc """`TextAnnotation("Some text", [attr]; [attr_kwargs])`

Text annotation object to overlay on plot.

Alternative construction using `cons()` interface:
```julia-repl
annot = cons(:atext, "Some text", x=1, y=2, angle=0, align=:bl, strip=1)
```

The following are supported attribute keyword arguments (`attr_kwargs`):
 - `prop=...`, `offset=...`, `reloffset=...`

Alternatively, `attr_kwargs` can be bundled into `AttributeChangeSpec` vectors with the [`EasyPlot.attributes`](@ref)
function call or its `cons(:a, ...)` alias. `attr=AttributeChangeSpec` vectors can then be passed to the constructor.

```julia-repl
atextprop = cons(:a, #Construct `attributes` object
	prop=set(angle=0, align=:bl, strip=1),
	offset=set(x=-1, y=-1), #Device units
	reloffset=set(x=.5, y=.5), #Normalized to [0,1] graph bounds; depends on zoom level
)

annot = cons(:atext, "Some text", atextprop, x=1, y=2)
```

# Supported attributes

#TODO: Describe in more detail


# See also:
[`cons`](@ref) [`attributes`](@ref)
""" TextAnnotation


@doc """`cons(obj_symbol, args...; kwargs...)`

"Construct" interface created to minimize number of exported symbols.

## Construct `AttributeChangeSpec` vectors (call `EasyPlot.attributes()`):
```julia-repl
cons(:attribute_list, args...; kwargs...) = EasyPlot.attributes(args...; kwargs...)
cons(:attr, args...; kwargs...) = EasyPlot.attributes(args...; kwargs...)
cons(:a, args...; kwargs...) = EasyPlot.attributes(args...; kwargs...)
```

## Construct plot objects:
```julia-repl
cons(:plot_collection, args...; kwargs...) = EasyPlot.PlotCollection(args...; kwargs...)
cons(:plotcoll, args...; kwargs...) = EasyPlot.PlotCollection(args...; kwargs...)
cons(:plot, args...; kwargs...) = EasyPlot.Plot(args...; kwargs...)
cons(:wfrm, args...; kwargs...) = EasyPlot.Waveform(args...; kwargs...)
cons(:fldaxis, args...; kwargs...) = EasyPlot.FoldedAxis(args...; kwargs...)
```

## Construct annotation objects:
```julia-repl
cons(:atext, args...; kwargs...) = EasyPlot.TextAnnotation(args...; kwargs...)
cons(:vmarker, args...; kwargs...) = EasyPlot.vmarker(args...; kwargs...)
cons(:hmarker, args...; kwargs...) = EasyPlot.hmarker(args...; kwargs...)
```

# See also:
[`EasyPlot.attributes`](@ref),
[`EasyPlot.PlotCollection`](@ref), [`EasyPlot.Plot`](@ref), [`EasyPlot.Waveform`](@ref).
[`EasyPlot.TextAnnotation`](@ref), [`EasyPlot.vmarker`](@ref), [`EasyPlot.hmarker`](@ref),
""" cons
#Last line
