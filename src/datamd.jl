#EasyPlot Utilities to handle multi-dimensional datasets
#-------------------------------------------------------------------------------

#==NOTE:
This module includes tools to use in case the plotting (rendering) tool does
not support multi-dimensional datasets directly.==#


#==Additional traps
===============================================================================#
addwfrm() = nothing #Register symbol here (implemented by rendering modules)

function _addwfrm{T<:DataMD}(ax::AbstractAxes, d::T, args...; kwargs...)
	throw("Plotting $T datasets not supported.")
end


#==Adding DataF1 waveforms
===============================================================================#

#Add a waveform to a typical plot:
function _addwfrm(ax::AbstractAxes, d::DataF1,
	id::String, la::LineAttributes, ga::GlyphAttributes, pidx::Int)
	cur_la = deepcopy(la)
	if nothing == cur_la.color
		cur_la.color = pidx
	end
	addwfrm(ax, d, id, cur_la, ga)
end

#Add a waveform to an eye diagram:
function _addwfrm(ax::AbstractAxes{:eye}, d::DataF1,
	id::String, la::LineAttributes, ga::GlyphAttributes, pidx::Int)
	param = ax.eye
	eye = buildeye(d, param.tbit, param.teye, tstart=param.tstart)

	cur_la = deepcopy(la)
	if nothing == cur_la.color
		cur_la.color = pidx
	end
	cur_id = id

	for segment in eye.data
		addwfrm(ax, segment, cur_id, cur_la, ga)
		cur_id = ""
	end
end

#==Adding with DataRS waveform
===============================================================================#

#Add collection of DataRS{DataF1} results:
function _addwfrm(ax::AbstractAxes, d::DataRS{DataF1}, crnid::String,
	id::String, la::LineAttributes, ga::GlyphAttributes, pidx::Int)
	crnid = ""==crnid? crnid: "$crnid / "
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		v = d.sweep.v[i]
		curcrnid = "$crnid$sweepname=$v"
		cur_id = "$id; $curcrnid"
		wfrm = _addwfrm(ax, d.elem[i], cur_id, la, ga, i)
	end
end

#Add collection of DataRS{Number} results:
function _addwfrm{T<:Number}(ax::AbstractAxes, d::DataRS{T}, crnid::String,
	id::String, la::LineAttributes, ga::GlyphAttributes, pidx::Int)
	cur_id = "" == crnid? id: "$id; $curcrnid"
	return _addwfrm(ax, DataF1(d.sweep.v, d.elem), cur_id, la, ga, pidx)
end

#Add collection of DataRS{DataRS} results:
function _addwfrm(ax::AbstractAxes, d::DataRS{DataRS}, crnid::String,
	id::String, la::LineAttributes, ga::GlyphAttributes, pidx::Int)
	crnid = ""==crnid? crnid: "$crnid / "
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		v = d.sweep.v[i]
		curcrnid = "$crnid$sweepname=$v"
		wfrm = _addwfrm(ax, d.elem[i], curcrnid, id, la, ga, i)
	end
end

#If corner id !exists, use "" & relay call:
_addwfrm(ax::AbstractAxes, d::DataRS,
	id::String, la::LineAttributes, ga::GlyphAttributes, pidx::Int) =
	_addwfrm(ax, d, "", id, la, ga, pidx)


#==Working with DataHR
===============================================================================#

#Add waveforms from a collection of DataHR{DataF1}:
function _addwfrm(ax::AbstractAxes, d::DataHR{DataF1},
	id::String, la::LineAttributes, ga::GlyphAttributes, wfrmidx::Int)
	sweepnames = names(sweeps(d))

	for inds in subscripts(d)
		values = coordinates(d, inds)
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		cur_id = "$id; $crnid"
		cur_wfrmidx = inds[end]
		wfrm = _addwfrm(ax, d.elem[inds...], cur_id, la, ga, cur_wfrmidx)
	end
end

#Add waveforms from a collection of DataHR{DataF1}:
#(Convert DataHR{Number} => DataHR{DataF1} & add):
function _addwfrm{T<:Number}(ax::AbstractAxes, d::DataHR{T},
	id::String, la::LineAttributes, ga::GlyphAttributes, wfrmidx::Int)
	return _addwfrm(ax, DataHR{DataF1}(d), id, la, ga, wfrmidx)
end

#==Relay functions
===============================================================================#
#NOTE: wfrmidx identifies order of adding waveform
#wfrm might get reset to 1 for each subplot, or might be continuous across
#entire plot.
addwfrm(ax::AbstractAxes, wfrm::Waveform, wfrmidx::Int) =
	_addwfrm(ax, wfrm.data, wfrm.id, wfrm.line, wfrm.glyph, wfrmidx)

#Last line
