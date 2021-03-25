#EasyPlot: Grids, etc.
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#


#==Main types
===============================================================================#
abstract type AbstractGrid end

"""`GridCartesian(vmajor=true, vminor=false, hmajor=true, hminor=false)`

Allows control over grid lines.
"""
mutable struct GridCartesian <: AbstractGrid
	#TODO: Could eventually specify grid lines and color manually
	vmajor::Bool
	vminor::Bool
	hmajor::Bool
	hminor::Bool
end
GridCartesian(;vmajor=true, vminor=false, hmajor=true, hminor=false) =
	GridCartesian(vmajor, vminor, hmajor, hminor)

mutable struct GridPolar <: AbstractGrid
	rmajor::Bool
	rminor::Bool
	thetamajor::Bool
	thetaminor::Bool
end

#Last line
