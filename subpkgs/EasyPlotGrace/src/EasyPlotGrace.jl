#EasyPlotGrace: Render EasyPlot-plots with Grace/xmgrace (through GracePlot)
#-------------------------------------------------------------------------------
module EasyPlotGrace

import CMDimData
import CMDimData.EasyPlot #Import only - avoid collisions
using CMDimData.MDDatasets
using CMDimData.Colors
using GracePlot

import CMDimData.EasyPlot: render
import GracePlot: LineAttributes, GlyphAttributes

include("base.jl")
include("display.jl")
include("defaults.jl")


#==Initialization
===============================================================================#
function __init__()
	global defaults
	_initialize(defaults)

	EasyPlot.registerdefaults(:EasyPlotGrace,
		maindisplay = PlotDisplay(guimode=true),
		renderdisplay = PlotDisplay(guimode=false, dpi=defaults.renderdpi)
	)
	return
end

end

#Last line
