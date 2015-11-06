#EasySave base types & core functions
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#

#==Main data structures
===============================================================================#

immutable EasyPlotHDF5 <: FileIO2.DataFormat; end
typealias EPH5Fmt EasyPlotHDF5 #More succinct

type EasyPlotReader <: AbstractReader{EasyPlotHDF5}
	reader::HDF5.HDF5File
end

type EasyPlotWriter <: AbstractWriter{EasyPlotHDF5}
	writer::HDF5.HDF5File
end


#Last line
