#EasyData: A quick/easy way to save datasets/plots to file.
#-------------------------------------------------------------------------------

module EasyData


import CMDimData
using CMDimData.EasyPlot
using MDDatasets
using Colors
import HDF5
import Pkg

import CMDimData.EasyPlot: PlotCollection, Plot, YStrip
import CMDimData.EasyPlot: Waveform, LineAttributes, GlyphAttributes
import CMDimData.EasyPlot: Extents1D, Axis, FoldedAxis

import HDF5: HDF5Group, HDF5Dataset

include("base.jl")
include("hdf5typed.jl")
include("hdf5datamd.jl")
include("hdf5plots.jl")


#==Initialization
===============================================================================#
function __init__()
	#Needed by @includepkg
end


#==Un-exported public interface to read/write data.
================================================================================
	openwriter(path::String)
	openreader(path::String)
	Base.close(w::EasyDataWriter)
	Base.close(r::EasyDataReader)

	Base.write(w::EasyDataWriter, d::DataMD, name::String)
	Base.write(w::EasyDataWriter, pcoll::PlotCollection, name::String)

	Base.read(::Type{DataMD}, r::EasyDataReader, name::String)
	Base.read(::Type{PlotCollection}, r::EasyDataReader, name::String)
	readdata(r::EasyDataReader, name::String) #Avoids specifying ::Type{DataMD}
	readplot(r::EasyDataReader, name::String) #Avoids specifying ::Type{PlotCollection}

	#High-level open, read/write, close interface for plots:
	writeplot(filepath::String, pcoll::PlotCollection; name::String="_unnamed")
	readplot(filepath::String; name::String="_unnamed")
==#

end #EasyData

#Last line
