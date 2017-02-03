#EasyPlotInspect base types & core functions
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#

const scalemap = Dict{Symbol, Symbol}(
	:lin => :lin,
	:log => :log10,
)

const linestylemap = Dict{Symbol, Symbol}(
	:none    => :none,
	:solid   => :solid,
	:dash    => :dash,
	:dot     => :dot,
	:dashdot => :dashdot,
)

const glyphmap = Dict{Symbol, Symbol}(
	:none      => :none,
	:square    => :square,
	:diamond   => :diamond,
	:uarrow    => :uarrow, :darrow => :darrow,
	:larrow    => :larrow, :rarrow => :rarrow,
	:cross     => :cross, :+ => :+,
	:diagcross => :diagcross, :x => :x,
	:circle    => :circle, :o => :o,
	:star      => :star, :* => :*,
)

immutable FlagType{T}; end
const NOTFOUND = FlagType{:NOTFOUND}()


#==Base types
===============================================================================#
typealias NullOr{T} Union{Void, T} #Simpler than Nullable

type Axes{T} <: EasyPlot.AbstractAxes{T}
	ref::InspectDR.Plot2D #Plot reference
	theme::EasyPlot.Theme
	eye::NullOr{EasyPlot.EyeAttributes}
end
Axes(style::Symbol, ref, theme::EasyPlot.Theme, eye=nothing) =
	Axes{style}(ref, theme, eye)

type WfrmAttributes
	label
	linecolor
	linewidth #[0, 10]
	linestyle
	glyphshape
	glyphsize
	glyphcolor
	glyphfillcolor #Fill color.
end
WfrmAttributes(;label=nothing,
	linecolor=nothing, linewidth=nothing, linestyle=nothing,
	glyphshape=nothing, glyphsize=nothing,
	glyphcolor=nothing, glyphfillcolor=nothing) =
	WfrmAttributes(label, linecolor, linewidth, linestyle,
		glyphshape, glyphsize, glyphcolor, glyphfillcolor
)


#==Helper functions
===============================================================================#
mapcolor(v::Colorant) = v
mapglyphcolor(v) = mapcolor(v) #In case we want to diverge

#Linewidth:
maplinewidth(w) = w
maplinewidth(::Void) = maplinewidth(1) #default

#Glyph size:
mapglyphsize(sz) = 6*sz
mapglyphsize(::Void) = mapglyphsize(1) #default

function maplinestyle(v::Symbol)
	result = get(linestylemap, v, NOTFOUND)
	if NOTFOUND == result
		info("Line style not supported: :$v")
		result = maplinestyle(nothing)
	end
	return result
end
maplinestyle(::Void) = "-" #default

function mapglyphshape(v::Symbol)
	result = get(glyphmap, v, NOTFOUND)
	if NOTFOUND == result
		info("Glyph shape not supported: :$v")
		result = :o #Use some supported glyph shape
	end
	return result
end
mapglyphshape(::Void) = :none #default (no glyph)

function WfrmAttributes(id::String, attr::EasyPlot.WfrmAttributes)
	return WfrmAttributes(label=id,
		linecolor=mapcolor(attr.linecolor),
		linewidth=maplinewidth(attr.linewidth),
		linestyle=maplinestyle(attr.linestyle),
		glyphshape=mapglyphshape(attr.glyphshape),
		glyphsize=mapglyphsize(attr.glyphsize),
		glyphcolor=mapglyphcolor(attr.glyphlinecolor),
		glyphfillcolor=mapglyphcolor(attr.glyphfillcolor),
	)
end


#==Rendering functions
===============================================================================#

#Add DataF1 results:
function _addwfrm(plot::InspectDR.Plot2D, d::DataF1, a::WfrmAttributes)
	wfrm = add(plot, d.x, d.y, id=a.label)
	wfrm.line = line(color=a.linecolor, width=a.linewidth, style=a.linestyle)
	wfrm.glyph = glyph(shape=a.glyphshape, size=a.glyphsize,
		color=a.glyphcolor, fillcolor=a.glyphfillcolor
	)
end

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(ax::Axes, d::DataF1, id::String,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes)
	attr = EasyPlot.WfrmAttributes(ax.theme, la, ga) #Apply theme to attributes
	inspectattr = WfrmAttributes(id, attr) #Attributes understood by InspectDR
	_addwfrm(ax.ref, d, inspectattr)
end

function generatesubplot(subplot::EasyPlot.Subplot, theme::EasyPlot.Theme)
	iplot = InspectDR.Plot2D()
	strip = iplot.strips[1]

	#TODO Ugly: setting defaults like this should be done in EasyPlot
	ep = nothing
	if :eye == subplot.style
		ep = subplot.eye
		if nothing == ep.teye; ep.teye = ep.tbit; end
	end

	axes = Axes(subplot.style, iplot, theme, ep)

	for (i, wfrm) in enumerate(subplot.wfrmlist)
		EasyPlot.addwfrm(axes, wfrm, i)
	end

	srca = subplot.axes

	#Update axis limits:
	_getlim(v::Void) = NaN
	_getlim(v::Real) = Float64(v)
	iplot.xext_full = InspectDR.PExtents1D(_getlim(srca.xmin), _getlim(srca.xmax))
	strip.yext_full = InspectDR.PExtents1D(_getlim(srca.ymin), _getlim(srca.ymax))

	#Apply x/y scales:
	iplot.xscale = InspectDR.AxisScale(scalemap[srca.xscale])
	strip.yscale = InspectDR.AxisScale(scalemap[srca.yscale], tgtmajor=8, tgtminor=2)
	
	#Apply x/y labels:
	a = iplot.annotation
	a.title = subplot.title
	a.xlabel = srca.xlabel
	a.ylabels = [srca.ylabel]
	return iplot
end

function render(mplot::InspectDR.Multiplot, eplot::EasyPlot.Plot, lyt::InspectDR.Layout)
	mplot.ncolumns = eplot.ncolumns
	mplot.title = eplot.title

	for s in eplot.subplots
		plot = generatesubplot(s, eplot.theme)
		plot.layout = lyt
		add(mplot, plot)
		plot.layout.legend.enabled = eplot.displaylegend
	end

	return mplot
end

#Last line
