#CMDimData: Tools to easily manipulate continuous, multi-dimensional datasets.
#-------------------------------------------------------------------------------
__precompile__(true)
#=
TAGS:
	#WANTCONST, HIDEWARN_0.7
=#

module CMDimData

using Colors
using MDDatasets
import Pkg

const rootpath = realpath(joinpath(@__DIR__, ".."))

include("EasyPlot/EasyPlot.jl")


#==Subpackage manipulations
===============================================================================#

#Add a CMDimData subpackage to the active environment.
function pkgadd(pkgname::Symbol)
	throw(:NOTIMPL)
	repo = "https://github.com/ma-laforge/CMDimData"
	@show Pkg.add(PackageSpec(path=repo, subdir="subpkgs/$pkgname"))
end


#==Initialization
===============================================================================#
#Mimick import by including package code into the caller's module
macro includepkg(pkgname::Symbol)
#=Import glue code in caller's module.
	Expected that caller's module has access to dependency information on both
	`CMDimData` & dependencies of included module.

	Sadly, precompile of package code cannot be reused across Julia sessions.
	NOTE: Must call __init__() because it is only called on legitimate packages (not modules)
=#
	path = realpath(joinpath(rootpath,"subpkgs/$pkgname/src/$pkgname.jl"))
	m = quote
		if !@isdefined $pkgname
			include($path)
			$pkgname.__init__()
		end
	end
	return esc(m) #esc: Evaluate in calling module
end

function __init__()
	return
end

end # module
