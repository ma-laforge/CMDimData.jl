#Save/load DataMD datasets to/from HDF5
#-------------------------------------------------------------------------------

#==Useful constants
===============================================================================#
const hdf5dataroot = "data"

const MAP_STR2TDATAMD = Dict{AbstractString, DataType}(
	"DataF1" => DataF1,
	"DataHR" => DataHR,
)
const MAP_TDATAMD2STR = Dict{DataType, AbstractString}([v=>k for (k,v) in MAP_STR2TDATAMD])
const MAP_STR2TLEAF = Dict{AbstractString, DataType}(
	"DataF1" => DataF1,
	"INT64" => Int64,
	"INT32" => Int32,
	"FLOAT64" => Float64,
	"FLOAT32" => Float32,
	"BOOL" => Bool,
)
const MAP_TLEAF2STR = Dict{DataType, AbstractString}([v=>k for (k,v) in MAP_STR2TLEAF])

#==Helper functions
===============================================================================#

#Create/open HDF5 groups:
creategrp(w::EasyDataWriter, path::DataPath) =
	g_create(w.writer, "$hdf5dataroot/$(string(path))")
opengrp(w::EasyDataWriter, path::DataPath) =
	g_open(w.writer, "$hdf5dataroot/$(string(path))")
opengrp(r::EasyDataReader, path::DataPath) =
	g_open(r.reader, "$hdf5dataroot/$(string(path))")

#Read/write dataset subtype:
#-------------------------------------------------------------------------------
writesubtype{T<:Number}(grp::HDF5Group, ::Type{DataHR{T}}) = a_write(grp, "subtype", MAP_TLEAF2STR[T])
writesubtype{T<:DataF1}(grp::HDF5Group, ::Type{DataHR{T}}) = a_write(grp, "subtype", MAP_TDATAMD2STR[DataF1])

readsubtype{T}(grp::HDF5Group, ::Type{T}) = T
readsubtype(grp::HDF5Group, ::Type{DataHR}) = DataHR{MAP_STR2TLEAF[a_read(grp, "subtype")]}

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
function Base.write(w::EasyDataWriter, d::DataF1, elem::AbstractString)
	grp = creategrp(w, DataPath(elem))
	a_write(grp, "type", MAP_TDATAMD2STR[DataF1])
	grp["x"] = d.x
	grp["y"] = d.y
end

function Base.read(::Type{DataF1}, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, DataPath(elem))
	return DataF1(d_read(grp, "x"), d_read(grp, "y"))
end

#Read/write DataHR{T<:Number}:
#-------------------------------------------------------------------------------
function Base.write{T<:Number}(w::EasyDataWriter, d::DataHR{T}, elem::AbstractString)
	grp = creategrp(w, DataPath(elem))
	a_write(grp, "type", MAP_TDATAMD2STR[DataHR])
	writesubtype(grp, typeof(d))
	writepsweep(grp, d.sweeps)
	grp["data"] = d.elem
end

function Base.read{T<:Number}(::Type{DataHR{T}}, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, DataPath(elem))
	sweeps = readpsweep(grp)
	data = d_read(grp, "data")
	return DataHR{T}(sweeps, data)
end

#Read/write DataHR{DataF1}:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, d::DataHR{DataF1}, elem::AbstractString)
	grp = creategrp(w, DataPath(elem))
	a_write(grp, "type", MAP_TDATAMD2STR[DataHR])
	writesubtype(grp, typeof(d))
	writepsweep(grp, d.sweeps)

	for inds in subscripts(d)
		subpath = join(inds, "/")
		write(w, d.elem[inds...], "$elem/$subpath")
	end
end

function Base.read(::Type{DataHR{DataF1}}, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, DataPath(elem))
	sweeps = readpsweep(grp)
	data = DataHR{DataF1}(sweeps)

	for inds in subscripts(data)
		subpath = join(inds, "/")
		data.elem[inds...] = read(DataF1, r, "$elem/$subpath")
	end

	return data
end

#Read/write DataMD:
#-------------------------------------------------------------------------------
function Base.read(::Type{DataMD}, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, DataPath(elem))
	dtype = MAP_STR2TDATAMD[a_read(grp, "type")]
	dtype = readsubtype(grp, dtype)
	return read(dtype, r, elem) #Read appropriate sub-type
end


#==Exported (user-level) functions:
===============================================================================#

#Save/load DataMD to EasyDataHDF5 file:
#-------------------------------------------------------------------------------
#TODO: Implement here

#Save individual datasets:
#Base.write(file::File{EasyDataHDF5}, d::DataMD) = write([d], path)
#Base.write(path::AbstractString, d::DataMD) = write([d], path)

#Last Line
