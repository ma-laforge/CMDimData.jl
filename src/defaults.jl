#EasyPlotGrace Defaults control
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
DEFAULT_RENDERDPI = 75 #Low res for inline graphics


#==Defaults
===============================================================================#
mutable struct Defaults
	renderdpi::Int #Low res for inline graphics
end
Defaults() = Defaults(DEFAULT_RENDERDPI)


#==Data
===============================================================================#
const global defaults = Defaults()


#==Initialization
===============================================================================#
function _initialize(dflt::Defaults)
	ENVSTR_RENDERDPI = "EASYPLOTGRACE_RENDERDPI" #WANTCONST
	renderdpi = get(ENV, ENVSTR_RENDERDPI, "$DEFAULT_RENDERDPI")

	try
		dflt.renderdpi = parse(Int, renderdpi)
	catch
		warn("Invalid value for $ENVSTR_RENDERDPI: $renderdpi.  Setting to $(DEFAULT_RENDERDPI).")
		dflt.renderdpi = DEFAULT_RENDERDPI
	end

	return
end

#Last line
