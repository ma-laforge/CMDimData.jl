#EasyPlotPlots: Render EasyPlot-plots using Plots.jl backend.
#-------------------------------------------------------------------------------
__precompile__(false)
#=
PROBLEM:
In Plots.jl, functions specific to a backend are added AFTER we add them with
the call to Plots.backend().

It seems like this causes issues when EasyPlotPlots gets precompiled (even
when __precompile__(false))... presumably because these functions are not
defined yet... so they don't get "precompiled" into this module.
=#
module EasyPlotPlots

#Hoping that environment of including module points to *correct* CMDimData:
import CMDimData
#Ensure *correct* modules are imported:
import CMDimData.EasyPlot #Avoid name collisions
using CMDimData.MDDatasets
using CMDimData.Colors
using Plots

import CMDimData.EasyPlot: Optional, Target, DS

include("base.jl")
include("defaults.jl")
include("builder.jl")

#==Initialization
===============================================================================#
function __init__()
	global defaults
	_initialize(defaults)

	EasyPlot.register(:EasyPlotPlots)
	return
end

end

#Last line
