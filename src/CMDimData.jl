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
using Pkg

const rootpath = realpath(joinpath(@__DIR__, ".."))

include("EasyPlot/EasyPlot.jl")


#==Subpackage manipulations
===============================================================================#

#Import a given backend into the caller's module
function pkgadd(backend::Symbol)
	throw(:NOTIMPL)
	repo = "https://github.com/ma-laforge/CMDimData"
	@show Pkg.add(PackageSpec(path=repo, subdir="subpkgs/$backend"))
end


#==Initialization
===============================================================================#
function __init__()
	@info "CMDimData.__init__()"

	return
end

end # module
