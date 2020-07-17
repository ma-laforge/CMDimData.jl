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

struct FlagType{T}; end
const NOTFOUND = FlagType{:NOTFOUND}()


#==Base types
===============================================================================#
const NullOr{T} = Union{Nothing, T} #Simpler than Nullable

mutable struct Axes{T} <: EasyPlot.AbstractAxes{T}
	ref::PyCall.PyObject #Axes reference
	theme::EasyPlot.Theme
	eye::NullOr{EasyPlot.EyeAttributes}
end
Axes(style::Symbol, ref, theme::EasyPlot.Theme, eye=nothing) =
	Axes{style}(ref, theme, eye)

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


#==Rendering functions
===============================================================================#

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
function EasyPlot.addwfrm(ax::Axes, d::DataF1, id::String,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes)
	attr = EasyPlot.WfrmAttributes(ax.theme, la, ga) #Apply theme to attributes
	mplattr = WfrmAttributes(id, attr) #Attributes understood by MPL
	_addwfrm(ax.ref, d, mplattr)
end

function rendersubplot(ax, subplot::EasyPlot.Subplot, theme::EasyPlot.Theme)
	ax.set_title(subplot.title)

	#TODO Ugly: setting defaults like this should be done in EasyPlot
	ep = nothing
	if :eye == subplot.style
		ep = subplot.eye
		if nothing == ep.teye; ep.teye = ep.tbit; end
	end

	axes = Axes(subplot.style, ax, theme, ep)

	for (i, wfrm) in enumerate(subplot.wfrmlist)
		EasyPlot.addwfrm(axes, wfrm, i)
	end

	srca = subplot.axes

	#Update axis limits:
	(xmin, xmax) = ax.set_xlim()
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	(ymin, ymax) = ax.set_ylim()
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	ax.set_xlim(xmin, xmax)
	ax.set_ylim(ymin, ymax)

	#Apply x/y scales:
	ax.set_xscale(scalemap[srca.xscale])
	ax.set_yscale(scalemap[srca.yscale])
	
	#Apply x/y labels:
	if srca.xlabel != nothing; ax.set_xlabel(srca.xlabel); end
	if srca.ylabel != nothing; ax.set_ylabel(srca.ylabel); end

	return ax
end

function render(fig::PyPlot.Figure, eplot::EasyPlot.Plot)
	ncols = eplot.ncolumns
	fig.suptitle(eplot.title)
	nrows = div(length(eplot.subplots)-1, ncols)+1
	subplotidx = 0

	for s in eplot.subplots
#		row = div(subplotidx, ncols) + 1
#		col = mod(subplotidx, ncols) + 1
		ax = fig.add_subplot(nrows, ncols, subplotidx+1)
		rendersubplot(ax, s, eplot.theme)
		if eplot.displaylegend; ax.legend(); end
		subplotidx += 1
	end

	fig.canvas.draw()
	return fig
end

#Last line
