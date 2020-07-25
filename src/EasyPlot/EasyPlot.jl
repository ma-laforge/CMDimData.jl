#EasyPlot: A quick/easy way to generate, save, & display plots.
#-------------------------------------------------------------------------------
module EasyPlot

import ..CMDimData: rootpath

demofilelist() =
	[joinpath(rootpath, "sample", "plots", "demo$i.jl") for i in 1:5]

using Colors
using MDDatasets

include("codegen.jl")
include("colors.jl")
include("base.jl")
include("plotmanip.jl")
include("eyediag.jl")
include("datamd.jl")
include("themes.jl")
include("display.jl")
include("defaults.jl")
include("init.jl")


#==Interface
===============================================================================#
export line, glyph #Waveform attributes
export eyeparam #Eye diagram parameters
export add #Add new plot/subplot/waveform/...
export set #Set Plot/Subplot/Waveform/... attributes
export paxes #Plot axes attributes (Bad idea to extend Base.axes: when defining zero-argument signature)

#
export render #render will not display (if possible).  "display()" shows plot.

#==Already exported functions:
Base.display(backend::Symbol, plot::Plot, args...; kwargs...)
==#

#==Unexported tools available to rendering modules:
================================================================================
	AbstractAxes #Type: Provides advanced functionality to rendering modules.
	AbstractAxes{:eye}: Expects .eye::EyeAttributes
	addwfrm(ax::AbstractAxes, ...) #
	buildeye() #Builds multi-dimensional DataEye objects from DataF1 Leaf elements.
	getcolor()
	@initbackend() #Initializes any un-initialized backend specified in defaults.maindisplay
      (typically through ~/.julia/config/startup.jl)
		=> Only to be used in interactive mode; conditionally importing a module is bad for precompile.

	#Constants:
	COLORSCHEME[{:default/}] #List of color schemes
	COLOR_NAMED[COLOR_SYMBOL]
(Some COLOR_SYMBOLs:)
		:black, :white, :grey85
		:red, :green, :blue
		:yellow, :cyan, :magenta
		:brown, :orange, :indigo, :violet, :maroon, :turquoise
==#


#==Rendering modules should implement:
================================================================================
Subtype EasyPlotDisplay, for example:
	struct NEWPLOTDisplay <: EasyPlotDisplay{:NEWPLOTID}

	EasyPlot.getdisplay(::Type{EasyPlotDisplay{:NEWPLOTID}}) 
		=> return NEWPLOTDisplay object

EasyPlot.render{T<:Symbol}(::Backend{T}, plot::EasyPlot.Plot, args...; kwargs...)
	=> returns YOUR_MODULE_PLOT object
Base.display(plot::YOUR_MODULE_PLOT) #Displays the plot
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
