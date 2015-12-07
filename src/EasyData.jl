#EasyData: A quick/easy way to save datasets/plots to file.
#-------------------------------------------------------------------------------
module EasyData

const rootpath = realpath(joinpath(dirname(realpath(@__FILE__)),"../."))

using MDDatasets
using FileIO2
using EasyPlot
using HDF5

import EasyPlot: AttributeList
import EasyPlot: Plot, Subplot, Waveform
import HDF5: HDF5Group


include("base.jl")
include("hdf5data.jl")
include("hdf5plots.jl")

#==Already exported functions:
==#

end #EasyData

#Last line
