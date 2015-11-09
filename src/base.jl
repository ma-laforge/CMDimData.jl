#EasyData base types & core functions
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#

#==Main data structures
===============================================================================#

immutable EasyDataHDF5 <: FileIO2.DataFormat; end
typealias EDH5Fmt EasyDataHDF5 #More succinct

type EasyDataReader <: AbstractReader{EasyDataHDF5}
	reader::HDF5.HDF5File
end

type EasyDataWriter <: AbstractWriter{EasyDataHDF5}
	writer::HDF5.HDF5File
end


#==Helper data structures
===============================================================================#

#Dispatchable type identifying paths within HDF5 files:
#-------------------------------------------------------------------------------
type HDF5Path{Symbol}
	subpath::AbstractString
end
#typealias ElementPath HDF5Path{:plotelement}
typealias PlotElemPath HDF5Path{:plotelement}
typealias DataPath HDF5Path{:data}

#Also changes string():
Base.print(io::IO, p::HDF5Path) = print(io, p.subpath)


#==Helper functions
===============================================================================#

macro accessfield(_type,_field)
	return esc(:($_type.$_field))
end

#Write out attribute to HDF5 file (use wrapper instead of extending HDF5.a_write):
writeattr(grp::HDF5.HDF5Group, k::AbstractString, v::Any) = a_write(grp, k, v)
writeattr(grp::HDF5.HDF5Group, k::AbstractString, v::Symbol) =
	a_write(grp, k, ["CONST", string(v)])

function readattr(grp::HDF5.HDF5Group, k::AbstractString)
	v = a_read(grp, k)
	if isa(v,Vector) && eltype(v)<:AbstractString && 2==length(v) && "CONST" == v[1]
		return symbol(v[2])
	else
		return v
	end
end


#==Open/close functions
===============================================================================#

#Open/close EasyDataHDF5 files:
#-------------------------------------------------------------------------------
function Base.open(::Type{EasyDataWriter}, file::File{EasyDataHDF5})
	writer = h5open(file.path, "w")
	return EasyDataWriter(writer)
end
Base.close(w::EasyDataWriter) = close(w.writer)

function Base.open(::Type{EasyDataReader}, file::File{EasyDataHDF5})
	reader = h5open(file.path, "r")
	return EasyDataReader(reader)
end
Base.close(r::EasyDataReader) = close(r.reader)

#Last line
