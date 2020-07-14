#EasyPlotInspect: Implement EasyPlot interface with InspectDR.jl
#-------------------------------------------------------------------------------
module EasyPlotInspect

import CMDimData
import CMDimData.EasyPlot #Import only - avoid collisions
using CMDimData.MDDatasets
using CMDimData.Colors
using InspectDR

import CMDimData.EasyPlot: render
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
