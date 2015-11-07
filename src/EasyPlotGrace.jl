#EasyPlotGrace: Render EasyPlot-plots with Grace/xmgrace (through GracePlot)
#-------------------------------------------------------------------------------
module EasyPlotGrace

using MDDatasets
import EasyPlot #Import only - avoid collisions
using GracePlot

import EasyPlot: render
import GracePlot: LineAttributes, GlyphAttributes

include("base.jl")

end

#Last line
