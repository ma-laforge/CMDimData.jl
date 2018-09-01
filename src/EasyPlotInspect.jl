#EasyPlotInspect: Render EasyPlot-plots with InspectDR.jl
#-------------------------------------------------------------------------------
#=
TAGS:
	#WANTCONST, HIDEWARN_0.7
=#

module EasyPlotInspect

using MDDatasets
import EasyPlot #Import only - avoid collisions
using InspectDR
using Colors

import EasyPlot: render
import InspectDR: LineAttributes, GlyphAttributes

include("base.jl")
include("display.jl")

end

#Last line
