#EasyPlot Display functionnality
#-------------------------------------------------------------------------------
#display


#=Design philosophy:
Defaults are initialized from ENV[] variables, so that they can be set from
.juliarc.jl without first loading the EasyPlot module.

Plot "Displays" should register their own EasyPlotDisplays objects to be used:
   1) Explicitly from the display stack (ex: with external GUI plot applications),
   2) Indirectly from the writemime system (ex: generating inline plot images),
=#


#==Display types
===============================================================================#

#To be subtyped by supported plot displays:
abstract EasyPlotDisplay <: Display
immutable NullDisplay <: EasyPlotDisplay; end
immutable UninitializedDisplay <: EasyPlotDisplay
	dtype::Symbol
end


#==Defaults
===============================================================================#
type Defaults
	rendersvg::Bool #Might want to dissalow SVG renderings for performance reasons

	#Plot-aware display to be added to the display stack:
	maindisplay::EasyPlotDisplay

	#Display used to render MIME-compatible plots
	#(ex: support for "plot-unaware" displays, like bitmap canvases)
	renderdisplay::EasyPlotDisplay
end


#Helpers
#-------------------------------------------------------------------------------
function readdefaults(::Type{EasyPlotDisplay}, envstr::ASCIIString)
	val = get(ENV, envstr, "ANY")
	uval = uppercase(val)
	if "ANY" == uval
		return UninitializedDisplay(:Any)
	elseif "NONE" == uval
		return NullDisplay()
	else
		return UninitializedDisplay(symbol(val))
	end
end

function readdefaults(::Type{Bool}, envstr::ASCIIString, default::Bool)
	const bstr = ["FALSE", "TRUE"]
	val = get(ENV, envstr, string(default))
	uval = uppercase(val)

	if !(in(uval, bstr))
		optstr = join(bstr, ", ")
		warn("$envstr valid settings are: $optstr")
	end

	#Return default if not recognized as !default:
	return bstr[!default+1] != uval? default: !default
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
	else
		renderdisplay = NullDisplay()
	end

	Defaults(rendersvg, maindisplay, renderdisplay)
end

#Data
#-------------------------------------------------------------------------------
const defaults = Defaults()


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

	if overwriteunitinialized(defaults.maindisplay, displayid, maindisplay)
		defaults.maindisplay = maindisplay
		pushdisplay(maindisplay)
	end
	if overwriteunitinialized(defaults.renderdisplay, displayid, renderdisplay)
		defaults.renderdisplay = renderdisplay
	end
end


#==Rendering functions
===============================================================================#
Base.mimewritable(mime::MIME, p::Plot, d::NullDisplay) = false
Base.mimewritable(mime::MIME, p::Plot, d::UninitializedDisplay) = false

Base.writemime(io::IO, mime::MIME, p::Plot, d::NullDisplay) =
	throw(MethodError(writemime, (io, mime, p))) #Don't put d (not part of high-level call)
function Base.writemime(io::IO, mime::MIME, p::Plot, d::UninitializedDisplay)
	warn("Plot display not initialized: $(d.dtype)")
	throw(MethodError(writemime, (io, mime, p))) #Don't put d (not part of high-level call)
end

Base.mimewritable(mime::MIME, p::Plot) =
	Base.mimewritable(mime, p, defaults.renderdisplay)

Base.mimewritable(mime::MIME"image/svg+xml", p::Plot) =
	defaults.rendersvg && Base.mimewritable(mime, p, defaults.renderdisplay)


#Maintain text/plain MIME support (Is this ok?... showlimited is not exported).
Base.writemime(io::IO, ::MIME"text/plain", p::Plot) = Base.showlimited(io, p)
Base.writemime(io::IO, mime::MIME, p::Plot) =
	writemime(io, mime, p, defaults.renderdisplay)


#==Rendering interface (to be implemented externally):
===============================================================================#

#Placeholder to define _display method:
#NOTE: Do not overwrite Base.display... would circumvent display system.
_display(plot) = throw("\"_display\" not defined for ::$(typeof(plot))")

#Catch-alls function placeholder:
render(d::EasyPlotDisplay, plot::Plot) =
	throw("\"render\" not supported for backend: $(typeof(d))")

function Base.display(d::EasyPlotDisplay, plot::Plot)
	nativeplot = render(d, plot)
	_display(nativeplot)
end

#Last line
