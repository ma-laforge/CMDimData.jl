#EasyPlot Display functionnality
#-------------------------------------------------------------------------------
#display


#=Design philosophy:
Defaults are initialized from ENV[] variables, so that they can be set from
.juliarc.jl without first loading the EasyPlot module.

Plot "Displays" should register their own EasyPlotDisplays objects to be used:
   1) Explicitly from the display stack (ex: with external GUI plot applications),
   2) Indirectly from the show(MIME) system (ex: generating inline plot images),
=#


#==Constants
===============================================================================#
#const FILE2MIME_MAP = Dict{DataType,String}(
const FILE2MIME_MAP = IdDict(
	FileIO2.PNGFmt => "image/png",
	FileIO2.SVGFmt => "image/svg+xml",
)


#==Display types
===============================================================================#

#To be subtyped by supported plot displays:
abstract type EasyPlotDisplay <: AbstractDisplay end
struct NullDisplay <: EasyPlotDisplay; end
struct UninitializedDisplay <: EasyPlotDisplay
	dtype::Symbol
end


#==Defaults
===============================================================================#
mutable struct Defaults
	rendersvg::Bool #Might want to dissalow SVG renderings for performance reasons

	#Plot-aware display to be added to the display stack:
	maindisplay::EasyPlotDisplay

	#Display used to render MIME-compatible plots
	#(ex: support for "plot-unaware" displays, like bitmap canvases)
	renderdisplay::EasyPlotDisplay
end


#Helpers
#-------------------------------------------------------------------------------
function readdefaults(::Type{EasyPlotDisplay}, envstr::String)
	val = get(ENV, envstr, "ANY")
	uval = uppercase(val)
	if "ANY" == uval
		return UninitializedDisplay(:Any)
	elseif "NONE" == uval
		return NullDisplay()
	else
		return UninitializedDisplay(Symbol(val))
	end
end

function readdefaults(::Type{Bool}, envstr::String, default::Bool)
	bstr = ["FALSE", "TRUE"] #WANTCONST
	val = get(ENV, envstr, string(default))
	uval = uppercase(val)

	if !(in(uval, bstr))
		optstr = join(bstr, ", ")
		warn("$envstr valid settings are: $optstr")
	end

	#Return default if not recognized as !default:
	return bstr[!default+1] != uval ? default : !default
end

#Constructors
#-------------------------------------------------------------------------------
function Defaults()
	rendersvg = readdefaults(Bool, "EASYPLOT_RENDERSVG", true)
	renderonly = readdefaults(Bool, "EASYPLOT_RENDERONLY", false)
	d = readdefaults(EasyPlotDisplay, "EASYPLOT_DEFAULTDISPLAY")
	maindisplay = renderdisplay = d

	if renderonly
		maindisplay = NullDisplay()
	end

	Defaults(rendersvg, maindisplay, renderdisplay)
end

#Data
#-------------------------------------------------------------------------------
function __init__()
global defaults = Defaults() #WANTCONST
end


#==Registration functions
===============================================================================#
overwriteunitinialized(::EasyPlotDisplay, ::Symbol, ::EasyPlotDisplay) = false
overwriteunitinialized(::UninitializedDisplay, ::Symbol, ::NullDisplay) = false
function overwriteunitinialized(d::UninitializedDisplay, displayid::Symbol, newd::EasyPlotDisplay)
	return (:Any == d.dtype || displayid  == d.dtype)
end

function registerdefaults(displayid::Symbol; 
	maindisplay::EasyPlotDisplay = NullDisplay(),
	renderdisplay::EasyPlotDisplay = NullDisplay())

	if overwriteunitinialized(EasyPlot.defaults.maindisplay, displayid, maindisplay)
		EasyPlot.defaults.maindisplay = maindisplay
		pushdisplay(maindisplay)
	end
	if overwriteunitinialized(EasyPlot.defaults.renderdisplay, displayid, renderdisplay)
		EasyPlot.defaults.renderdisplay = renderdisplay
	end
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
	warn("Plot display not initialized: $(d.dtype)")
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

function _write(file::File{T}, plot::Plot, d::EasyPlotDisplay) where T
	mimestr = get(FILE2MIME_MAP, T, nothing)
	if nothing == mimestr
		throw(methoderror(_write, (file, plot, d)))
	end
	nativeplot = render(d, plot)
	_write(file.path, MIME{Symbol(mimestr)}(), nativeplot)
end

_write(file::File, plot::Plot) =_write(file, plot, EasyPlot.defaults.renderdisplay)


#Last line
