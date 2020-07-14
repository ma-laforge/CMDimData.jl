#EasyPlot Defaults control
#-------------------------------------------------------------------------------

#=Design philosophy:
Defaults are initialized from ENV[] variables, so that they can be set from
.juliarc.jl without first loading the EasyPlot module.
=#


#==Types
===============================================================================#
mutable struct Defaults
	rendersvg::Bool #Might want to dissalow SVG renderings for performance reasons

	#Plot-aware display to be added to the display stack:
	maindisplay::EasyPlotDisplay

	#Display used to render MIME-compatible plots
	#(ex: support for "plot-unaware" displays, like bitmap canvases)
	renderdisplay::EasyPlotDisplay
end
Defaults() = Defaults(false, NullDisplay(), NullDisplay())


#==Data
===============================================================================#
const global defaults = Defaults()


#==Helper functions
===============================================================================#
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
		@warn("$envstr valid settings are: $optstr")
	end

	#Return default if not recognized as !default:
	return bstr[!default+1] != uval ? default : !default
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
	global defaults

	if overwriteunitinialized(defaults.maindisplay, displayid, maindisplay)
		defaults.maindisplay = maindisplay
		pushdisplay(maindisplay)
	end
	if overwriteunitinialized(defaults.renderdisplay, displayid, renderdisplay)
		defaults.renderdisplay = renderdisplay
	end
end


#==Initialization
===============================================================================#
function _initialize(dflt::Defaults)
	renderonly = readdefaults(Bool, "EASYPLOT_RENDERONLY", false)
	dflt.rendersvg = readdefaults(Bool, "EASYPLOT_RENDERSVG", true)
	disp = readdefaults(EasyPlotDisplay, "EASYPLOT_DEFAULTDISPLAY")
	dflt.maindisplay = dflt.renderdisplay = disp

	if renderonly
		dflt.maindisplay = NullDisplay()
	end
	return
end

#Last line
