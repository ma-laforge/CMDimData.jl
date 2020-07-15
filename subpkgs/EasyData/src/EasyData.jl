#EasyData: A quick/easy way to save datasets/plots to file.
#-------------------------------------------------------------------------------

module EasyData


import CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
using HDF5

import CMDimData.EasyPlot: AttributeList
import CMDimData.EasyPlot: Plot, Subplot, Waveform
import HDF5: HDF5Group

include("base.jl")
include("hdf5data.jl")
include("hdf5plots.jl")


#==Initialization
===============================================================================#
function __init__()
	#Needed by @includepkg
end


#==Already exported functions:
==#

#==Un-exported public interface: _read/_write
================================================================================
#Using _read/_write interface ensures EasyData module handles operation.
	_read(path::String, Vector{Plot})
		_write(path::String, v::Vector{Plot})
	_read(path::String, Plot)
		_write(path::String, p::Plot, idx=[Int])

#TODO: provide _open interface as well
==#

end #EasyData

#Last line
