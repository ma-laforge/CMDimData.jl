#EasyPlot: A quick/easy way to generate, save, & display plots.
#-------------------------------------------------------------------------------
module EasyPlot

import ..CMDimData: rootpath

demofilelist() =
	[joinpath(rootpath, "sample", "plots", "demo$i.jl") for i in 1:5]

using Colors
using MDDatasets
import NumericIO


#==Core type declarations
===============================================================================#

#Type used to dispatch on a symbol & minimize namespace pollution:
#-------------------------------------------------------------------------------
struct DS{T}; end; #Dispatchable symbol
DS(v::Symbol) = DS{v}()

#Real values for plot coordinates, etc:
const PReal = Float64
const PNaN = PReal(NaN)


#==Functions
===============================================================================#
SI(v; ndigits=3) = NumericIO.formatted(v, :SI, ndigits=ndigits)

include("attributes.jl")
include("colors.jl")
include("base.jl")
include("multistrip.jl")
include("eyediag.jl")
include("datamd.jl")
include("themes.jl")
include("display.jl")
include("defaults.jl")
include("show.jl")
include("init.jl")
include("doc.jl")


#==Construct interface to minimize namespace pollution
===============================================================================#
function cons(::DS{T}, args...; kwargs...) where T
	mlist = string(methods(cons, (DS,)))
msg = """
Cannot construct object of type :$T.
Supported methods are:\n
"""
	throw(ArgumentError(msg * mlist))
end
cons(s::Symbol, args...; kwargs...) = cons(DS(s), args...; kwargs...)


#==Exported interface
===============================================================================#
export cons #Construct objects (minimize namespace pollution)
export set #Set PlotCollection/Plot/Waveform/... attributes
export render #render will not display (if possible).  "display()" shows plot.


#==Extensions
================================================================================
Base.display(backend::Symbol, pcoll::PlotCollection, args...; kwargs...)
==#


#==Unexported tools available to users:
================================================================================
	@initbackend() #Initializes any un-initialized backend specified in defaults.maindisplay
      (typically through ~/.julia/config/startup.jl)
		=> Only to be used in interactive mode; conditionally importing a module is bad for precompile.
==#


#==Unexported tools available to backend-interfacing modules:
================================================================================
	addwfrm(ax::AbstractBuilder, ...) #
	buildeye() #Builds multi-dimensional DataEye objects from DataF1 Leaf elements.
	getcolor()

	#Constants:
	COLORSCHEME[{:default/}] #List of color schemes
	COLOR_NAMED[COLOR_SYMBOL]
(Some COLOR_SYMBOLs:)
		:black, :white, :grey85
		:red, :green, :blue
		:yellow, :cyan, :magenta
		:brown, :orange, :indigo, :violet, :maroon, :turquoise
==#


#==Backend-interface modules should implement:
================================================================================
An <: EasyPlotDisplay subtype to dispatch calls to display():
	struct MyBackendDisplay <: EasyPlot.EasyPlotDisplay; ...; end

A render function to build plot on its plotting backend:
	EasyPlot.render(::MyBackendDisplay, pcoll::EasyPlot.PlotCollection, args...; kwargs...)
		=> returns MyBackendPlot object

#Used by EasyPlot to display plots (without side-effects of Base.display):
	EasyPlot._display(plot::MyBackendPlot) #Displays the plot
==#


#==Initialization
===============================================================================#
function __init__()
	global defaults
	_initialize(defaults)
	return
end

end #EasyPlot

#Last line
