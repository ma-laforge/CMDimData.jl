#EasyPlotGrace: Render EasyPlot-plots with Grace/xmgrace (through GracePlot)
#-------------------------------------------------------------------------------
module EasyPlotGrace

using MDDatasets
import EasyPlot #Import only - avoid collisions
using GracePlot
using Colors

import EasyPlot: render
import GracePlot: LineAttributes, GlyphAttributes

include("base.jl")
include("display.jl")

end

#Last line
