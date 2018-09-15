#EasyPlotGrace: Render EasyPlot-plots with Grace/xmgrace (through GracePlot)
#-------------------------------------------------------------------------------
__precompile__(true)
#=
TAGS:
	#WANTCONST, HIDEWARN_0.7
=#

module EasyPlotGrace

using MDDatasets
import EasyPlot #Import only - avoid collisions
using GracePlot
using Colors

import EasyPlot: render
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
end

end

#Last line
