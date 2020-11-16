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

import CMDimData.EasyPlot: Optional, Target, DS

include("base.jl")
include("defaults.jl")
include("builder.jl")


#==TODO
================================================================================
 - Convoluted/flaky handling of "interactivity", "backends", and "guimode:on/off".
   See MPLState, _getstate(), _applystate()
=#


#==Initialization
===============================================================================#
function __init__()
	global defaults
	_initialize(defaults)

	EasyPlot.register(:EasyPlotMPL)
	return
end

end

#Last line
