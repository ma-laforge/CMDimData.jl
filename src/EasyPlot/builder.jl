#EasyPlot plot builder interface (implemented by backends)
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
mutable struct ShowOptions
	dim::AbstractPlotDimensions
end
ShowOptions() = ShowOptions(plotautosize)

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


#==Constructors
===============================================================================#
function ShowOptions(a::AttributeChangeData)
	return ShowOptions() #For now
end


#==AbstractBuilder interface:
===============================================================================#
#(Includes catch-all functions/placeholders)

#Maps a symbol => concrete builder type:
AbstractBuilder(ds::DS{T}) where T = throw(MethodError(AbstractBuilder, (ds,)))
AbstractBuilder(bid::Symbol) = AbstractBuilder(DS(bid))

getbuilder(::Target{TS}, ::Type{T}, args...; kwargs...) where {TS, T} =
	throw(MethodError(getbuilder, (TS, T)))
getbuilder(target::Symbol, builderid::Symbol, args...; kwargs...) where T =
	getbuilder(Target(target), AbstractBuilder(builderid), args...; kwargs...)

build(b::AbstractBuilder, pcoll::PlotCollection) = throw(MethodError(build, (b, plot)))

_showable(mime::MIME, b::AbstractBuilder) = throw(MethodError(Base.showable, (mime,b)))

#To be implemented by backend:
function _show(io::IO, mime::MIME, opt::ShowOptions, nativeplot::T) where T
	error("EasyPlot._show: no support for plots of type $T.")
end

#Last line
