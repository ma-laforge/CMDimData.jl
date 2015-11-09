#Save/load DataMD datasets to/from HDF5
#-------------------------------------------------------------------------------

#==Useful constants
===============================================================================#
const hdf5dataroot = "data"

const MAP_STR2TDATAMD = Dict{AbstractString, DataType}(
	"Data2D" => Data2D,
	"DataHR" => DataHR,
)
const MAP_TDATAMD2STR = Dict{DataType, AbstractString}([v=>k for (k,v) in MAP_STR2TDATAMD])
const MAP_STR2TLEAF = Dict{AbstractString, DataType}(
	"Data2D" => Data2D,
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
writesubtype{T<:Data2D}(grp::HDF5Group, ::Type{DataHR{T}}) = a_write(grp, "subtype", MAP_TDATAMD2STR[Data2D])

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

#Read/write Data2D:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, d::Data2D, elem::AbstractString)
	grp = creategrp(w, DataPath(elem))
	a_write(grp, "type", MAP_TDATAMD2STR[Data2D])
	grp["x"] = d.x
	grp["y"] = d.y
end

function Base.read(::Type{Data2D}, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, DataPath(elem))
	return Data2D(d_read(grp, "x"), d_read(grp, "y"))
end

#Read/write DataHR{T<:Number}:
#-------------------------------------------------------------------------------
function Base.write{T<:Number}(w::EasyDataWriter, d::DataHR{T}, elem::AbstractString)
	grp = creategrp(w, DataPath(elem))
	a_write(grp, "type", MAP_TDATAMD2STR[DataHR])
	writesubtype(grp, typeof(d))
	writepsweep(grp, d.sweeps)
	grp["data"] = d.subsets
end

function Base.read{T<:Number}(::Type{DataHR{T}}, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, DataPath(elem))
	sweeps = readpsweep(grp)
	data = d_read(grp, "data")
	return DataHR{T}(sweeps, data)
end

#Read/write DataHR{Data2D}:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, d::DataHR{Data2D}, elem::AbstractString)
	grp = creategrp(w, DataPath(elem))
	a_write(grp, "type", MAP_TDATAMD2STR[DataHR])
	writesubtype(grp, typeof(d))
	writepsweep(grp, d.sweeps)

	for coord in subscripts(d)
		subpath = join(coord, "/")
		write(w, d.subsets[coord...], "$elem/$subpath")
	end
end

function Base.read(::Type{DataHR{Data2D}}, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, DataPath(elem))
	sweeps = readpsweep(grp)
	data = DataHR{Data2D}(sweeps)

	for coord in subscripts(data)
		subpath = join(coord, "/")
		data.subsets[coord...] = read(Data2D, r, "$elem/$subpath")
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
#FileIO2.save(d::DataMD, path::File{EasyDataHDF5}) = save([d], path)
#FileIO2.save(d::DataMD, path::AbstractString) = save([d], path)

#Last Line
