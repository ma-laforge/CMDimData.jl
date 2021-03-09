#Read/write DataMD datasets to/from HDF5
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#

#Possible T element types of DataHR{T} & DataRS{T}:
const MAP_STR2TELEM = Dict{String, Type}(
	"DataRS" => DataRS,
	"DataF1" => DataF1,
	"INT64" => Int64,
	"INT32" => Int32,
	"FLOAT64" => Float64,
	"FLOAT32" => Float32,
	"CPLX128" => Complex{Float64},
	"BOOL" => Bool,
)
const MAP_TELEM2STR = Dict{Type, String}(v=>k for (k,v) in MAP_STR2TELEM)

#==Helper functions
===============================================================================#

#Read/write dataset subtype:
#-------------------------------------------------------------------------------
_write_elemtype_attr(grp::HDF5.Group, ::DataHR{T}) where T = HDF5.write_attribute(grp, "ELEMTYPE", MAP_TELEM2STR[T])
_write_elemtype_attr(grp::HDF5.Group, ::DataRS{T}) where T = HDF5.write_attribute(grp, "ELEMTYPE", MAP_TELEM2STR[T])

_write_datatype_attr(grp::HDF5.Group, d::DataF1) = _write_datatype_attr(grp, DataF1)
function _write_datatype_attr(grp::HDF5.Group, d::DataHR)
	_write_datatype_attr(grp, DataHR)
	_write_elemtype_attr(grp, d)
end
function _write_datatype_attr(grp::HDF5.Group, d::DataRS)
	_write_datatype_attr(grp, DataRS)
	_write_elemtype_attr(grp, d)
end

#Read DataMD datatype, as required
function _read_mddatatype_attr(grp::HDF5.Group)
	basetype = _read_datatype_attr(grp)
	if !(basetype <: DataMD)
		path = HDF5.name(grp)
		throw(Meta.ParseError("Expected T<:DataMD, got $basetype:\n$path"))
	elseif (basetype <: DataHR) || (basetype <: DataRS)
		elemtype = MAP_STR2TELEM[HDF5.read_attribute(grp, "ELEMTYPE")]
		return basetype{elemtype}
	end
	return basetype
end


#Read/write PSweep (DataHR):
#-------------------------------------------------------------------------------
function writepsweep(grp::HDF5.Group, sweeps::Vector{PSweep})
	HDF5.write_attribute(grp, "sweepnames", names(sweeps))
	for i in 1:length(sweeps)
		HDF5.write_attribute(grp, "sweep$i", sweeps[i].v)
	end
end

function readpsweep(grp::HDF5.Group)
	sweepnames = HDF5.read_attribute(grp, "sweepnames")
	result = PSweep[]
	for i in 1:length(sweepnames)
		push!(result, PSweep(sweepnames[i], HDF5.read_attribute(grp, "sweep$i")))
	end
	return result
end


#==Main EasyDataHDF5 dataset read/write functions
===============================================================================#

#Read/write DataF1:
#-------------------------------------------------------------------------------
function _write_typed(grp::HDF5.Group, d::DataF1)
	_write_datatype_attr(grp, d)
	grp["x"] = d.x
	grp["y"] = d.y
end

function __read(::Type{DataF1}, grp::HDF5.Group)
	return DataF1(HDF5.read_dataset(grp, "x"), HDF5.read_dataset(grp, "y"))
end

#Read/write DataRS{T<:Number}:
#-------------------------------------------------------------------------------
function _write_typed(grp::HDF5.Group, d::DataRS{T}) where T<:Number
	_write_datatype_attr(grp, d)
	grp["data"] = d.elem
end

function __read(::Type{DataRS{T}}, grp::HDF5.Group) where T<:Number
	sweeps = readpsweep(grp)
	if length(sweeps) != 1
		path = HDF5.name(grp)
		throw(Meta.ParseError("Each DataRS node must have exactly one sweep:\n$path"))
	end
	data = grp["data"]
	return DataRS{T}(sweeps[1], data)
end

#Read/write DataHR{T<:Number}:
#-------------------------------------------------------------------------------
function _write_typed(grp::HDF5.Group, d::DataHR{T}) where T<:Number
	_write_datatype_attr(grp, d)
	writepsweep(grp, d.sweeps)
	grp["data"] = d.elem
end

function __read(::Type{DataHR{T}}, grp::HDF5.Group) where T<:Number
	sweeps = readpsweep(grp)
	data = HDF5.read_dataset(grp, "data")
	return DataHR{T}(sweeps, data)
end


#Read/write DataRS{DataF1}:
#-------------------------------------------------------------------------------
function _write_typed(grp::HDF5.Group, d::DataRS{DataF1})
	_write_datatype_attr(grp, d)
	writepsweep(grp, PSweep[d.sweep])

	for i in 1:length(d.elem)
		_write_typed(grp, "$i", d.elem[i])
	end
end

function __read(::Type{DataRS{DataF1}}, grp::HDF5.Group)
	sweeps = readpsweep(grp)
	if length(sweeps) != 1
		path = HDF5.name(grp)
		throw(Meta.ParseError("Each DataRS node must have exactly one sweep:\n$path"))
	end
	data = DataRS{DataF1}(sweeps[1])

	for i in 1:length(data.elem)
		data.elem[i] = _read_datamd(grp, "$i")
	end

	return data
end

#Read/write DataHR{DataF1}:
#-------------------------------------------------------------------------------
function _write_typed(grp::HDF5.Group, d::DataHR{DataF1})
	_write_datatype_attr(grp, d)
	writepsweep(grp, d.sweeps)

	for inds in subscripts(d)
		subpath = join(inds, "/")
		_write_typed(grp, subpath, d.elem[inds...])
	end
end

function __read(::Type{DataHR{DataF1}}, grp::HDF5.Group)
	sweeps = readpsweep(grp)
	data = DataHR{DataF1}(sweeps)

	for inds in subscripts(data)
		subpath = join(inds, "/")
		data.elem[inds...] = _read_datamd(grp, "$subpath")
	end

	return data
end

#Read/write DataRS{DataRS}:
#-------------------------------------------------------------------------------
function _write_typed(grp::HDF5.Group, d::DataRS{DataRS})
	_write_datatype_attr(grp, d)
	writepsweep(grp, PSweep[d.sweep])

	for i in 1:length(d.elem)
		_write_typed(grp, "$i", d.elem[i])
	end
end

function __read(::Type{DataRS{DataRS}}, grp::HDF5.Group)
	sweeps = readpsweep(grp)
	if length(sweeps) != 1
		throw(Meta.ParseError("Each DataRS node must have exactly one sweep:\n$path"))
	end
	data = DataRS{DataRS}(sweeps[1])

	for i in 1:length(data.elem)
		data.elem[i] = _read_datamd(grp, "$i")
	end

	return data
end


#Catch-all for _write_typed() interface:
#-------------------------------------------------------------------------------
function _write_typed(grp::HDF5.Group, name::String, d::DataMD)
	objgrp = creategrp(grp, name)
	_write_typed(objgrp, d)
end

#Traps for typed _read_typed() function (because we need element type for DataRS & DataHR):
#-------------------------------------------------------------------------------
function __read(::Union{Type{DataHR},Type{DataRS}}, grp::HDF5.Group)
	dtype = _read_mddatatype_attr(grp)
		path = HDF5.name(grp)
	return __read(dtype, grp) #Call more specific version
end

#Read DataMD types (start point):
#(Slightly more direct than calling _read_typed(grp, name) because it knows
#to look for element type as well)
#-------------------------------------------------------------------------------
function _read_datamd(grp::HDF5.Group, name::String)
	dgrp = opengrp(grp, name)
	dtype = _read_mddatatype_attr(dgrp)
	return __read(dtype, dgrp) #Read appropriate data structure
end


#==User-level interface:
===============================================================================#

function Base.write(w::EasyDataWriter, d::DataMD, name::String)
	grp = opengrp(w, hdf5dataroot)
	return _write_typed(grp, name, d)
end
function readdata(r::EasyDataReader, name::String) #Avoids specifying ::Type{DataMD}
	grp = opengrp(r, hdf5dataroot)
	return _read_datamd(grp, name)
end
Base.read(::Type{DataMD}, r::EasyDataReader, name::String) = readdata(r, name)

#Last Line
