#EasyPlot: A quick/easy way to generate, save, & display plots.
#-------------------------------------------------------------------------------
module EasyPlot

#TODO: Place HDF5 persist code in separate module to avoid long load times?

const rootpath = realpath(joinpath(dirname(realpath(@__FILE__)),"../."))
sampleplotfile(id::Int) =
	joinpath(rootpath, "sample/sampleplot$id.jl")

using MDDatasets
using FileIO2
using HDF5


include("codegen.jl")
include("base.jl")
include("plotmanip.jl")
include("hdf5plots.jl")

export line, glyph #Waveform attributes
export axes #Plot axes attributes
export add #Add new plot/subplot/waveform/...
export set #Set Plot/Subplot/Waveform/... attributes

#
export Backend, render #render will not display (if possible).  display shows plot.

#For loading/saving EasyPlotHDF5 files:
export EPH5Fmt

#==Already exported functions:
Base.display{T}(::Type{Backend{T}}, plot::Plot, args...; kwargs...)
==#

#==Rendering modules should implement:
================================================================================
EasyPlot.render{T}(::Type{Backend{T}}, plot::EasyPlot.Plot, args...; kwargs...)
Base.display(plot::BackendPlotType)
==#

end #EasyPlot

#Last line
