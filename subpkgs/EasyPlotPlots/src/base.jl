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

#const NOMULTISUPPORT = Set([:gr]) #GR now supported using multiplot model.
const NOMULTISUPPORT = Set([])


#==Base types
===============================================================================#
mutable struct WfrmBuilder <: EasyPlot.AbstractWfrmBuilder
	subplot::Plots.Subplot #Axes reference
	theme::EasyPlot.Theme
	fold::Optional{EasyPlot.FoldedAxis}
end


#Top-level plot (which might contain subplots)
abstract type Figure end

#TODO: Is this workaround still needed??
mutable struct FigureSng <: Figure #For backends that support single plots only (no subplots)
	subplots::Vector{Plots.Plot}
end
FigureSng() = FigureSng(Plots.Plot[])

mutable struct FigureMulti <: Figure #For backends that support subplots
	p::Optional{Plots.Plot} #Optional - So construction does not display anything.
#	subplots::Vector{Plots.Subplot}
end
FigureMulti() = FigureMulti(Plots.plot(overwrite_figure=false))

Figure(backend::Symbol) =
	in(backend, NOMULTISUPPORT) ? FigureSng() : FigureMulti()

#Immutable? would be on stack...
mutable struct WfrmAttributes
	label::Optional{String}

	linetype::Symbol
	linestyle::Symbol
	linewidth::Float64
	linecolor::Colorant
#	linealpha

	markershape::Symbol
	markersize::Float64
	markercolor::Colorant #Fill color
	markeralpha::Float64 #Apperently entire marker
	markerstrokewidth::Float64
	markerstrokecolor::Colorant
	markerstrokealpha::Float64
	markerstrokestyle::Symbol
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
	nrows = div(nsubplots-1, ncols) + 1
	fig.p = Plots.plot(layout=(nrows, ncols), overwrite_figure=true)
	return fig
end


#==Helper functions
===============================================================================#
getsubplot(fig::FigureSng, idx::Int) = fig.subplots[idx]
getsubplot(fig::FigureMulti, idx::Int) = fig.p.subplots[idx]

#Linewidth:
maplinewidth(w) = w
maplinewidth(::Nothing) = maplinewidth(1) #default

#Marker size:
mapmarkersize(sz) = 5*sz
mapmarkersize(::Nothing) = mapmarkersize(1)

function maplinetype(v::Symbol) #Only support small subset of linetype values
	if :none == v
		return :none
	else
		return :line
	end
end
maplinetype(::Nothing) = :line #default

function maplinestyle(v::Symbol)
	result = get(linestylemap, v, missing)
	if ismissing(result)
		@info("Line style not supported")
		result = maplinestyle(nothing)
	end
	return result
end
maplinestyle(::Nothing) = :solid #default

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
	linewidth = maplinewidth(attr.linewidth)

	#Marker line
	markerstrokecolor = attr.glyphlinecolor
	markerstrokealpha = Colors.alpha(markerstrokecolor)

	#Marker fill:
	markercolor = attr.glyphfillcolor
	markeralpha = Colors.alpha(markercolor)

	#WARNING: In GR backend, markeralpha is applied to marker line!

	return WfrmAttributes(id,
		maplinetype(attr.linestyle),
		maplinestyle(attr.linestyle),
		linewidth,
		attr.linecolor,

		mapmarkershape(attr.glyphshape),
		mapmarkersize(attr.glyphsize),
		markercolor, markeralpha,
		linewidth,
		markerstrokecolor, markerstrokealpha,
		:solid, #markerstrokestyle
	)
end


#==AbstractWfrmBuilder implementation
===============================================================================#
EasyPlot.needsfold(b::WfrmBuilder) = b.fold

#Add DataF1 results:
function _addwfrm(sp::Plots.Subplot, d::DataF1, a::WfrmAttributes)
	kwargs = Any[]
	for attrib in fieldnames(WfrmAttributes)
		v = getfield(a,attrib)

		if v != nothing
			push!(kwargs, tuple(attrib, v))
		end
	end

	wfrm = plot!(sp, d.x, d.y; kwargs...)
end

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(b::WfrmBuilder, d::DataF1, id::String,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes, strip::Int)
	attr = EasyPlot.WfrmAttributes(b.theme, la, ga) #Apply theme to attributes
	plotsattr = WfrmAttributes(id, attr) #Attributes understood by Plots.jl
	_addwfrm(b.subplot, d, plotsattr)
end

#Last line
