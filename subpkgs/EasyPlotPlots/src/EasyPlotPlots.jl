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

import CMDimData
import CMDimData.EasyPlot #Import only - avoid collisions
using MDDatasets
using Colors

using Plots

include("base.jl")
include("display.jl")
include("defaults.jl")

#==Initialization
===============================================================================#
function __init__()
	global defaults
	_initialize(defaults)

	EasyPlot.registerdefaults(:EasyPlotPlots,
		maindisplay = PlotDisplay(defaults.renderingtool, guimode=true),
		renderdisplay = EasyPlot.NullDisplay() #No support for render-only
	)
	return
end

end

#Last line
