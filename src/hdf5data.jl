#Save/load DataMD datasets to/from HDF5
#-------------------------------------------------------------------------------

#==Useful constants
===============================================================================#

#High-level data types that can be written:
const MAP_STR2TDATA = Dict{AbstractString, DataType}(
	"DataF1" => DataF1,
	"DataHR" => DataHR,
	"DataRS" => DataRS,
)
const MAP_TDATA2STR = Dict{DataType, AbstractString}([v=>k for (k,v) in MAP_STR2TDATA])

#Possible element types of high-level data types:
const MAP_STR2TELEM = Dict{AbstractString, DataType}(
	"DataRS" => DataRS,
	"DataF1" => DataF1,
	"INT64" => Int64,
	"INT32" => Int32,
	"FLOAT64" => Float64,
	"FLOAT32" => Float32,
	"CPLX128" => Complex{Float64},
	"BOOL" => Bool,
)
const MAP_TELEM2STR = Dict{DataType, AbstractString}([v=>k for (k,v) in MAP_STR2TELEM])

#==Helper functions
===============================================================================#

#Read/write dataset subtype:
#-------------------------------------------------------------------------------
writesubtype{T}(grp::HDF5Group, ::Type{DataHR{T}}) = a_write(grp, "subtype", MAP_TELEM2STR[T])
writesubtype{T}(grp::HDF5Group, ::Type{DataRS{T}}) = a_write(grp, "subtype", MAP_TELEM2STR[T])

readsubtype{T}(grp::HDF5Group, ::Type{T}) = T
readsubtype(grp::HDF5Group, ::Type{DataHR}) = DataHR{MAP_STR2TELEM[a_read(grp, "subtype")]}
readsubtype(grp::HDF5Group, ::Type{DataRS}) = DataRS{MAP_STR2TELEM[a_read(grp, "subtype")]}

#Read/write PSweep:
#-------------------------------------------------------------------------------
function writepsweep(grp::HDF5Group, sweeps::Vector{PSweep})
	a_write(grp, "sweepnames", names(sweeps))
	for i in 1:length(sweeps)
		a_write(grp, "sweep$i", sweeps[i].v)
	end
end

function readpsweep(grp::HDF5Group)
	sweepnames = a_read(grp, "sweepnames")
	result = PSweep[]
	for i in 1:length(sweepnames)
		push!(result, PSweep(sweepnames[i], a_read(grp, "sweep$i")))
	end
	return result
end


#==Main EasyDataHDF5 dataset read/write functions
===============================================================================#

#Read/write DataF1:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, path::AbstractString, d::DataF1)
	grp = creategrp(w, path)
	a_write(grp, "type", MAP_TDATA2STR[DataF1])
	grp["x"] = d.x
	grp["y"] = d.y
end

function Base.read(r::EasyDataReader, path::AbstractString, ::Type{DataF1})
	grp = opengrp(r, path)
	return DataF1(d_read(grp, "x"), d_read(grp, "y"))
end

#Read/write DataRS{T<:Number}:
#-------------------------------------------------------------------------------
function Base.write{T<:Number}(w::EasyDataWriter, path::AbstractString, d::DataRS{T})
	grp = creategrp(w, path)
	a_write(grp, "type", MAP_TDATA2STR[DataRS])
	writesubtype(grp, typeof(d))
	writepsweep(grp, Sweep[d.sweep])
	grp["data"] = d.elem
end

function Base.read{T<:Number}(r::EasyDataReader, path::AbstractString, ::Type{DataRS{T}})
	grp = opengrp(r, path)
	sweeps = readpsweep(grp)
	if length(sweeps) != 1
		throw(ParseError("Each DataRS node must have exactly one sweep:\n$path"))
	end
	data = d_read(grp, "data")
	return DataRS{T}(sweeps[1], data)
end

#Read/write DataHR{T<:Number}:
#-------------------------------------------------------------------------------
function Base.write{T<:Number}(w::EasyDataWriter, path::AbstractString, d::DataHR{T})
	grp = creategrp(w, path)
	a_write(grp, "type", MAP_TDATA2STR[DataHR])
	writesubtype(grp, typeof(d))
	writepsweep(grp, d.sweeps)
	grp["data"] = d.elem
end

function Base.read{T<:Number}(r::EasyDataReader, path::AbstractString, ::Type{DataHR{T}})
	grp = opengrp(r, path)
	sweeps = readpsweep(grp)
	data = d_read(grp, "data")
	return DataHR{T}(sweeps, data)
end


#Read/write DataRS{DataF1}:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, path::AbstractString, d::DataRS{DataF1})
	grp = creategrp(w, path)
	a_write(grp, "type", MAP_TDATA2STR[DataRS])
	writesubtype(grp, typeof(d))
	writepsweep(grp, PSweep[d.sweep])

	for i in 1:length(d.elem)
		write(w, "$path/$i", d.elem[i])
	end
end

function Base.read(r::EasyDataReader, path::AbstractString, ::Type{DataRS{DataF1}})
	grp = opengrp(r, path)
	sweeps = readpsweep(grp)
	if length(sweeps) != 1
		throw(ParseError("Each DataRS node must have exactly one sweep:\n$path"))
	end
	data = DataRS{DataF1}(sweeps[1])

	for i in 1:length(data.elem)
		data.elem[i] = read(r, "$path/$i", DataF1)
	end

	return data
end

#Read/write DataHR{DataF1}:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, path::AbstractString, d::DataHR{DataF1})
	grp = creategrp(w, path)
	a_write(grp, "type", MAP_TDATA2STR[DataHR])
	writesubtype(grp, typeof(d))
	writepsweep(grp, d.sweeps)

	for inds in subscripts(d)
		subpath = join(inds, "/")
		write(w, "$path/$subpath", d.elem[inds...])
	end
end

function Base.read(r::EasyDataReader, path::AbstractString, ::Type{DataHR{DataF1}})
	grp = opengrp(r, path)
	sweeps = readpsweep(grp)
	data = DataHR{DataF1}(sweeps)

	for inds in subscripts(data)
		subpath = join(inds, "/")
		data.elem[inds...] = read(r, "$path/$subpath", DataF1)
	end

	return data
end

#Read/write DataRS{DataRS}:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, path::AbstractString, d::DataRS{DataRS})
	grp = creategrp(w, path)
	a_write(grp, "type", MAP_TDATA2STR[DataRS])
	writesubtype(grp, typeof(d))
	writepsweep(grp, PSweep[d.sweep])

	for i in 1:length(d.elem)
		write(w, "$path/$i", d.elem[i])
	end
end

function Base.read(r::EasyDataReader, path::AbstractString, ::Type{DataRS})
	grp = opengrp(r, path)
	dtype = MAP_STR2TDATA[a_read(grp, "type")]
	if dtype != DataRS
		throw(ParseError("Expecting DataRS node:\n$path"))
	end
	dtype = readsubtype(grp, dtype)
	return read(r, path, dtype) #Read appropriate data structure
end

function Base.read(r::EasyDataReader, path::AbstractString, ::Type{DataRS{DataRS}})
	grp = opengrp(r, path)
	sweeps = readpsweep(grp)
	if length(sweeps) != 1
		throw(ParseError("Each DataRS node must have exactly one sweep:\n$path"))
	end
	data = DataRS{DataRS}(sweeps[1])

	for i in 1:length(data.elem)
		data.elem[i] = read(r, "$path/$i", DataRS)
	end

	return data
end

#Read/write DataMD:
#-------------------------------------------------------------------------------
function Base.read(r::EasyDataReader, path::AbstractString, ::Type{DataMD})
	grp = opengrp(r, path)
	dtype = MAP_STR2TDATA[a_read(grp, "type")]
	dtype = readsubtype(grp, dtype)
	return read(r, path, dtype) #Read appropriate data structure
end

#NOTE: Base.write signatures above will trap appropriate DataMD subtypes.


#==Exported (user-level) functions:
===============================================================================#

#NOTE: Most user-level read/write operations are already exported (above)

#Last Line
