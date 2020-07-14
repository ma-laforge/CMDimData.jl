#EasyPlot initialization routines
#-------------------------------------------------------------------------------

#Import a given backend into the caller's module
macro importbackend(backend::Symbol)
#=Import glue code in caller's module.
	Expected that caller's module has access to dependency information on both
	`CMDimData` & plotting backend module.

	Sadly, precompile of glue code cannot be reused across Julia sessions.
=#
	path = realpath(joinpath(rootpath,"subpkgs/$backend/src/$backend.jl"))
	m = quote
		if !@isdefined $backend
			include($path)
		end
	end
	return esc(m) #esc: Evaluate in calling module
end


#==Initialize backend (importing module initializes corresponding backend)
===============================================================================#

function _initbackend(d::EasyPlot.NullDisplay) #Use default display
	return :(CMDimData.EasyPlot.@importbackend EasyPlotInspect) #Make InspectDR the default
end

function _initbackend(d::EasyPlot.UninitializedDisplay)
	bkmodule = d.dtype

	if "ANY" == uppercase(string(bkmodule))
		return _initbackend(EasyPlot.NullDisplay())
	end
	return :(CMDimData.EasyPlot.@importbackend $bkmodule)
end

function _initbackend(d) #Other cases: Display already initialized
	return :() #Do nothing
end

#Initialize any un-initialized backend specified as the main display:
macro initbackend()
#=NOTE:
	Use macro with "esc" so that no "import" command executes in this module.
   Instead, "import" gets executed in the user's (target) module.  This should
   presumably be better for precompilation?
=#
	esc(_initbackend(EasyPlot.defaults.maindisplay))
end

#Last line
