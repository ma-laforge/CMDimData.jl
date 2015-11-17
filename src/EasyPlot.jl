#EasyPlot: A quick/easy way to generate, save, & display plots.
#-------------------------------------------------------------------------------
module EasyPlot

const rootpath = realpath(joinpath(dirname(realpath(@__FILE__)),"../."))
sampleplotfile(id::Int) =
	joinpath(rootpath, "sample/sampleplot$id.jl")

using MDDatasets
using FileIO2


include("codegen.jl")
include("base.jl")
include("plotmanip.jl")
include("eyediag.jl")

export line, glyph #Waveform attributes
export axes #Plot axes attributes
export eyeparam #Eye diagram parameters
export add #Add new plot/subplot/waveform/...
export set #Set Plot/Subplot/Waveform/... attributes

#
export render #render will not display (if possible).  "display()" shows plot.

#==Already exported functions:
Base.display(backend::Symbol, plot::Plot, args...; kwargs...)
==#

#==Rendering modules should implement:
================================================================================
EasyPlot.render{T<:Symbol}(::Backend{T}, plot::EasyPlot.Plot, args...; kwargs...)
	=> returns YOUR_MODULE_PLOT object
Base.display(plot::YOUR_MODULE_PLOT) #Displays the plot
==#

end #EasyPlot

#Last line
