#EasyPlotPlots Defaults control
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
const DEFAULT_BACKEND = :gr


#==Defaults
===============================================================================#
mutable struct Defaults
	backend::Symbol
end
Defaults() = Defaults(DEFAULT_BACKEND)


#==Data
===============================================================================#
const global defaults = Defaults()


#==Initialization
===============================================================================#
function _initialize(dflt::Defaults)
	dflttool = string(DEFAULT_BACKEND)
	envstr = "EASYPLOTPLOTS_BACKEND"
	val = get(ENV, envstr, dflttool)
	dflt.backend = Symbol(lowercase(val))
	return
end

#Last line
