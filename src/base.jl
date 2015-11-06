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


#Last line
