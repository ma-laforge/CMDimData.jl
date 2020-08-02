#EasyData base types & core functions
#-------------------------------------------------------------------------------


#==Version info:
===============================================================================#
function _get_CMDimData_versionstr()
	#Adds to load up time... Maybe a more efficient way??
	try
		deps = Pkg.dependencies()
		uuid = Base.UUID("70385e83-f223-47f4-874b-539892411e49") #CMDimData
		vinfo = deps[uuid].version
		return "Source: CMDimData.EasyData (v$vinfo)"
	catch
		vinfo = v"0.2.0"
		@warn("Old version of Julia. Package version number written to file might be inexact.")
		return "Source: CMDimData.EasyData (> v$vinfo)???"
	end
end


#==Useful constants
===============================================================================#
const hdf5plotcollroot = "plots"
const hdf5dataroot = "data"
const _versionstr = _get_CMDimData_versionstr()


#==Main data structures
===============================================================================#

mutable struct EasyDataReader
	reader::HDF5.HDF5File
end

mutable struct EasyDataWriter
	writer::HDF5.HDF5File
end


#==Helper functions
===============================================================================#

#Create/open HDF5 groups:
creategrp(w::EasyDataWriter, path::String) = HDF5.g_create(w.writer, path)
creategrp(grp::HDF5Group, sub::String) = HDF5.g_create(grp, sub)
opengrp(w::EasyDataWriter, path::String) = HDF5.g_open(w.writer, path)
opengrp(r::EasyDataReader, path::String) = HDF5.g_open(r.reader, path)
opengrp(grp::HDF5Group, sub::String) = HDF5.g_open(grp, sub)

function _write_length_attr(grp::HDF5Group, v::Vector)
	HDF5.attrs(grp)["LENGTH"] = length(v)
end
_read_length_attr(::Type{Vector}, grp::HDF5Group) = HDF5.read(HDF5.attrs(grp)["LENGTH"])


#==User-level interface:
===============================================================================#
function openwriter(path::String)
	w = EasyDataWriter(HDF5.h5open(path, "w"))
	creategrp(w, hdf5dataroot)
	creategrp(w, hdf5plotcollroot)
	HDF5.d_write(w.writer, "VERSION_INFO", _versionstr)
	return w
end
Base.close(w::EasyDataWriter) = close(w.writer)
function openwriter(fn::Function, path::String)
	w = openwriter(path)
	try
		fn(w)
	finally
		close(w)
	end
end

openreader(path::String) = EasyDataReader(HDF5.h5open(path, "r"))
Base.close(r::EasyDataReader) = close(r.reader)
function openreader(fn::Function, path::String)
	w = openreader(path)
	try
		fn(w)
	finally
		close(w)
	end
end

#Last line
