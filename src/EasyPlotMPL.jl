#EasyPlotMPL: Render EasyPlot-plots with Matplotlib (through PyPlot)
#-------------------------------------------------------------------------------
__precompile__(true)
#=
TAGS:
	#WANTCONST, HIDEWARN_0.7
=#
module EasyPlotMPL

import EasyPlot #Import only - avoid collisions
using PyPlot
import PyCall #Need to access some types
using MDDatasets
using Colors

import EasyPlot: render

include("base.jl")
include("display.jl")


end

#Last line
