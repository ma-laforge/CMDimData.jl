#EasyPlot plot builder interface (implemented by backends)
#-------------------------------------------------------------------------------

#=
Concerns with chosen EasyPlotBuilder implementation:
 - Garbage collection when you re-evaluate builder files?
   (evalfile() creates auto-named modules to house returned functions)

Alternative solutions considered:
 1. Implement functions for subtypes of EasyPlotBuilder (make EasyPlotBuilder abstract).
Concerns:
    - Too many `struct`s (basically one for each plot we define).
    - Objects might linger around more given loaded with evalfile() in load_plotbuilders()??
 2. Return references to modules created by load_plotbuilders() instead of EasyPlotBuilder objects
Concerns:
    - Users don't have a EasyPlotBuilder object to tell them how to structure their modules.
    - Garbage collection when you redefine module?
=#


#==Types
===============================================================================#
"""`struct EasyPlotBuilder`

Build `EasyPlot.Plot/PlotCollection` using data provided as `NamedTuple`.
"""
struct EasyPlotBuilder
	fnbuild::Function
end

#Dimension of entre plot canvas (distinct from PlotDim, but same values)
struct CanvasDim <: AbstractPlotDimensions
	w::Int; h::Int
end

mutable struct ShowOptions <: AbstractAttributeReceiver
	dim::AbstractPlotDimensions
end
_ShowOptions() = ShowOptions(plotautosize)
ShowOptions(args...; kwargs...) = _apply(_ShowOptions(), args, kwargs)

#Target application:
struct Target{T}; end
Target(id::Symbol) = Target{id}()

"""`abstract type AbstractBuilder`

Builds native plots (`NP`) from `EasyPlot.Plot/PlotCollection` objects.

Backend modules must implement a concrete builder object (`CB`), which generates
native plots.

# Must implement:
 - Member: `.postproc::Optional{Function}` with function signature `.postproc(plot::NP)`
 - `AbstractBuilder(::DS{:CB_ID}) = CB` (register symbol=>object mapping)
 - `getbuilder(::Target{T}, ::Type{CB}, args...; postproc=fn, kwargs...)` where T ∈ {:gui, :image}
   (args & kwargs are optional).
 - `build(b::CB, pcoll::PlotCollection)`
 - `_showable(mime::MIME, ::CB)`
 - `_show(io::IO, mime::MIME, opt::ShowOptions, plot::NP)`
"""
abstract type AbstractBuilder; end


#==Helper functions
===============================================================================#
function postproc(b::AbstractBuilder, plot)
	if !isnothing(b.postproc)
		b.postproc(plot)
	end
	return plot
end


#==EasyPlotBuilder interface:
===============================================================================#
function build(pf::EasyPlotBuilder, data::NamedTuple)
	plot = pf.fnbuild(data)
	@assert(isa(plot, PlotCollection), "EasyPlotBuilder.fnbuild() must return EasyPlot.PlotCollection")
	return plot
end

"""
`load_plotbuilders(@__DIR__, id1="gen1.jl", id2="gen2.jl", ...)`

Loads EasyPlotBuilder definitions from given files.

# Outputs
Returns a Dict of EasyPlotBuilder objects.

# NOTE
Must run from global scope to avoid world-age issue (code loading).
"""
function load_plotbuilders(rootpath::String; kwargs...)
#	outfile=splitext(filepath)[1] * ".svg"
	fmtlist = Dict{Symbol, EasyPlotBuilder}()
	for (k,filepath) in kwargs
		push!(fmtlist, k=>evalfile(joinpath(rootpath, filepath)))
	end
	return fmtlist
end


#==AbstractBuilder interface:
===============================================================================#
#(Includes catch-all functions/placeholders)

#Maps a symbol => concrete builder type:
AbstractBuilder(ds::DS{T}) where T = throw(MethodError(AbstractBuilder, (ds,)))
AbstractBuilder(bid::Symbol) = AbstractBuilder(DS(bid))

getbuilder(::Target{TS}, ::Type{T}, args...; kwargs...) where {TS, T} =
	throw(MethodError(getbuilder, (TS, T)))

"""`getbuilder(target::Symbol, builderid::Symbol, args...; kwargs...)`

Return a <: AbstractBuilder object specific to a `builderid` backend , yet
appropriate for use in a `target` application.

#Arugments
 - `target`: should be one of: `{:gui, :image}`.
 - `builderid`: should be one of: {:InspectDR, :Grace, :Grace_headless,
   :PyPlot, :PlotsJl}
"""
getbuilder(target::Symbol, builderid::Symbol, args...; kwargs...) where T =
	getbuilder(Target(target), AbstractBuilder(builderid), args...; kwargs...)

build(b::AbstractBuilder, pcoll::PlotCollection) = throw(MethodError(build, (b, plot)))

_showable(mime::MIME, b::AbstractBuilder) = throw(MethodError(Base.showable, (mime,b)))

#To be implemented by backend:
function _show(io::IO, mime::MIME, opt::ShowOptions, nativeplot::T) where T
	error("EasyPlot._show: no support for plots of type $T.")
end


#==Implement _apply() methods for ShowOptions
===============================================================================#
function _apply(opt::ShowOptions, ::DS{:plotdim}; w::Int=nothing, h::Int=nothing)
	if isnothing(w) || isnothing(h)
		throw(ArgumentError("set(`::ShowOptions`, plotdim=...): must specify w::Int & h::Int."))
	end
	opt.dim = PlotDim(w, h)
end

function _apply(opt::ShowOptions, ::DS{:dim}; w::Int=nothing, h::Int=nothing)
	if isnothing(w) || isnothing(h)
		throw(ArgumentError("set(`::ShowOptions`, dim=...): must specify w::Int & h::Int."))
	end
	opt.dim = CanvasDim(w, h)
end

#Last line
