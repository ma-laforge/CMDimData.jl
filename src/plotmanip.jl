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
typealias AttributeListFunctionMap Dict{DataType, Function}

#==Helper functions
===============================================================================#

#Copy in only attributes that are not "nothing":
function ApplyNewAttributes{T<:AttributeList}(dest::T, newlist::T)
	for attrib in names(newlist)
		v = eval(:($newlist.$attrib))

		if v != nothing
			eval(:($dest.$attrib=$newlist.$attrib))
		end
	end
end

#Core algorithm for "set" interface:
#-------------------------------------------------------------------------------
function set(obj::Any, listfnmap::AttributeListFunctionMap, fnmap::AttributeFunctionMap, args...; kwargs...)
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


#==Subplot-level functionality
===============================================================================#

settitle(s::Subplot, a::String) = (s.title = a)
setaxes(s::Subplot, a::AxesAttributes) = ApplyNewAttributes(s.axes, a)


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
])
set(p::Plot, args...; kwargs...) =
	set(p, empty_listfnmap, setplot_fnmap, args...; kwargs...)

#-------------------------------------------------------------------------------
const setsubplot_listfnmap = AttributeListFunctionMap([
	(AxesAttributes, setaxes)
])
const setsubplot_fnmap = AttributeFunctionMap([
	(:title, settitle)
])
set(s::Subplot, args...; kwargs...) =
	set(s, setsubplot_listfnmap, setsubplot_fnmap, args...; kwargs...)

#-------------------------------------------------------------------------------
const setwfrm_listfnmap = AttributeListFunctionMap([
	(LineAttributes, setline)
	(GlyphAttributes, setglyph)
])
const setwfrm_fnmap = AttributeFunctionMap([
	(:id, setid)
])
set(w::Waveform, args...; kwargs...) =
	set(w, setwfrm_listfnmap, setwfrm_fnmap, args...; kwargs...)

#Last line
