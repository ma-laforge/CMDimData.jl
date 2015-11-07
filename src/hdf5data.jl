#Save/load DataMD datasets to/from HDF5
#-------------------------------------------------------------------------------

#==Useful constants
===============================================================================#
const hdf5dataroot = "data"
const ID_DATA2D = "Data2D"
const ID_DATAHR = "DataHR"
const DATAMDTYPES = Dict{AbstractString, DataType}(
	ID_DATA2D => Data2D,
	ID_DATAHR => DataHR,
)

#==Helper functions
===============================================================================#

#Create/open HDF5 groups:
creategrp(w::EasyDataWriter, path::DataPath) =
	g_create(w.writer, "$hdf5dataroot/$(string(path))")
opengrp(w::EasyDataWriter, path::DataPath) =
	g_open(w.writer, "$hdf5dataroot/$(string(path))")
opengrp(r::EasyDataReader, path::DataPath) =
	g_open(r.reader, "$hdf5dataroot/$(string(path))")




#==Main EasyDataHDF5 dataset read/write functions
===============================================================================#

#Read/write Data2D:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, d::Data2D, elem::AbstractString)
	grp = creategrp(w, DataPath(elem))
	a_write(grp, "type", ID_DATA2D)
	grp["x"] = d.x
	grp["y"] = d.y
end

function Base.read(::Type{Data2D}, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, DataPath(elem))
	return Data2D(d_read(grp, "x"), d_read(grp, "y"))
end

#Read/write DataMD:
#-------------------------------------------------------------------------------
function Base.read(::Type{DataMD}, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, DataPath(elem))
	dtype = DATAMDTYPES[a_read(grp, "type")]
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
