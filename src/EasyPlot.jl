#EasyPlot: A quick/easy way to generate, save, & display plots.
#-------------------------------------------------------------------------------
module EasyPlot

const rootpath = realpath(joinpath(dirname(realpath(@__FILE__)),"../."))
sampleplotfile(id::Int) =
	joinpath(rootpath, "sample/sampleplot$id.jl")

using MDDatasets

include("codegen.jl")
include("base.jl")
include("plotmanip.jl")

export line, glyph #Waveform attributes
export axes #Plot axes attributes
export add #Add new plot/subplot/waveform/...
export set #Set Plot/Subplot/Waveform/... attributes

#
export Backend, render #render will not display (if possible).  display shows plot.

#==Already exported functions:
Base.display{T}(::Type{Backend{T}}, plot::Plot, args...; kwargs...)
==#

#==Rendering modules should implement:
================================================================================
EasyPlot.render{T}(::Type{Backend{T}}, plot::EasyPlot.Plot, args...; kwargs...)
Base.display(plot::BackendPlotType)
==#

end

#Last line
