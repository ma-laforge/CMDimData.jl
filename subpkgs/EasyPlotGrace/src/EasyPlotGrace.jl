#EasyPlotGrace: Render EasyPlot-plots with Grace/xmgrace (through GracePlot)
#-------------------------------------------------------------------------------
module EasyPlotGrace

#Hoping that environment of including module points to *correct* CMDimData:
import CMDimData
#Ensure *correct* modules are imported:
import CMDimData.EasyPlot #Avoid name collisions
using CMDimData.MDDatasets
using CMDimData.Colors
using GracePlot

import CMDimData.EasyPlot: Optional, Target, DS
import GracePlot: LineAttributes, GlyphAttributes

include("base.jl")
include("defaults.jl")
include("builder.jl")


#==Initialization
===============================================================================#
function __init__()
	global defaults
	_initialize(defaults)

	EasyPlot.register(:EasyPlotGrace)
	return
end

end

#Last line
