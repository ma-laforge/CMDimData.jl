#EasyPlot Defaults control
#-------------------------------------------------------------------------------

#=Design philosophy:
Defaults are initialized from ENV[] variables, so that they can be set from
~/.julia/config/startup.jl without first loading the EasyPlot module.
=#


#==Types
===============================================================================#
#Default width/height for rendering inline plots (preferably low res):
const DEFAULT_RENDERW = 300
const DEFAULT_RENDERH = round(Int, DEFAULT_RENDERW / MathConstants.φ) #φ: golden ratio


#==Types
===============================================================================#
mutable struct Defaults
	rendersvg::Bool #Might want to dissalow SVG renderings for performance reasons
	mimeshowopt::ShowOptions

	#When no builder is specified:
	guibuilder::Optional{AbstractBuilder}
	filebuilder::Optional{AbstractBuilder} #Writing to file
	mimebuilder::Optional{AbstractBuilder} #Responds directly to show(::IO, ::MIME, ...)
end
Defaults() = Defaults(false, ShowOptions(), nothing, nothing, nothing)


#==Data
===============================================================================#
const global defaults = Defaults()


#==Helper functions
===============================================================================#
function readdefaults(::Type{AbstractPlotDimensions}, envstr::String, default::AbstractPlotDimensions)
	result = default
	optstr = "{(w, h), :default}"
	val = get(ENV, envstr, nothing)
	if isa(val, Tuple{Int,Int})
		return PlotDim(val...)
	elseif isnothing(val)
		#use default
	elseif s == :auto
		result = plotautosize
	else
		@warn("$envstr valid settings are: $optstr")
	end

	return result
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
function register(displayid::Symbol)
	#global defaults
	#TODO
end


#==Initialization
===============================================================================#
function _initialize(dflt::Defaults)
	dflt.rendersvg = readdefaults(Bool, "EASYPLOT_RENDERSVG", true)
	dim = readdefaults(AbstractPlotDimensions, "EASYPLOT_MIMESIZE", plotautosize)
	dflt.mimeshowopt = ShowOptions(dim)
	return
end

#Last line
