#EasyPlotMPL: Render EasyPlot-plots with Matplotlib (through PyPlot)
#-------------------------------------------------------------------------------
module EasyPlotMPL

import EasyPlot #Import only - avoid collisions
using PyPlot
using MDDatasets

const plt = PyPlot

include("base.jl")

end

#Last line
