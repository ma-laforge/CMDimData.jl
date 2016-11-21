#EasyData base types & core functions
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#

#==Main data structures
===============================================================================#

immutable EasyDataHDF5 <: FileIO2.DataFormat; end
FileIO2.File(::FileIO2.Shorthand{:edh5}, path::String) = File{EasyDataHDF5}(path)

type EasyDataReader <: AbstractReader{EasyDataHDF5}
	reader::HDF5.HDF5File
end

type EasyDataWriter <: AbstractWriter{EasyDataHDF5}
	writer::HDF5.HDF5File
end


#==Helper functions
===============================================================================#

#Write out attribute to HDF5 file (use wrapper instead of extending HDF5.a_write):
writeattr(grp::HDF5.HDF5Group, k::String, v::Any) = a_write(grp, k, v)
writeattr(grp::HDF5.HDF5Group, k::String, v::Symbol) =
	a_write(grp, k, ["CONST", string(v)])

function readattr(grp::HDF5.HDF5Group, k::String)
	v = a_read(grp, k)
	if isa(v,Vector) && eltype(v)<:String && 2==length(v) && "CONST" == v[1]
		return Symbol(v[2])
	else
		return v
	end
end

#Create/open HDF5 groups:
creategrp(w::EasyDataWriter, path::String) = g_create(w.writer, path)
opengrp(w::EasyDataWriter, path::String) = g_open(w.writer, path)
opengrp(r::EasyDataReader, path::String) = g_open(r.reader, path)


#==Open/close functions
===============================================================================#
#Open/close EasyDataHDF5 files:
#-------------------------------------------------------------------------------
function Base.open(::Type{EasyDataWriter}, path::String;
	opt::IOOptionsWrite=IOOptions(write=true))
	#NOTE: opt ignored for now.
	writer = h5open(path, "w")
	return EasyDataWriter(writer)
end
Base.close(w::EasyDataWriter) = close(w.writer)

function Base.open(::Type{EasyDataReader}, path::String)
	reader = h5open(path, "r")
	return EasyDataReader(reader)
end
Base.close(r::EasyDataReader) = close(r.reader)

#==Un-"Exported", user-level functions:
===============================================================================#

#Explicit module-level read/write functions:
#-------------------------------------------------------------------------------
_read(filepath::String, h5path::String, args...; kwargs...) =
	read(EasyDataReader, filepath, h5path, args...; kwargs...)

_write(filepath::String, h5path::String, args...; kwargs...) =
	write(EasyDataWriter, filepath, h5path, args...; kwargs...)


#Last line
