#EasyPlot: docstring definitions
#-------------------------------------------------------------------------------

#==attributes()
===============================================================================#

@doc """
    attributes(...)

Create a `AttributeChangeSpec[]` vector describing which plot attributes are
to be overwritten.

# X/Y Axes (`xyaxes=`): Produce single y-strip.

The following example lists which attributes of x/y axes values can be overwritten:

TODO: List valid scales
```julia-repl
lin_log = attributes(
    xyaxes = set(xscale=:lin, yscale=:log)
)

axesattr = attributes(
    xyaxes = set(xscale=:lin, yscale=:log, xmin=3, xmax=5, ymin=0, ymax=10)
)
```

# X-Axis (`xaxis=`)

The following example shows how x-axis attributes can be overwritten:

TODO: List valid scales
```julia-repl
logscale = attributes(xaxis = set(scale=:log))

xattr = attributes(
	xaxis = set(scale=:log, min=-1, max=4, label="Frequency (Hz)")
)
```

# Multi-Y-Strips (`nstrips=`, `ystrip=`)
The following example lists which y-strip attributes can be overwritten:

TODO: List valid scales
```julia-repl
ystripattributes = attributes(
    nstrips = 3,
    ystrip1 = set(min=0, max=.5, scale=:lin, axislabel="Voltage", striplabel="Strip 1 Label"),
    #Leave defaults for strip #2
    ystrip3 = set(min=1, max=1000, scale=:log, striplabel="Strip 3 Label"),
)

#=Note:
kwargs `ystripi` are only supporte from i=1...9. To set properties for i>9, you
can set the base `ystrip=` parameter (only 1 can be set per call to attributes()):
=#
ystripattributes2 = attributes(
    nstrips = 15,
    ystrip = set(12, min=0, max=.5, scale=:lin, axislabel="Voltage", striplabel="Strip 12 Label"),
```

# Folded x-axis (`xfolded=`)
Folded x=axis overlays (folds) all x-data onto same x-values.
**Used to create eye diagrams.**

The following example lists which folded x-axis attributes can be overwritten:
```julia-repl
foldedxaxis = attributes(
    xfolded = set(1e-9, xstart=5e-9, xmin=-1e9, xmax=1e-9)
)
```

# Labels (`labels=`)
The following example lists which labels can be overwritten:
```julia-repl
axislabels = attributes(
    labels = set(title="Plot Title", xaxis="X-Axis Label", yaxis="Y-Axis Label")
)
```

# Line Attributes (`line=`)
The following example lists which line attributes can be overwritten:

TODO: List valid styles
```julia-repl
lineattributes = attributes(
    line = set(style=:dash, width=3, color=:red)
)
```

# Glyph/Marker Attributes (`glyph=`)
The following example lists which glyph attributes can be overwritten:\r
TODO: List valid shapes
```julia-repl
glyphattributes = attributes(
    line = set(shape=:circle, size=3, color=:red, fillcolor=:white)
)
```
""" attributes

#Last line
