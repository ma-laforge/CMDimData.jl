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

const linestylemap = Dict{Symbol, Symbol}(
	:none    => :none,
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
#:auto, :none, 
:cross, :xcross
:ellipse, :rect, :diamond, :dtriangle, :utriangle,
:heptagon, :hexagon, :octagon, :pentagon,
:star4, :star5, :star6, :star7, :star8
=#

immutable FlagType{T}; end
const NOTFOUND = FlagType{:NOTFOUND}()


#==Backend-related stuff
===============================================================================#
typealias BkndMPL     EasyPlot.Backend{:Plots_MPL}
typealias BkndGadfly  EasyPlot.Backend{:Plots_Gadfly}
typealias BkndWinston EasyPlot.Backend{:Plots_Winston}
typealias BkndBokeh   EasyPlot.Backend{:Plots_Bokeh}
typealias BkndQwt     EasyPlot.Backend{:Plots_Qwt}
typealias BkndGR      EasyPlot.Backend{:Plots_GR}

typealias SupportedBackends Union{BkndMPL, BkndQwt, BkndGadfly, BkndWinston, BkndBokeh, BkndQwt, BkndGR}

#Backends that do *not* support subplots
typealias NonMultiBackends Union{BkndWinston, BkndBokeh, BkndGR}

#backend symbol recognized by Plots.backend()
Plots_bkndsymbol(::BkndMPL) = :pyplot
Plots_bkndsymbol(::BkndGadfly) = :gadfly
Plots_bkndsymbol(::BkndWinston) = :winston
Plots_bkndsymbol(::BkndBokeh) = :bokeh
Plots_bkndsymbol(::BkndQwt) = :qwt
Plots_bkndsymbol(::BkndGR) = :gr


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
abstract AbstractPlot

type PlotSng #Supports single plots only (no subplots)
	subplots::Vector{Plots.Plot}
end

type PlotMulti #Supports subplots
	subplots::Plots.Subplot #Actually contains all subplots
end

#Immutable? would be on stack...
type WfrmAttributes
#	linetype #:bar, :contour, :density, :heatmap, :hexbin, :hist, :hline, :line, :none

	label::NullOr{AbstractString}

	linestyle::Symbol
	linewidth::Float64
	linecolor::Colorant
#	linealpha

	markershape::Symbol
	markersize::Float64
	markercolor::Colorant #Fill color
	fillalpha::Float64 #Does nothing?
	markerstrokewidth::Float64
	markerstrokecolor::Colorant
#	markeralpha #Apperently entire marker
end


#==Constructor-like functions
===============================================================================#
function buildplot(BT::NonMultiBackends, ncols::Int, nsubplots::Int)
	subplots = Plots.Plot[]
	for i in 1:nsubplots
		push!(subplots, Plots.plot())
	end
	return PlotSng(subplots)
end
function buildplot(BT::EasyPlot.Backend, ncols::Int, nsubplots::Int)
	subplots = Plots.subplot(nc=ncols, n=nsubplots)
	return PlotMulti(subplots)
end


#==Helper functions
===============================================================================#
getsubplot(p::PlotSng, idx::Int) = p.subplots[idx]
getsubplot(p::PlotMulti, idx::Int) = p.subplots.plts[idx]

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
	fillalpha = 1.0
	if	markercolor == EasyPlot.COLOR_TRANSPARENT
		fillalpha = 0.0 #Does not work, as of yet
		markercolor = EasyPlot.COLOR_WHITE  #Workaround... Background color?
	end

	return WfrmAttributes(id,
		maplinestyle(attr.linestyle),
		linewidth,
		attr.linecolor,

		mapmarkershape(attr.glyphshape),
		mapmarkersize(attr.glyphsize),
		markercolor, fillalpha,
		linewidth,
		attr.glyphlinecolor,
	)
end


#==Rendering functions
===============================================================================#

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


#Would normally trap ::Figure, but Plots.jl does not have this
function _render(BT::SupportedBackends, eplot::EasyPlot.Plot; ncols::Int=1)
	nsubplots = length(eplot.subplots)
	bknd = Plots.backend(Plots_bkndsymbol(BT)) #Activate backend
	plt = buildplot(BT, ncols, nsubplots)

	for (i, s) in enumerate(eplot.subplots)
		ax = getsubplot(plt, i)
		rendersubplot(ax, s, eplot.theme)
#		if eplot.displaylegend; ax[:legend](); end
	end

	return plt.subplots
end


#==EasyPlot-level rendering functions
===============================================================================#

function EasyPlot.render(BT::SupportedBackends, plot::EasyPlot.Plot, args...; ncols::Int=1, kwargs...)
	#fig = PyPlot.figure(args...; kwargs...) #No figure, so ignore kwargs???
	return _render(BT, plot, ncols=ncols)
end

#NOTE: Display already defined in Plots.jl
#function Base.display{T<:Plots.Plot}(d::Display, v::Vector{T})
function Base.display{T<:Plots.Plot}(v::Vector{T})
	for p in v
		display(p)
	end
end

#Last line
