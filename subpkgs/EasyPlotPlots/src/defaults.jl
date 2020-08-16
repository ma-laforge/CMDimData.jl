#EasyPlotPlots Defaults control
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
const DEFAULT_RENDERINGTOOL = :pyplot


#==Defaults
===============================================================================#
mutable struct Defaults
	renderingtool::Symbol
end
Defaults() = Defaults(DEFAULT_RENDERINGTOOL)


#==Data
===============================================================================#
const global defaults = Defaults()


#==Initialization
===============================================================================#
function _initialize(dflt::Defaults)
	dflttool = string(DEFAULT_RENDERINGTOOL)
	envstr = "EASYPLOTPLOTS_RENDERINGTOOL"
	val = get(ENV, envstr, dflttool)
	dflt.renderingtool = Symbol(lowercase(val))
	return
end

#Last line
