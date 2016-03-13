#EasyPlotPlots base types & core functions
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#

#TODO: deprecate:
const scalemap = Dict{Symbol, Symbol}(
	:lin => :identity,
	:log => :log10,
)
#:identity, :ln, :log2, :log10, :asinh, :sqrt

#="linetype" values
:none, :line, :sticks, :bar, :hist,
:scatter, :scatter3d,
:path, :path3d,
:contour, :density, :heatmap, :hexbin,
:surface, :wireframe
:steppost, :steppre,
:hline, :vline
=#

const linestylemap = Dict{Symbol, Symbol}(
	:none    => :auto, #Will modify linetype to cover "none".
	:solid   => :solid,
	:dash    => :dash,
	:dot     => :dot,
	:dashdot => :dashdot,
)
#:auto, :dash, :dashdot, :dot, :solid

const markermap = Dict{Symbol, Symbol}(
	:none    => :none,
	:square    => :rect,
	:diamond   => :diamond,
	:uarrow    => :utriangle, :darrow => :dtriangle,
	:larrow    => :utriangle, :darrow => :dtriangle, #NOT SUPPORTED
	:cross     => :cross, :+ => :cross,
	:diagcross => :xcross, :x => :xcross,
	:circle    => :ellipse, :o => :ellipse,
	:star      => :star5, :* => :star5,
)

#=
:auto, :none, 
:cross, :xcross
:ellipse, :rect, :diamond, :dtriangle, :utriangle,
:heptagon, :hexagon, :octagon, :pentagon,
:star4, :star5, :star6, :star7, :star8
=#

const NOMULTISUPPORT = Set([:gr])

immutable FlagType{T}; end
const NOTFOUND = FlagType{:NOTFOUND}()


#==Base types
===============================================================================#
typealias NullOr{T} Union{Void, T} #Simpler than Nullable

type Axes{T} <: EasyPlot.AbstractAxes{T}
	ref::Plots.Plot #Axes reference
	theme::EasyPlot.Theme
	eye::NullOr{EasyPlot.EyeAttributes}
end
Axes(style::Symbol, ref, theme::EasyPlot.Theme, eye=nothing) =
	Axes{style}(ref, theme, eye)


#Top-level plot (which might contain subplots)
abstract Figure

type FigureSng <: Figure #For backends that support single plots only (no subplots)
	subplots::Vector{Plots.Plot}
end
FigureSng() = FigureSng(Plots.Plot[])

type FigureMulti <: Figure #For backends that support subplots
	subplots::NullOr{Plots.Subplot} #Actually contains all subplots
end
FigureMulti() = FigureMulti(nothing)

Figure(toolid::Symbol) =
	in(toolid, NOMULTISUPPORT)? FigureSng(): FigureMulti()

#Immutable? would be on stack...
type WfrmAttributes
	label::NullOr{AbstractString}

	linetype::Symbol
	linestyle::Symbol
	linewidth::Float64
	linecolor::Colorant
#	linealpha

	markershape::Symbol
	markersize::Float64
	markercolor::Colorant #Fill color
#	fillalpha::Float64 #Does nothing?
	markeralpha::Float64 #Apperently entire marker
	markerstrokewidth::Float64
	markerstrokecolor::Colorant
end


#==Constructor-like functions
===============================================================================#
function addsubplots(fig::FigureSng, ncols::Int, nsubplots::Int)
	for i in 1:nsubplots
		push!(fig.subplots, Plots.plot())
	end
	return fig
end
function addsubplots(fig::FigureMulti, ncols::Int, nsubplots::Int)
	fig.subplots = Plots.subplot(nc=ncols, n=nsubplots)
	return fig
end


#==Helper functions
===============================================================================#
getsubplot(p::FigureSng, idx::Int) = p.subplots[idx]
getsubplot(p::FigureMulti, idx::Int) = p.subplots.plts[idx]

#Linewidth:
maplinewidth(w) = w
maplinewidth(::Void) = maplinewidth(1) #default

#Marker size:
mapmarkersize(sz) = 5*sz
mapmarkersize(::Void) = mapmarkersize(1)

function maplinetype(v::Symbol) #Only support small subset of linetype values
	if :none == v
		return :none
	else
		return :line
	end
end
maplinetype(::Void) = :line #default

function maplinestyle(v::Symbol)
	result = get(linestylemap, v, NOTFOUND)
	if NOTFOUND == result
		info("Line style not supported")
		result = maplinestyle(nothing)
	end
	return result
end
maplinestyle(::Void) = :solid #default

function mapmarkershape(v::Symbol)
	result = get(markermap, v, NOTFOUND)
	if NOTFOUND == result
		info("Marker shape not supported")
		result = "o" #Use some supported marker
	end
	return result
end
mapmarkershape(::Void) = "" #default (no marker)

function WfrmAttributes(id::AbstractString, attr::EasyPlot.WfrmAttributes)
	linewidth = maplinewidth(attr.linewidth)
	markercolor = attr.glyphfillcolor
	markeralpha = 1.0
	if	markercolor == EasyPlot.COLOR_TRANSPARENT
		markeralpha = 0.0
		markercolor = EasyPlot.COLOR_WHITE  #Use a solid color, just in case
	end

	return WfrmAttributes(id,
		maplinetype(attr.linestyle),
		maplinestyle(attr.linestyle),
		linewidth,
		attr.linecolor,

		mapmarkershape(attr.glyphshape),
		mapmarkersize(attr.glyphsize),
		markercolor, markeralpha,
		linewidth,
		attr.glyphlinecolor,
	)
end


#==Rendering functions
===============================================================================#
displaylegend(fig::FigureSng, v::Bool) = nothing
displaylegend(fig::FigureMulti, v::Bool) = Plots.subplot!(fig.subplots, legend=v)

#Add DataF1 results:
function _addwfrm(ax::Plots.Plot, d::DataF1, a::WfrmAttributes)
	kwargs = Any[]
	for attrib in fieldnames(a)
		v = getfield(a,attrib)

		if v != nothing
			push!(kwargs, tuple(attrib, v))
		end
	end

	wfrm = plot!(ax, d.x, d.y; kwargs...)
end

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(ax::Axes, d::DataF1, id::AbstractString,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes)
	attr = EasyPlot.WfrmAttributes(ax.theme, la, ga) #Apply theme to attributes
	plotsattr = WfrmAttributes(id, attr) #Attributes understood by Plots.jl
	_addwfrm(ax.ref, d, plotsattr)
end

function rendersubplot(ax::Plots.Plot, subplot::EasyPlot.Subplot, theme::EasyPlot.Theme)
	Plots.title!(ax, subplot.title)


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
#=
	#Update axis limits:
	(xmin, xmax) = ax[:set_xlim]()
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	(ymin, ymax) = ax[:set_ylim]()
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	ax[:set_xlim](xmin, xmax)
	ax[:set_ylim](ymin, ymax)
	#@show Plots.ylims!(1,5) #Cannot find way to read current limits
=#	

	#Apply x/y scales:
	_xscale = scalemap[srca.xscale]
	_yscale = scalemap[srca.yscale]
	#Not working:
#	Plots.xscale!(ax, scalemap[srca.xscale])
#	Plots.yscale!(ax, scalemap[srca.yscale])
	Plots.plot!(ax, xscale=_xscale, yscale=_yscale)

	#Apply x/y labels:
	if srca.xlabel != nothing; Plots.xlabel!(ax, srca.xlabel); end
	if srca.ylabel != nothing; Plots.ylabel!(ax, srca.ylabel); end

	return ax
end

function render(fig::Figure, eplot::EasyPlot.Plot)
	ncols = eplot.ncolumns
	nsubplots = length(eplot.subplots)
	plt = addsubplots(fig, ncols, nsubplots)
	displaylegend(fig, eplot.displaylegend)

	for (i, s) in enumerate(eplot.subplots)
		ax = getsubplot(fig, i)
		rendersubplot(ax, s, eplot.theme)
	end

	return fig
end

#Last line
