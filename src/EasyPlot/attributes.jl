#EasyPlot attribute system
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#


#==Main types
===============================================================================#

#struct OverwritableValue; end

#Alt?: NoChange, KeepValue
"Type for a value indicating an attribute should not be overwritten"
struct NoOverwrite; end

"""Singleton instance of type Nothing.
Identifies an attribute that should not be overwritten."""
const nooverwrite = NoOverwrite()

"Object that supports attributes changes"
abstract type AbstractAttributeReceiver; end

struct AttributeChangeData
	base::Tuple
	named::Base.Iterators.Pairs
end
#_"Constructor", avoiding signature conflicts
_AttributeChangeData(args...; kwargs...) = AttributeChangeData(args, kwargs)
_AttributeChangeData() = _AttributeChangeData(tuple())

struct AttributeChangeSpec{ID}
	data::AttributeChangeData
end
AttributeChangeSpec(id::Symbol, data::AttributeChangeData) =
	AttributeChangeSpec{id}(data)
AttributeChangeSpec(id::Symbol, data) =
	AttributeChangeSpec{id}(_AttributeChangeData(data))


#==Accessors
===============================================================================#
"""
	NoOverwrite(v)

Test whether a value is of type "NoOverwrite"
"""
NoOverwrite(v) = false
NoOverwrite(v::NoOverwrite) = true


#==Validation
===============================================================================#


#==Helper functions
===============================================================================#


#==Main functions
===============================================================================#

function attributes(;kwargs...)
	#Each key identifies "type of attribute" - as in `AttributeChangeSpec{type}`
	#Each value resolves/gets wrapped to an `AttributeChangeData`
	result = AttributeChangeSpec[]
	for (k, v) in kwargs
		push!(result, AttributeChangeSpec(k, v))
	end
	return result
end


#==apply() interface (implements set interface)
===============================================================================#
#Calls user-defined set functions:
#   _apply(ar::T, ::DS{AT}, args...; kwargs...)
function _apply(ar::AbstractAttributeReceiver, args::Tuple, kwargs::Base.Iterators.Pairs)
	getDS(::AttributeChangeSpec{AT}) where AT = DS(AT)

	for arg in args
		if !isa(arg, Vector{AttributeChangeSpec})
			T = typeof(ar)
			msg = "set(::$T, ...): non-keyword arguments must be created from attributes():\n    $arg"
			throw(ArgumentError(msg))
		end
		for attr in arg
			_apply(ar, getDS(attr), attr.data.base...; attr.data.named...)
		end
	end
	alist = attributes(;kwargs...)
	for attr in alist
		_apply(ar, getDS(attr), attr.data.base...; attr.data.named...)
	end
	return ar
end


#==Register constructors with cons() interface
===============================================================================#
cons(::DS{:a}; kwargs...) = attributes(; kwargs...)
cons(::DS{:attr}; kwargs...) = attributes(; kwargs...)
cons(::DS{:attribute_list}; kwargs...) = attributes(; kwargs...)


#==set() interface
===============================================================================#
"""
    set(args...; kwargs...)

Construct `AttributeChangeData` object if first argument is not special.

# Example
```julia-repl
set(style=:dash, width=3, color=:red)

#Change specs (`AttributeChangeSpec[]`) are created with `attributes`-`set` combinations: 
lineattributes = attributes(
    line = set(style=:dash, width=3, color=:red)
)
```
"""
set(args...; kwargs...) = AttributeChangeData(args, kwargs)

"""
    set(ar::AbstractAttributeReceiver, [alist1], [alist2], ...; [akv_expr1], [akv_expr1], ...)

Set attributes to an `::AbstractAttributeReceiver` object using:
 1. `AttributeChangeSpec[]` created by `attributes()` function, and
 2. Attribute key-value expressions, **as used** by `attributes()` function.

Applicable types implementing this feature can be found using:
```julia-repl
julia> subtypes(EasyPlot.AbstractAttributeReceiver)
```

See also: [`attributes`](@ref)
"""
set(ar::AbstractAttributeReceiver, args...; kwargs...) = _apply(ar, args, kwargs)


#==Show functions
===============================================================================#
function Base.show(io::IO, d::AttributeChangeData)
	print(io, "{", d.base, ", ")

	#Show "named" attribute changes:
	rmg = length(d.named)
	for (k,v) in d.named
		print(io, k, "=")
		show(io, v)
		rmg -= 1
		if rmg!=0; print(io, ", "); end
	end

	print(io, "}")
end


function Base.show(io::IO, s::AttributeChangeSpec{T}) where T
	print(io, "Δattr{$T}: ", s.data)
end


@static if false




end #@static

#Last line
