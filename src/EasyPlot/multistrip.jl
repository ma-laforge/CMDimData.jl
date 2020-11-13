#multistrip.jl: Convert a multi-strip Plot into a multi-Plot PlotCollection
#-------------------------------------------------------------------------------

#=NOTE:
Useful for plotting backends that do not support multi-strip plots.
=#


#==Helper functions
===============================================================================#

function hasmultistrip(pcoll::PlotCollection)
	for p in pcoll.plotlist
		if length(p.ystriplist) > 1
			return true
		end
	end
	return false
end


#==Main algorithm
===============================================================================#

function _ms2pcoll(src::Plot; title=nooverwrite)
	NoOverwrite(title) && (title = src.title)
	dcoll = PlotCollection(title=title, ncolumns=1)

	for srcy in src.ystriplist
		dplot = Plot(title=srcy.striplabel, legend=src.legend)
		desty = dplot.ystriplist[1]
			desty.scale = srcy.scale
			#desty.striplabel = srcy.striplabel #Use title instead
			desty.axislabel = srcy.axislabel
			desty.ext = deepcopy(srcy.ext)
		dplot.xext=deepcopy(src.xext)
		dplot.xaxis=deepcopy(src.xaxis)
		push!(dcoll, dplot)
	end

	nstrips = length(dcoll.plotlist)
	for srcwfrm in src.wfrmlist
		istrip = clamp(srcwfrm.strip, 1, nstrips)
		dwfrm = copy(srcwfrm); dwfrm.strip = 1
		push!(dcoll.plotlist[istrip], dwfrm)
	end
	dcoll.plotlist[end].xlabel = src.xlabel
	return dcoll
end


#==External interface (for backend implementation)
===============================================================================#

#Conditionally transform multi-strip plots to multi-plot collections:
function condxfrm_multistrip(pcoll::PlotCollection, backendid::String="some code";
	warnconv::Bool=true, warnfail::Bool=true)
	_hasmult = hasmultistrip(pcoll)
	title = pcoll.title
	msghdr ="""
`$backendid` does not natively support multi-strip plots found in:
    PlotCollection(\"$title\")
"""
	if !_hasmult
		return pcoll
	elseif length(pcoll.plotlist) > 1
		if warnconv
			@warn """$msghdr

*EMULATION MODE FAILED*: Can only convert a SINGLE multi-strip plot into multi-plot collection.
                         Output may be difficult to read."""
		end
		return pcoll
	end

	if warnconv
		@info """$msghdr
*EMULATION MODE ENABLED*: Breaking up (single) multi-strip plot into multi-plot collection."""
	end

	return _ms2pcoll(pcoll.plotlist[1], title=pcoll.title)
end

multistrip2plotcoll(src::Plot; kwargs...) = _ms2pcoll(src; kwargs...)

#Last line
