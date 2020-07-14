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
render(d::EasyPlotDisplay, plot::Plot) = throw(MethodError(render, (d, plot)))

function Base.display(d::EasyPlotDisplay, plot::Plot)
	nativeplot = render(d, plot)
	_display(nativeplot)
	return nothing
end


#==Rendering functions
===============================================================================#
Base.showable(mime::MIME, p::Plot, d::NullDisplay) = false
Base.showable(mime::MIME, p::Plot, d::UninitializedDisplay) = false

function render(d::UninitializedDisplay, plot::Plot)
	@warn("Plot display not initialized: $(d.dtype)")
	throw(MethodError(render, (d, plot)))
end

Base.showable(mime::MIME, p::Plot) =
	Base.showable(mime, p, EasyPlot.defaults.renderdisplay)
Base.showable(mime::MIME"text/plain", p::Plot) = true
Base.showable(mime::MIME"image/svg+xml", p::Plot) =
	EasyPlot.defaults.rendersvg && Base.showable(mime, p, EasyPlot.defaults.renderdisplay)

#Maintain text/plain MIME support.
Base.show(io::IO, ::MIME"text/plain", p::Plot) = Base.show(io, p)

function Base.show(io::IO, mime::MIME, p::Plot)
	d = EasyPlot.defaults.renderdisplay
	#Try to figure out if possible *before* rendering:
	if !showable(mime, p, d)
		throw(MethodError(show, (io, mime, p)))
	end
	nativeplot = render(d, p)
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

function _write(filepath::String, mime::MIME, plot::Plot, d::EasyPlotDisplay)
	nativeplot = render(d, plot)
	_write(filepath, mime, nativeplot)
end

_write(filepath::String, mime::MIME, plot::Plot) =_write(filepath, mime, plot, EasyPlot.defaults.renderdisplay)

#TODO: Do forall mimes

#write_png(filepath::String, plot::Plot, args...) =_write(filepath, MIME"image/png"(), plot, args...)

#Create write_png, write_svg, ... convenience functions:
for (ext, mime) in EXT2MIME_MAP; fn=Symbol(:write_,ext); @eval begin #CODEGEN----------------------------------------

$fn(filepath::String, plot::Plot, args...) =_write(filepath, MIME($mime), plot, args...)

end; end #CODEGEN---------------------------------------------------------------

#Last line
