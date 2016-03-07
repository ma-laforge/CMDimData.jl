#EasyPlotPlots: Render EasyPlot-plots using Plots.jl backend.
#-------------------------------------------------------------------------------
module EasyPlotPlots

import EasyPlot #Import only - avoid collisions
using Plots
import PyCall #Need to access some types
using MDDatasets
using Colors

include("base.jl")

end

#Last line
