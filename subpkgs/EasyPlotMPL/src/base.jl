#EasyPlotMPL base types & core functions
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#

const scalemap = Dict{Symbol, String}(
	:lin => "linear",
	:log => "log",
)

const linestylemap = Dict{Symbol, String}(
	:none    => "none",
	:solid   => "-",
	:dash    => "--",
	:dot     => ":",
	:dashdot => "-.",
)

const markermap = Dict{Symbol, String}(
	:none    => "",
	:square    => "s",
	:diamond   => "D", #Diagsquare; diamond is d
	:uarrow    => "^", :darrow => "v",
	:larrow    => "<", :rarrow => ">",
	:cross     => "+", :+ => "+",
	:diagcross => "x", :x => "x",
	:circle    => "o", :o => "o",
	:star      => "*", :* => "*",
)

struct NotFound; end
const NOTFOUND = NotFound()


#==Base types
===============================================================================#
const NullOr{T} = Union{Nothing, T} #Simpler than Nullable

mutable struct Builder <: EasyPlot.AbstractBuilder
	ref::PyCall.PyObject #"Axes" reference
	theme::EasyPlot.Theme
	fold::NullOr{EasyPlot.FoldedAxis}
end

mutable struct WfrmAttributes
	label
	color #linecolor
	linewidth
	linestyle
	marker
	markersize
	markerfacecolor
	markeredgecolor
	markeredgewidth
	fillstyle
end
WfrmAttributes(;label=nothing,
	color=nothing, linewidth=nothing, linestyle=nothing,
	marker=nothing, markersize=nothing, markerfacecolor=nothing,
	markeredgecolor=nothing) =
	WfrmAttributes(label, color, linewidth, linestyle,
		marker, markersize, markerfacecolor, markeredgecolor, linewidth,
		nothing == markerfacecolor ? "none" : "full"
	)


#==Helper functions
===============================================================================#
const HEX_CODES = UInt8[
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
]
function int2mplcolorstr(v::UInt)
	result = Array{UInt8}(undef, 7) #6HEX+Hash symbol
	result[1] = '#'
	for i in length(result):-1:2
		result[i] = HEX_CODES[(v & 0xF)+1]
		v >>= 4
	end
	return String(result)
end

function mapcolor(v::Colorant)
	v = convert(RGB24, v)
	return int2mplcolorstr(UInt(v.color))
end
mapfacecolor(v) = mapcolor(v) #In case we want to diverge

#Linewidth:
maplinewidth(w) = w
maplinewidth(::Nothing) = maplinewidth(1) #default

#Marker size:
mapmarkersize(sz) = 5*sz
mapmarkersize(::Nothing) = mapmarkersize(1)

function maplinestyle(v::Symbol)
	result = get(linestylemap, v, NOTFOUND)
	if NOTFOUND == result
		@info("Line style not supported")
		result = maplinestyle(nothing)
	end
	return result
end
maplinestyle(::Nothing) = "-" #default

function mapmarkershape(v::Symbol)
	result = get(markermap, v, NOTFOUND)
	if NOTFOUND == result
		@info("Marker shape not supported")
		result = "o" #Use some supported marker
	end
	return result
end
mapmarkershape(::Nothing) = "" #default (no marker)

function WfrmAttributes(id::String, attr::EasyPlot.WfrmAttributes)
	markerfacecolor = attr.glyphfillcolor==EasyPlot.COLOR_TRANSPARENT ?
		nothing : mapfacecolor(attr.glyphfillcolor)

	return WfrmAttributes(label=id,
		color=mapcolor(attr.linecolor),
		linewidth=maplinewidth(attr.linewidth),
		linestyle=maplinestyle(attr.linestyle),
		marker=mapmarkershape(attr.glyphshape),
		markersize=mapmarkersize(attr.glyphsize),
		markerfacecolor=markerfacecolor,
		markeredgecolor = mapcolor(attr.glyphlinecolor),
	)
end


#==AbstractBuilder implementation
===============================================================================#
EasyPlot.needsfold(b::Builder) = b.fold

#Add DataF1 results:
function _addwfrm(ax, d::DataF1, a::WfrmAttributes)
	kwargs = Any[]
	for attrib in fieldnames(typeof(a))
		v = getfield(a,attrib)

		if v != nothing
			push!(kwargs, tuple(attrib, v))
		end
	end

	wfrm = ax.plot(d.x, d.y; kwargs...)
end

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(b::Builder, d::DataF1, id::String,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes, strip::Int)
	attr = EasyPlot.WfrmAttributes(b.theme, la, ga) #Apply theme to attributes
	mplattr = WfrmAttributes(id, attr) #Attributes understood by MPL
	_addwfrm(b.ref, d, mplattr)
end


#==Plot building functions
===============================================================================#

function build(ax, eplot::EasyPlot.Plot, theme::EasyPlot.Theme)
	ax.set_title(eplot.title)
	fold = isa(eplot.xaxis, EasyPlot.FoldedAxis) ? eplot.xaxis : nothing

	builder = Builder(ax, theme, fold)
	for (i, wfrm) in enumerate(eplot.wfrmlist)
		EasyPlot.addwfrm(builder, wfrm, i)
	end

	#x-axis properties:
	xscale = Symbol(eplot.xaxis)
	xmin = eplot.xext.min; xmax = eplot.xext.max

	#y-axis properties:
	ylabel = ""
	yscale = :lin
	ymin, ymax = (NaN, NaN)
	if length(eplot.ystriplist) > 0
		strip = eplot.ystriplist[1]
		ylabel = strip.axislabel
		yscale = strip.scale
		ymin = strip.ext.min; ymax = strip.ext.max
	end

	#Apply x/y labels:
	ax.set_xlabel(eplot.xlabel)
	ax.set_ylabel(ylabel)

	#Apply x/y scales:
	ax.set_xscale(scalemap[xscale])
	ax.set_yscale(scalemap[yscale])

	#Apply x/y extents:
	(c_xmin, c_xmax) = ax.set_xlim() #Read in current limits
		isnan(xmin) && (xmin = c_xmin); isnan(xmax) && (xmax = c_xmax)
		ax.set_xlim(xmin, xmax)
	(c_ymin, c_ymax) = ax.set_ylim() #Read in current limits
		isnan(ymin) && (ymin = c_ymin); isnan(ymax) && (ymax = c_ymax)
		ax.set_ylim(ymin, ymax)

	return ax
end

function build(fig::PyPlot.Figure, ecoll::EasyPlot.PlotCollection)
	ecoll = EasyPlot.condxfrm_multistrip(ecoll, "EasyPlotMPL") #Emulate multi-strip plots
	ncols = ecoll.ncolumns
	fig.suptitle(ecoll.title)
	nrows = div(length(ecoll.plotlist)-1, ncols)+1
	iplot = 0

	for plot in ecoll.plotlist
#		row = div(iplot, ncols) + 1
#		col = mod(iplot, ncols) + 1
		ax = fig.add_subplot(nrows, ncols, iplot+1)
		build(ax, plot, ecoll.theme)
		if ecoll.displaylegend; ax.legend(); end
		iplot += 1
	end

	fig.canvas.draw()
	return fig
end

#Last line
