#EasyPlot: A quick/easy way to generate, save, & display plots.
#-------------------------------------------------------------------------------
module EasyPlot

import ..CMDimData: rootpath

demofilelist() =
	[joinpath(rootpath, "sample", "plots", "demo$i.jl") for i in 1:5]

using Colors
using MDDatasets
import NumericIO
using Graphics: BoundingBox

import ..NullOr


#==Implementation
===============================================================================#
include("core.jl")
include("attributes.jl")
include("colors.jl")
include("text.jl")
include("cartesian.jl")
include("grids.jl")
include("annotation.jl")
include("base.jl")
include("multistrip.jl")
include("eyediag.jl")
include("datamd.jl")
include("themes.jl")
include("show.jl")
include("builder.jl")
include("defaults.jl")
include("io.jl")
include("display.jl")
include("doc.jl")


#==`cons`truct interface (minimize namespace pollution)
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


#==Unexported tools available to backend-interfacing modules:
================================================================================
	addwfrm(ax::AbstractWfrmBuilder, ...) #
	buildeye() #Builds multi-dimensional DataEye objects from DataF1 Leaf elements.
	getcolor()

	#Constants:
	COLORSCHEME[{:default/}] #List of color schemes
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
