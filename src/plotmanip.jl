#EasyPlot: Plot manipulation tools
#-------------------------------------------------------------------------------


#==Type definitions
===============================================================================#

#Map an individual attribute to a setter function:
typealias AttributeFunctionMap Dict{Symbol, Function}

#Map an "AttributeList" property to a setter function:
#NOTE: Unlike individual attributes, typed obects do not need to be "set"
#      using keyword arguments
#TODO: Find way to restrict Dict to DataTypes inherited from AttributeList
#typealias AttributeListFunctionMap Dict{DataType, Function}
typealias AttributeListFunctionMap ObjectIdDict #{DataType, Function}

#==Helper functions
===============================================================================#

#Copy in only attributes that are not "nothing":
function ApplyNewAttributes{T<:AttributeList}(dest::T, newlist::T)
	for attrib in fieldnames(newlist)
		v = getfield(newlist,attrib)

		if v != nothing
			setfield!(dest, attrib, v)
		end
	end
end

#Core algorithm for "set" interface:
#-------------------------------------------------------------------------------
function _set(obj::Any, listfnmap::AttributeListFunctionMap, fnmap::AttributeFunctionMap, args...; kwargs...)
	for value in args
		setfn = get(listfnmap, typeof(value), nothing)

		if setfn != nothing
			setfn(obj, value)
		else
			argstr = string(typeof(value))
			objtype = typeof(obj)
			warn("Argument \"$argstr\" not recognized by \"set(::$objtype, ...)\"")
		end
	end

	for (arg, value) in kwargs
		setfn = get(fnmap, arg, nothing)

		if setfn != nothing
			setfn(obj, value)
		else
			argstr = string(arg)
			objtype = typeof(obj)
			warn("Argument \"$argstr\" not recognized by \"set(::$objtype, ...)\"")
		end
	end
	return
end


#==Plot-level functionality
===============================================================================#

settitle(p::Plot, a::String) = (p.title = a)
setdisplaylegend(p::Plot, a::Bool) = (p.displaylegend = a)


#==Subplot-level functionality
===============================================================================#

settitle(s::Subplot, a::String) = (s.title = a)
setaxes(s::Subplot, a::AxesAttributes) = ApplyNewAttributes(s.axes, a)
function seteyeparam(s::Subplot, a::EyeAttributes)
	ApplyNewAttributes(s.eye, a)
	s.style = :eye
end


#==Waveform-level functionality
===============================================================================#

setid(w::Waveform, a::String) = (w.id = a)
setline(w::Waveform, a::LineAttributes) = ApplyNewAttributes(w.line, a)
setglyph(w::Waveform, a::GlyphAttributes) = ApplyNewAttributes(w.glyph, a)

#==Define cleaner "set" interface (minimize # of "export"-ed functions)
===============================================================================#

#-------------------------------------------------------------------------------
const empty_listfnmap = AttributeListFunctionMap()
const empty_fnmap = AttributeFunctionMap()

#-------------------------------------------------------------------------------
const setplot_fnmap = AttributeFunctionMap([
	(:title, settitle)
	(:displaylegend, setdisplaylegend)
])
set(p::Plot, args...; kwargs...) =
	_set(p, empty_listfnmap, setplot_fnmap, args...; kwargs...)

#-------------------------------------------------------------------------------
const setsubplot_listfnmap = AttributeListFunctionMap([
	(AxesAttributes, setaxes)
	(EyeAttributes, seteyeparam)
])
const setsubplot_fnmap = AttributeFunctionMap([
	(:title, settitle)
])
set(s::Subplot, args...; kwargs...) =
	_set(s, setsubplot_listfnmap, setsubplot_fnmap, args...; kwargs...)

#-------------------------------------------------------------------------------
const setwfrm_listfnmap = AttributeListFunctionMap([
	(LineAttributes, setline)
	(GlyphAttributes, setglyph)
])
const setwfrm_fnmap = AttributeFunctionMap([
	(:id, setid)
])
set(w::Waveform, args...; kwargs...) =
	_set(w, setwfrm_listfnmap, setwfrm_fnmap, args...; kwargs...)

#Last line
