#Read/write values with type info to HDF5.
#-------------------------------------------------------------------------------

#=
Useful when reading in values that might be of unknown type. Thus, they are written
to .hdf5 with metadata identifying the data type.

Note that many base types are alreay understood by the hdf5 format, so no need to
write metadata.

# Interface to be implemented

 - _write_typed(grp::HDF5Group, name::String, v::NEWTYPE): Writes out type data
with type name in attributes.
 - __read(::Type{NEWTYPE}, ds::HDF5Dataset): Read in data from NEWTYPE (leaf datatypes)
 - __read(::Type{NEWTYPE}, ds::HDF5Group): Read in data from NEWTYPE (complex structures)

## NOTE:
 - Must register type with MAP_STR2TYPE
=#


#==Useful constants
===============================================================================#

const NOTHING_STRING = "nothing"

#Data types that have read/write functions implemented:
#NOTE: limit supported types so that not all concrete types need separate read/write functions
const MAP_STR2TYPE = Dict{String, Type}(
	"Nothing" => Nothing,
	"Symbol" => Symbol,
	"RGBA" => Colorant, #Write out any Colorant to an #RRGGBBAA string


	#Higher-level types
	"Extents1D" => Extents1D,
	"Axis" => Axis,
	"FoldedAxis" => FoldedAxis,
	"LineAttributes" => LineAttributes,
	"GlyphAttributes" => GlyphAttributes,
	"Waveform" => Waveform,
	"YStrip" => YStrip,
	"DataF1" => DataF1,
	"DataHR" => DataHR,
	"DataRS" => DataRS,
)
const MAP_TYPE2STR = Dict{Type, String}(v=>k for (k,v) in MAP_STR2TYPE)

#Types that already have built-in HDF5 support (just write out natively):
const Types_HDF5Support = Union{Number, String}


#==Type declarations
===============================================================================#
#HDF5 reader will auto-detect type correctly:
struct Type_HDF5AutoDetect; end


#==Read/write type name in attributes
===============================================================================#
function _write_datatype_attr(ds::Union{HDF5Group, HDF5Dataset}, ::Type{T}) where T
	typestr = MAP_TYPE2STR[T]
	HDF5.attrs(ds)["TYPE"] = typestr
end

function _read_datatype_attr(ds::Union{HDF5Group, HDF5Dataset})
	if !HDF5.exists(HDF5.attrs(ds), "TYPE")
		return Type_HDF5AutoDetect
	end

	typestr = HDF5.read(HDF5.attrs(ds)["TYPE"])
	return MAP_STR2TYPE[typestr]
end


#==_write_typed(): Simple (leaf) datatypes. (Labels with type name.)
===============================================================================#
#Default behaviour: Assumes value is supported by HDF5 format
function _write_typed(grp::HDF5Group, name::String, v::T) where T<:Types_HDF5Support
	grp[name] = v
	return #No need to _write_datatype_attr
end
function _write_typed(grp::HDF5Group, name::String, v::Nothing)
	grp[name] = NOTHING_STRING #Redundancy check/easier to read HDF5 file
	_write_datatype_attr(grp[name], Nothing)
end
function _write_typed(grp::HDF5Group, name::String, v::Symbol)
	grp[name] = String(v)
	_write_datatype_attr(grp[name], Symbol)
end
function _write_typed(grp::HDF5Group, name::String, v::Colorant)
	vstr = "#" * Colors.hex(v, :RRGGBBAA)
	grp[name] = vstr
	_write_datatype_attr(grp[name], Colorant)
end


#==_write_typed(): More complex structures. (Labels with type name.)
===============================================================================#


#==__read(): Read data, but not type information.
===============================================================================#

#Types with built-in HDF5 support:
__read(::Type{Type_HDF5AutoDetect}, ds::HDF5Dataset) = HDF5.read(ds)

function __read(::Type{Type_HDF5AutoDetect}, ds::HDF5Dataset)
	return HDF5.read(ds)
end
function __read(::Type{Nothing}, ds::HDF5Dataset)
	v = HDF5.read(ds)
	nstr = NOTHING_STRING
	if nstr != v
		path = HDF5.name(ds)
		throw(Meta.ParseError("__read(::Nothing, ::HDF5Group): Read $v != $nstr:\n$path"))
	end
	return nothing
end
function __read(::Type{Symbol}, ds::HDF5Dataset)
	v = HDF5.read(ds)
	return Symbol(v)
end
function __read(::Type{Colorant}, ds::HDF5Dataset)
	v = HDF5.read(ds)
	return parse(Colorant, v)
end


#==Read/Write functions for high-level objects
===============================================================================#
function _writeobjectdata(grp::HDF5Group, obj::T) where T
	for fname in fieldnames(T)
		v = getfield(obj, fname)
		_write_typed(grp, String(fname), v)
	end
	return
end

#When type is unknown, _read_typed() figures it out:
function _read_typed(grp::HDF5Group, name::String)
	ds = grp[name]
	t = _read_datatype_attr(ds)
	return __read(t, ds)
end

#_readobjectdata: Needs object values to be written out with _write_typed():
function _readobjectdata(::Type{T}, grp::HDF5Group) where T
	vlist = Array{Any}(nothing, fieldcount(T))
	for (i, fname) in enumerate(fieldnames(T))
		vlist[i] = _read_typed(grp, String(fname))
	end
	return T(vlist...)
end


#==Catch-alls (default behaviour)
===============================================================================#

__read(::Type{T}, grp::HDF5Group) where T = _readobjectdata(T, grp)
function _write_typed(grp::HDF5Group, name::String, v::T) where T #Catch-all
	#NOTE: need "name" parameter so that call signature is same with built-ins
	#      (a string is not dataset, not a group)
	objgrp = creategrp(grp, name)
	_writeobjectdata(objgrp, v)
	_write_datatype_attr(objgrp, T)
end

#Last line
