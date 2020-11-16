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


#==Base types
===============================================================================#
mutable struct WfrmBuilder <: EasyPlot.AbstractWfrmBuilder
	ref::PyCall.PyObject #"Axes" reference
	theme::EasyPlot.Theme
	fold::Optional{EasyPlot.FoldedAxis}
end

#Keeps key features of Matplotlib/PyPlot state needed for plotting
mutable struct MPLState
	interactive::Bool
	backend::Symbol
	guimode::Bool
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


#==GUI state control
===============================================================================#
function _getstate()
	return MPLState(
		PyPlot.matplotlib.is_interactive(),
		PyPlot.pygui(),
		!PyPlot.isjulia_display[1], #TODO: Hack!... not part of PyPlot interface.
	)
end

function _applystate(s::MPLState)
	PyPlot.pygui(s.backend)
	PyPlot.pygui(s.guimode)
#@show pygui(), PyPlot.isjulia_display[1]
	#Must be applied last (in case backend does not support interactive):
	PyPlot.matplotlib.interactive(s.interactive)
end


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
	result = get(linestylemap, v, missing)
	if ismissing(result)
		@info("Line style not supported")
		result = maplinestyle(nothing)
	end
	return result
end
maplinestyle(::Nothing) = "-" #default

function mapmarkershape(v::Symbol)
	result = get(markermap, v, missing)
	if ismissing(result)
		@info("Marker shape not supported")
		result = "o" #Use some supported marker
	end
	return result
end
mapmarkershape(::Nothing) = "" #default (no marker)

function WfrmAttributes(id::String, attr::EasyPlot.WfrmAttributes)
	markerfacecolor = attr.glyphfillcolor==colorant"transparent" ?
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


#==AbstractWfrmBuilder implementation
===============================================================================#
EasyPlot.needsfold(b::WfrmBuilder) = b.fold

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
function EasyPlot.addwfrm(b::WfrmBuilder, d::DataF1, id::String,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes, strip::Int)
	attr = EasyPlot.WfrmAttributes(b.theme, la, ga) #Apply theme to attributes
	mplattr = WfrmAttributes(id, attr) #Attributes understood by MPL
	_addwfrm(b.ref, d, mplattr)
end

#Last line
