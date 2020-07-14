#EasyPlotInspect Defaults control
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
#Default width/height for rendering inline plots (preferably low res):
const DEFAULT_RENDERW = 300.0
const DEFAULT_RENDERH = DEFAULT_RENDERW / MathConstants.φ #φ: golden ratio


#==Types
===============================================================================#
mutable struct Defaults
	#Default width/height for rendering inline plots:
	wrender::Float64
	hrender::Float64
end
Defaults() = Defaults(DEFAULT_RENDERW, DEFAULT_RENDERH)


#==Data
===============================================================================#
const global defaults = Defaults()


#==Initialization
===============================================================================#
function _initialize(dflt::Defaults)
	ENVSTR_RENDERW = "EASYPLOTINSPECT_RENDERW" #WANTCONST
	ENVSTR_RENDERH = "EASYPLOTINSPECT_RENDERH" #WANTCONST
	wrender = get(ENV, ENVSTR_RENDERW, "$DEFAULT_RENDERW")
	hrender = get(ENV, ENVSTR_RENDERH, "$DEFAULT_RENDERH")

	try
		dflt.wrender = parse(Float64, wrender)
	catch
		@warn("Invalid value for $ENVSTR_RENDERW: $wrender.  Setting to $DEFAULT_RENDERW.")
		dflt.wrender = DEFAULT_RENDERW
	end

	try
		dflt.hrender = parse(Float64, hrender)
	catch
		@warn("Invalid value for $ENVSTR_RENDERH: $hrender.  Setting to $DEFAULT_RENDERH.")
		dflt.hrender = DEFAULT_RENDERH
	end

	return
end

#Last line
