#EasyPlotInspect: Render EasyPlot-plots with InspectDR.jl
#-------------------------------------------------------------------------------
__precompile__(true)
#=
TAGS:
	#WANTCONST, HIDEWARN_0.7
=#

module EasyPlotInspect

using MDDatasets
import EasyPlot #Import only - avoid collisions
using InspectDR

import EasyPlot: render
import InspectDR: LineAttributes, GlyphAttributes

include("base.jl")
include("display.jl")
include("defaults.jl")


#==Initialization
===============================================================================#
function __init__()
	global defaults
	_initialize(defaults)

	EasyPlot.registerdefaults(:EasyPlotInspect,
		maindisplay = PlotDisplay(),
		renderdisplay = PlotDisplay(wrender=defaults.wrender, hrender=defaults.hrender)
	)
	return
end

end

#Last line
