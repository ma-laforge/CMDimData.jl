#EasyPlotMPL: Render EasyPlot-plots with Matplotlib (through PyPlot)
#-------------------------------------------------------------------------------
module EasyPlotMPL

import CMDimData
import CMDimData.EasyPlot #Import only - avoid collisions
using CMDimData.MDDatasets
using CMDimData.Colors
using PyPlot
import PyCall #Need to access some types

import CMDimData.EasyPlot: render

include("base.jl")
include("display.jl")
include("defaults.jl")


#==Initialization
===============================================================================#
function __init__()
	global defaults
	_initialize(defaults)

	EasyPlot.registerdefaults(:EasyPlotMPL,
		maindisplay = PlotDisplay(guimode=true),
		renderdisplay = PlotDisplay(guimode=false)
	)
	return
end

end

#Last line
