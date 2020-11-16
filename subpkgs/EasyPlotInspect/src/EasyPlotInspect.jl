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

import CMDimData.EasyPlot: Optional, Target, DS
import InspectDR: LineAttributes, GlyphAttributes

include("base.jl")
include("builder.jl")


#==Initialization
===============================================================================#
function __init__()
	EasyPlot.register(:InspectDR)
	return
end

end

#Last line
