#EasyPlot utilities to handle multi-dimensional datasets
#-------------------------------------------------------------------------------

#==NOTE:
This module includes tools to use in case the plotting (rendering) tool does
not support multi-dimensional datasets directly.

 - Also provides support for folded x-axis scale.
 - iparam: Parameter index (used to pick color)
==#


#==Interface to build plots on different backends.
===============================================================================#

"""
    abstract type AbstractWfrmBuilder

Provides:
 - `addwfrm(b::AbstractWfrmBuilder, wfrm::Waveform, wfrmidx::Int)`

Requires:
 - addwfrm(b::T, d::DataF1, label::String, l::LineAttributes, g::GlyphAttributes, strip::Int) where T<:AbstractWfrmBuilder
 - needsfold(b::T) where T<:AbstractWfrmBuilder -> FoldedAxis() or nothing
"""
abstract type AbstractWfrmBuilder; end


#Register symbols that need to be implemented by backend interfacing code
addwfrm(b::AbstractWfrmBuilder, d::DataF1, label::String, l::LineAttributes, g::GlyphAttributes, strip::Int) =
	throw(MethodError(addwfrm, (b, d, label, l, g, strip)))
needsfold(b::AbstractWfrmBuilder) = throw(MethodError(needsfold, (b,)))


#==Catch missing implementations
===============================================================================#
_addwfrm(b::AbstractWfrmBuilder, d::T, args...; kwargs...) where T<:DataMD =
	throw(ArgumentError("Plotting if $T datasets is not supported."))


#==Helper functions
===============================================================================#
_get_crnid(v::Integer) = string(v)
_get_crnid(v::Real) = SI(v, ndigits=3) #Limit significant digits for readability


#==Adding DataF1 waveforms
===============================================================================#

#AbstractWfrmBuilder requested to fold data on axis:
function _addwfrm_fold(b::AbstractWfrmBuilder, f::FoldedAxis, d::DataF1,
   id::String, l::LineAttributes, g::GlyphAttributes, strip::Int)
	xspan = f.xmax - f.xmin
	if f.xmin != 0
		@warn("buildeye(): Does not currently support non-zero start time")
	end
	eye = buildeye(d, f.foldinterval, xspan, tstart=f.xstart)

	cur_id = id
	for segment in eye.data
		addwfrm(b, segment, cur_id, l, g, strip)
		cur_id = "" #Should avoid clutter in legend
	end
end

#Add a waveform to a typical plot:
function _addwfrm(b::AbstractWfrmBuilder, d::DataF1,
   id::String, l::LineAttributes, g::GlyphAttributes, strip::Int, iparam::Int)
	cur_id = l
	if nothing == cur_id.color
		cur_id = LineAttributes(l.style, l.width, iparam)
	end

	faxis = needsfold(b)
	if isnothing(faxis)
		addwfrm(b, d, id, cur_id, g, strip)
	else
		_addwfrm_fold(b, faxis, d, id, cur_id, g, strip)
	end
end


#==Adding DataRS waveforms
===============================================================================#

#Add collection of DataRS{DataF1} results:
function _addwfrm(b::AbstractWfrmBuilder, d::DataRS{DataF1}, crnid::String, id::String,
	l::LineAttributes, g::GlyphAttributes, strip::Int, iparam::Int)
	crnid = (""==crnid) ? crnid : "$crnid / "
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		v = d.sweep.v[i]
		curcrnid = "$crnid$sweepname=" * _get_crnid(v)
		cur_id = "$id; $curcrnid"
		wfrm = _addwfrm(b, d.elem[i], cur_id, l, g, strip, i)
	end
end

#Add collection of DataRS{Number} results:
function _addwfrm(b::AbstractWfrmBuilder, d::DataRS{T}, crnid::String, id::String,
	l::LineAttributes, g::GlyphAttributes, strip::Int, iparam::Int) where T<:Number
	cur_id = (""==crnid) ? id : "$id; $crnid"
	return _addwfrm(b, DataF1(d.sweep.v, d.elem), cur_id, l, g, strip, iparam)
end

#Add collection of DataRS{DataRS} results:
function _addwfrm(b::AbstractWfrmBuilder, d::DataRS{DataRS}, crnid::String, id::String,
	l::LineAttributes, g::GlyphAttributes, strip::Int, iparam::Int)
	crnid = (""==crnid) ? crnid : "$crnid / "
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		v = d.sweep.v[i]
		curcrnid = "$crnid$sweepname=" * _get_crnid(v)
		wfrm = _addwfrm(b, d.elem[i], curcrnid, id, l, g, strip, i)
	end
end

#If corner id !exists, use "" & relay call:
_addwfrm(b::AbstractWfrmBuilder, d::DataRS, id::String,
	l::LineAttributes, g::GlyphAttributes, strip::Int, iparam::Int) =
	_addwfrm(b, d, "", id, l, g, strip, iparam)


#==Adding DataHR waveforms
===============================================================================#

#Add waveforms from a collection of DataHR{DataF1}:
function _addwfrm(b::AbstractWfrmBuilder, d::DataHR{DataF1}, id::String,
	l::LineAttributes, g::GlyphAttributes, strip::Int, wfrmidx::Int)
	sweepnames = names(sweeps(d))

	for inds in subscripts(d)
		values = coordinates(d, inds)
		crnid=join(["$k="*_get_crnid(v) for (k,v) in zip(sweepnames,values)], " / ")
		cur_id = "$id; $crnid"
		cur_wfrmidx = inds[end]
		wfrm = _addwfrm(b, d.elem[inds...], cur_id, l, g, strip, cur_wfrmidx)
	end
end

#Add waveforms from a collection of DataHR{DataF1}:
#(Convert DataHR{Number} => DataHR{DataF1} & add):
function _addwfrm(b::AbstractWfrmBuilder, d::DataHR{T}, id::String,
	l::LineAttributes, g::GlyphAttributes, strip::Int, wfrmidx::Int) where T<:Number
	return _addwfrm(b, DataHR{DataF1}(d), id, l, g, strip, wfrmidx)
end

#==External interface (for backend implementation)
===============================================================================#
"""
    addwfrm(b::AbstractWfrmBuilder, wfrm::Waveform, wfrmidx::Int)

Have `EasyPlot` module break down a multi-dimensional `Waveform` into individual
traces, and call upon `AbstractWfrmBuilder` at the end to add them one-by-one.

Also segment data again in order to emulate a folded x-axis if `::FoldedAxis`
is returned by:
```julia-repl
needsfold(b::T) where T<:AbstractWfrmBuilder

# Notes
 - `wfrmidx` identifies order of added waveform for color selection purposes.
 - `wfrmidx` might get reset to 1 for each subplot, or might be continuous across all plots.
"""
addwfrm(b::AbstractWfrmBuilder, wfrm::Waveform, wfrmidx::Int) =
	_addwfrm(b, wfrm.data, wfrm.label, wfrm.line, wfrm.glyph, wfrm.strip, wfrmidx)

#Last line
