#EasyPlot initialization routines
#-------------------------------------------------------------------------------

#==Initialize backend (importing module initializes corresponding backend)
===============================================================================#

function _initbackend(d::EasyPlot.NullDisplay) #Use default display
	return :(import EasyPlotInspect) #Make InspectDR the default
end

function _initbackend(d::EasyPlot.UninitializedDisplay)
	bkmodule = d.dtype

	if "ANY" == uppercase(string(bkmodule))
		return _initbackend(EasyPlot.NullDisplay())
	end
	return :(import $bkmodule)
end

function _initbackend(d) #Other cases: Display already initialized
	return :() #Do nothing
end

#Initialize any un-initialized backend specified as the main display:
macro initbackend()
#=NOTE:
   Use macro so that no "import" command executes in this module.  Instead,
   "import" gets executed in the user's (target) module.  This should presumably
   be better for precompilation?
=#
	_initbackend(EasyPlot.defaults.maindisplay)
end

#Last line
