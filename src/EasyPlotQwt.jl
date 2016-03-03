#EasyPlotQwt: Render EasyPlot-plots with Qwt guiqwt's interface
#-------------------------------------------------------------------------------
module EasyPlotQwt

import EasyPlot #Import only - avoid collisions
using MDDatasets
using Colors

#Type used to dispatch on a symbol & minimize namespace pollution:
#-------------------------------------------------------------------------------
immutable DS{Symbol}; end; #Dispatchable symbol
DS(v::Symbol) = DS{v}()

include("pybase.jl")
include("base.jl")

end

#Last line
