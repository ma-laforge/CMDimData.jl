#EasyPlotQwt: Render EasyPlot-plots with Qwt guiqwt's interface
#-------------------------------------------------------------------------------
module EasyPlotQwt

import EasyPlot #Import only - avoid collisions
using MDDatasets
using Colors

import EasyPlot: render

#Type used to dispatch on a symbol & minimize namespace pollution:
#-------------------------------------------------------------------------------
struct DS{Symbol}; end; #Dispatchable symbol
DS(v::Symbol) = DS{v}()

include("pybase.jl")
include("base.jl")
include("display.jl")

#==Initialization
===============================================================================#
function __init__()
	EasyPlot.registerdefaults(:Qwt,
		maindisplay = PlotDisplay(guimode=true),
		renderdisplay = EasyPlot.NullDisplay() #No support at the moment.
	)
	return
end

end

#Last line
