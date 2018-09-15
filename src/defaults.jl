#EasyPlotInspect Defaults control
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
const DEFAULT_BACKEND = :tk


#==Types
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
	envstr = "EASYPLOTMPL_DEFAULTBACKEND"
	val = get(ENV, envstr, String(DEFAULT_BACKEND))
	bk = lowercase(val)

	if !in(bk, SUPPORTED_BACKENDS)
		optstr = join(SUPPORTED_BACKENDS, ", ")
		@warn("$envstr valid settings are: $optstr")
		bk = String(DEFAULT_BACKEND)
	end

	dflt.backend = Symbol(bk)
	return
end

#Data
#-------------------------------------------------------------------------------


#Last line
