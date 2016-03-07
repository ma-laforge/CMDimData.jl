#EasyPlotQwt base types & core functions
#-------------------------------------------------------------------------------

#==Constants
===============================================================================#

#TODO: Support transparent, or *read* plot background color somehow.
const COLOR_BACKGROUND = EasyPlot.COLOR_WHITE

const scalemap = Dict{Symbol, ASCIIString}(
	:lin => "lin",
	:log => "log",
)

const linestylemap = Dict{Symbol, ASCIIString}(
	:none    => "",
	:solid   => "-",
	:dash    => "--",
	:dot     => ":",
	:dashdot => "-.",
)

const markermap = Dict{Symbol, ASCIIString}(
	:none      => "",
	:square    => "s",
	:diamond   => "d",
	:uarrow    => "^", :darrow => "v",
	:larrow    => "<", :rarrow => ">",
	:cross     => "+", :+ => "+",
	:diagcross => "x", :x => "x",
	:circle    => "o", :o => "o",
	:star      => "*", :* => "*",
)

immutable FlagType{T}; end
const NOTFOUND = FlagType{:NOTFOUND}()

#==Base types
===============================================================================#
typealias NullOr{T} Union{Void, T} #Simpler than Nullable

type EPAxes{T} <: EasyPlot.AbstractAxes{T}
	ref::Axes #Axes reference
	theme::EasyPlot.Theme
	eye::NullOr{EasyPlot.EyeAttributes}
end
EPAxes(style::Symbol, ref::Axes, theme::EasyPlot.Theme, eye=nothing) =
	EPAxes{style}(ref, theme, eye)

type WfrmAttributes
	title #Not label, for some reason
	color #linecolor
	linewidth
	linestyle
	marker
	markersize
	markerfacecolor
	markeredgecolor
#	markeredgewidth #Not supported
#	fillstyle #Not supported
#==Unknown options:
	shade, fitted, curvestyle, curvetype, baseline
==#
end
WfrmAttributes(;label=nothing,
	color=nothing, linewidth=nothing, linestyle=nothing,
	marker=nothing, markersize=nothing, markerfacecolor=nothing) =
	WfrmAttributes(label, color, linewidth, linestyle,
		marker, markersize, markerfacecolor, color
	)


#==Helper functions
===============================================================================#
const HEX_CODES = UInt8[
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
]
function int2mplcolorstr(v::UInt)
	result = Array(UInt8, 7)
	result[1] = '#'
	for i in length(result):-1:2
		result[i] = HEX_CODES[(v & 0xF)+1]
		v >>= 4
	end
	return bytestring(result)
end

function mapcolor(v::Colorant)
	v = convert(RGB24, v)
	return int2mplcolorstr(UInt(v.color))
end

mapfacecolor(v) = mapcolor(v) #In case we want to diverge

#Linewidth:
maplinewidth(w) = w
maplinewidth(::Void) = maplinewidth(1) #default

#Marker size:
mapmarkersize(sz) = 5*sz
mapmarkersize(::Void) = mapmarkersize(1)

function maplinestyle(v::Symbol)
	result = get(linestylemap, v, NOTFOUND)
	if NOTFOUND == result
		info("Line style not supported")
		result = maplinestyle(nothing)
	end
	return result
end
maplinestyle(::Void) = "-" #default

function mapmarkershape(v::Symbol)
	result = get(markermap, v, NOTFOUND)
	if "" == result
		result = nothing
	elseif NOTFOUND == result
		info("Marker shape not supported")
		result = "o" #Use some supported marker
	end
	return result
end
mapmarkershape(::Void) = mapmarkershape(:none) #default (no marker)

function WfrmAttributes(id::AbstractString, attr::EasyPlot.WfrmAttributes)
	#TODO: Figure out how to support transparency:
	markerfacecolor = attr.glyphfillcolor==EasyPlot.COLOR_TRANSPARENT?
		mapfacecolor(COLOR_BACKGROUND): mapfacecolor(attr.glyphfillcolor)

	return WfrmAttributes(label=id,
		color=mapcolor(attr.linecolor),
		linewidth=maplinewidth(attr.linewidth),
		linestyle=maplinestyle(attr.linestyle),
		marker=mapmarkershape(attr.glyphshape),
		markersize=mapmarkersize(attr.glyphsize),
		markerfacecolor=markerfacecolor,
	)
end

function _setlim(ax::Axes, setfn::Symbol, _min, _max)
	hasmin = nothing!=min
	hasmax = nothing!=max
	if hasmin && hasmax
		ax[setfn] = (_min, _max)
	elseif (hasmin && !hasmax) || (hasmax && !hasmin)
		warn("Partial limits not supported: $setfn($_min, $_max)")
	end
end


#==Rendering functions
===============================================================================#

#Add DataF1 results:
function _addwfrm(ax::Axes, d::DataF1, a::WfrmAttributes)
	kwargs = Any[]
	for attrib in fieldnames(a)
		v = getfield(a,attrib)

		if v != nothing
			push!(kwargs, tuple(attrib, v))
		end
	end

	#TODO: is result of add the "wfrm" we want to return?
	wfrm = Curve(d.x, d.y; kwargs...)
	add(ax, wfrm)
	return wfrm
end

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(ax::EPAxes, d::DataF1, id::AbstractString,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes)
	attr = EasyPlot.WfrmAttributes(ax.theme, la, ga) #Apply theme to attributes
	qwtattr = WfrmAttributes(id, attr) #Attributes understood by Qwt
	_addwfrm(ax.ref, d, qwtattr)
end

function rendersubplot(ax::Axes, subplot::EasyPlot.Subplot, theme::EasyPlot.Theme)
	#TODO: add support for supblot title

	#TODO Ugly: setting defaults like this should be done in EasyPlot
	ep = nothing
	if :eye == subplot.style
		ep = subplot.eye
		if nothing == ep.teye; ep.teye = ep.tbit; end
	end

	axes = EPAxes(subplot.style, ax, theme, ep)

	for (i, wfrm) in enumerate(subplot.wfrmlist)
		EasyPlot.addwfrm(axes, wfrm, i)
	end

	srca = subplot.axes

	#Update axis limits:
	_lim = ax[:xlimits]
	(xmin, xmax) = _lim != nothing? _lim: (nothing, nothing)
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	_lim = ax[:ylimits]
	(ymin, ymax) = _lim != nothing? _lim: (nothing, nothing)
	if srca.ymin != nothing; ymin = srca.ymin; end
	if srca.ymax != nothing; ymax = srca.ymax; end
	_setlim(ax, :set_xlim, xmin, xmax)
	_setlim(ax, :set_ylim, ymin, ymax)

	#Apply x/y scales:
	ax[:xscale] = scalemap[srca.xscale]
	ax[:yscale] = scalemap[srca.yscale]
	
	#Apply x/y labels:
	if srca.xlabel != nothing; ax[:xlabel] = (string(srca.xlabel), ""); end
	if srca.ylabel != nothing; ax[:ylabel] = (string(srca.ylabel), ""); end

	return ax
end

function render(fig::Figure, eplot::EasyPlot.Plot; ncols::Int=1)
	nrows = div(length(eplot.subplots)-1, ncols)+1
	subplotidx = 0

	for s in eplot.subplots
#		row = div(subplotidx, ncols) + 1
#		col = mod(subplotidx, ncols) + 1
		ax = subplot(fig, nrows, ncols, subplotidx+1)
		rendersubplot(ax, s, eplot.theme)
		if eplot.displaylegend; add(ax, :legend); end
		subplotidx += 1
	end

	return fig
end


#==EasyPlot-level rendering functions
===============================================================================#

function Base.show(fig::Figure, args...; kwargs...)
	fig[:show]()

#=IMPORTANT:
	#PyCall.pygui_start(:qt_pyqt4) seems to handle QT events in background thread.
	#For blocking show(), the following can be used instead:
	app = GUICore.qapplication()
	app[:exec_]() #Process app events (modal)
=#
end

function EasyPlot.render(::EasyPlot.Backend{:Qwt}, plot::EasyPlot.Plot, args...; ncols::Int=1, kwargs...)
	fig = Figure()
	return render(fig, plot, ncols=ncols)
end

function Base.display(fig::Figure)
	show(fig)
	return fig
end

#Last line
