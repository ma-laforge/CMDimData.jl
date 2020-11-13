#EasyPlotMPL: Render EasyPlot-plots with Matplotlib (through PyPlot)
#-------------------------------------------------------------------------------
module EasyPlotMPL

#Hoping that environment of including module points to *correct* CMDimData:
import CMDimData
#Ensure *correct* modules are imported:
import CMDimData.EasyPlot #Avoid name collisions
using CMDimData.MDDatasets
using CMDimData.Colors
import PyCall #Need to access some types
using PyPlot

import CMDimData.EasyPlot: Optional

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
