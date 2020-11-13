#EasyPlotInspect: Implement EasyPlot interface with InspectDR.jl
#-------------------------------------------------------------------------------
module EasyPlotInspect

#Hoping that environment of including module points to *correct* CMDimData:
import CMDimData
#Ensure *correct* modules are imported:
import CMDimData.EasyPlot #Avoid name collisions
using CMDimData.MDDatasets
using CMDimData.Colors
using InspectDR

import CMDimData.EasyPlot: Optional
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
