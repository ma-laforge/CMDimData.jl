#EasyPlotInspect base types & core functions
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#

const scalemap = Dict{Symbol, Symbol}(
	:lin => :lin,
	:log => :log10,
	:log10 => :log10,
	:dB10 => :dB10,
	:dB20 => :dB20,
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

struct NotFound; end
const NOTFOUND = NotFound()


#==Base types
===============================================================================#
const NullOr{T} = Union{Nothing, T} #Simpler than Nullable

mutable struct Builder <: EasyPlot.AbstractBuilder
	ref::InspectDR.Plot2D #Plot reference
	theme::EasyPlot.Theme
	fold::NullOr{EasyPlot.FoldedAxis}
end

mutable struct WfrmAttributes
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
maplinewidth(::Nothing) = maplinewidth(1) #default

#Glyph size:
mapglyphsize(sz) = 6*sz
mapglyphsize(::Nothing) = mapglyphsize(1) #default

function maplinestyle(v::Symbol)
	result = get(linestylemap, v, NOTFOUND)
	if NOTFOUND == result
		@info("Line style not supported: :$v")
		result = maplinestyle(nothing)
	end
	return result
end
maplinestyle(::Nothing) = "-" #default

function mapglyphshape(v::Symbol)
	result = get(glyphmap, v, NOTFOUND)
	if NOTFOUND == result
		@info("Glyph shape not supported: :$v")
		result = :o #Use some supported glyph shape
	end
	return result
end
mapglyphshape(::Nothing) = :none #default (no glyph)

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


#==AbstractBuilder implementation
===============================================================================#
EasyPlot.needsfold(b::Builder) = b.fold

#Add DataF1 results:
function _addwfrm(plot::InspectDR.Plot2D, d::DataF1, a::WfrmAttributes, strip::Int)
	wfrm = add(plot, d.x, d.y, id=a.label, strip=strip)
	wfrm.line = line(color=a.linecolor, width=a.linewidth, style=a.linestyle)
	wfrm.glyph = glyph(shape=a.glyphshape, size=a.glyphsize,
		color=a.glyphcolor, fillcolor=a.glyphfillcolor
	)
end

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(b::Builder, d::DataF1, id::String,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes, strip::Int)
	attr = EasyPlot.WfrmAttributes(b.theme, la, ga) #Apply theme to attributes
	inspectattr = WfrmAttributes(id, attr) #Attributes understood by InspectDR
	_addwfrm(b.ref, d, inspectattr, strip)
end


#==Plot building functions
===============================================================================#

function generateplot(plot::EasyPlot.Plot, theme::EasyPlot.Theme)
	iplot = InspectDR.Plot2D()
	fold = isa(plot.xaxis, EasyPlot.FoldedAxis) ? plot.xaxis : nothing

	#x-axis properties:
	iplot.xext_full = InspectDR.PExtents1D(plot.xext.min, plot.xext.max)
	iplot.xscale = InspectDR.AxisScale(scalemap[Symbol(plot.xaxis)])

	#Want more resolution on y-axis than default:
	#TODO: is there a better way???
	_yaxisscale(s::Symbol) = InspectDR.AxisScale(s, tgtmajor=8, tgtminor=2)

	#y-strip properties:
	iplot.strips = [] #Reset
	for srcstrip in plot.ystriplist
		strip = InspectDR.GraphStrip()
		push!(iplot.strips, strip)
		strip.yscale = _yaxisscale(scalemap[srcstrip.scale])
		strip.yext_full = InspectDR.PExtents1D(srcstrip.ext.min, srcstrip.ext.max)
	end

	#Apply x/y labels:
	a = iplot.annotation
	a.title = plot.title
	a.xlabel = plot.xlabel
	a.ylabels = String[strip.axislabel for strip in plot.ystriplist]
	a.ystriplabels = String[strip.striplabel for strip in plot.ystriplist]

	#Add data using EasyPlot.AbstractBuilder interface:
	builder = Builder(iplot, theme, fold)
	for (i, wfrm) in enumerate(plot.wfrmlist)
		EasyPlot.addwfrm(builder, wfrm, i)
	end
	
	return iplot
end

function render(mplot::InspectDR.Multiplot, ecoll::EasyPlot.PlotCollection, lyt::InspectDR.PlotLayout)
	mplot.layout[:ncolumns] = ecoll.ncolumns
	mplot.title = ecoll.title

	for p in ecoll.plotlist
		plot = generateplot(p, ecoll.theme)
		plot.layout.values = lyt
		add(mplot, plot)
		plot.layout[:enable_legend] = ecoll.displaylegend
	end

	return mplot
end

#Last line
