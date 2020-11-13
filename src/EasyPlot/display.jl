#EasyPlot Display functionnality
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
const EXT2MIME_MAP = IdDict{Symbol,String}(
	:png => "image/png",
	:svg => "image/svg+xml",
)


#==Display types
===============================================================================#

#To be subtyped by supported plot displays:
abstract type EasyPlotDisplay <: AbstractDisplay end
struct NullDisplay <: EasyPlotDisplay; end
struct UninitializedDisplay <: EasyPlotDisplay
	dtype::Symbol
end


#==Rendering interface (to be implemented externally):
===============================================================================#

#Placeholder to define _display method:
#NOTE: Do not overwrite Base.display... would circumvent display system.
_display(plot) = throw(MethodError(_display, (plot,)))

#Catch-alls function placeholder:
render(d::EasyPlotDisplay, pcoll::PlotCollection) = throw(MethodError(render, (d, pcoll)))

function Base.display(d::EasyPlotDisplay, pcoll::PlotCollection)
	nativeplot = render(d, pcoll)
	return _display(nativeplot)
end

function Base.display(d::EasyPlotDisplay, plot::Plot)
	pcoll = push!(cons(:plot_collection, ncolumns = 1), plot)
	return display(d, pcoll)
end


#==Rendering functions
===============================================================================#
Base.showable(mime::MIME, pc::PlotCollection, d::NullDisplay) = false
Base.showable(mime::MIME, pc::PlotCollection, d::UninitializedDisplay) = false

function render(d::UninitializedDisplay, pcoll::PlotCollection)
	@warn("Plot display not initialized: $(d.dtype)")
	throw(MethodError(render, (d, pcoll)))
end

Base.showable(mime::MIME, pc::PlotCollection) =
	Base.showable(mime, pc, EasyPlot.defaults.renderdisplay)
Base.showable(mime::MIME"text/plain", pc::PlotCollection) = true
Base.showable(mime::MIME"image/svg+xml", pc::PlotCollection) =
	EasyPlot.defaults.rendersvg && Base.showable(mime, pc, EasyPlot.defaults.renderdisplay)

#Maintain text/plain MIME support.
Base.show(io::IO, ::MIME"text/plain", pc::PlotCollection) = Base.show(io, pc)

function Base.show(io::IO, mime::MIME, pc::PlotCollection)
	d = EasyPlot.defaults.renderdisplay
	#Try to figure out if possible *before* rendering:
	if !showable(mime, pc, d)
		throw(MethodError(show, (io, mime, pc)))
	end
	nativeplot = render(d, pc)
	show(io, mime, nativeplot)
end


#==Exporting to file:
===============================================================================#
#TODO: Should this be overloading "show" instead?
function _write(filepath::String, mime::MIME, nativeplot)
	open(filepath, "w") do io
		show(io, mime, nativeplot)
	end
end

function _write(filepath::String, mime::MIME, pcoll::PlotCollection, d::EasyPlotDisplay)
	nativeplot = render(d, pcoll)
	_write(filepath, mime, nativeplot)
end

_write(filepath::String, mime::MIME, pcoll::PlotCollection) =_write(filepath, mime, pcoll, EasyPlot.defaults.renderdisplay)

#Create write_png, write_svg, ... convenience functions:
for (ext, mime) in EXT2MIME_MAP; fn=Symbol(:write_,ext); @eval begin #CODEGEN----------------------------------------

$fn(filepath::String, pcoll::PlotCollection, args...) =_write(filepath, MIME($mime), pcoll, args...)

end; end #CODEGEN---------------------------------------------------------------

#Last line
