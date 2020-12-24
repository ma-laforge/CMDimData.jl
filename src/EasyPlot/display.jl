#EasyPlot display facilities
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
const PlotOrColl = Union{Plot, PlotCollection}

abstract type AbstractPlotDisplay{T<:AbstractBuilder} <: AbstractDisplay end

struct GUIDisplay{T} <: AbstractPlotDisplay{T}
	builder::T
end

#Not implemented:
#-------------------------------------------------------------------------------
struct FileDisplay{T} <: AbstractPlotDisplay{T}; end #Render image to file
struct SocketDisplay{T} <: AbstractPlotDisplay{T}; end #Render image to listener (is there a useful protocol for this?)
#Find way to only load GUI libraries if needed:
struct WindowDisplay{T} <: AbstractPlotDisplay{T}; end #Render image to a pop-up window 


#==Constructors
===============================================================================#
GUIDisplay(builderid::Symbol, args...; kwargs...) =
	GUIDisplay(getbuilder(:gui, builderid, args...; kwargs...))


#==displaygui() interface (user-facing)
===============================================================================#
#`displaygui()` used instead of `Base.display` so as to not break Juila display system.

displaygui(nativeplot::T) where T =
	throw("displaygui: no support for plots of type $T.")

function displaygui(b::AbstractBuilder, pcoll::PlotCollection)
	plotgui = displaygui(build(b, pcoll))
	postproc(b, plotgui)
end
function displaygui(b::AbstractBuilder, plot::Plot)
	plotgui = displaygui(b, push!(PlotCollection(ncolumns = 1), plot))
	postproc(b, plotgui)
end

displaygui(bid::Symbol, plot::PlotOrColl) = 
	displaygui(GUIDisplay(bid).builder, plot)

function displaygui(plot::PlotOrColl)
	if isnothing(defaults.guibuilder)
		@warn("EasyPlot.defaults.guibuilder not initialized.")
		return
	end
	displaygui(defaults.guibuilder, plot)
end


#==Implement Base.display() interface:
===============================================================================#
Base.display(d::GUIDisplay, plot::PlotOrColl) = displaygui(d.builder, plot)

#Last line
