#EasySave: A quick/easy way to save datasets and plot objects.
#-------------------------------------------------------------------------------
module EasySave

const rootpath = realpath(joinpath(dirname(realpath(@__FILE__)),"../."))

using MDDatasets
using FileIO2
using EasyPlot
using HDF5

import EasyPlot: AttributeList
import EasyPlot: Plot, Subplot, Waveform


include("base.jl")
include("hdf5plots.jl")

#For loading/saving EasyPlotHDF5 files:
export EPH5Fmt

#==Already exported functions:
==#

end #EasySave

#Last line
