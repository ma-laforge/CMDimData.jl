#Save/load EasyPlot plots to/from HDF5
#-------------------------------------------------------------------------------

#==Useful constants
===============================================================================#
const hdf5plotroot = "plots"
const hdf5dataroot = "data"

#==Types
===============================================================================#
immutable EasyPlotHDF5 <: FileIO2.DataFormat; end
typealias EPH5Fmt EasyPlotHDF5 #More succinct

type EasyPlotReader <: AbstractReader{EasyPlotHDF5}
	reader::HDF5.HDF5File
end

type EasyPlotWriter <: AbstractWriter{EasyPlotHDF5}
	writer::HDF5.HDF5File
end

#Shorthand for writing to HDF5 files
#-------------------------------------------------------------------------------
type HDF5Path{Symbol}
	subpath::AbstractString
end
#TODO: Figure out why this string() does not work with "$interpolation":
Base.string(p::EasyPlot.HDF5Path) = p.subpath
typealias ElementPath HDF5Path{:plotelement}
typealias DataPath HDF5Path{:data}

#==Helper functions
===============================================================================#
#Plot element/data path:
elempath(subpath::AbstractString) = ElementPath(subpath)
datapath(subpath::AbstractString) = DataPath(subpath)

#Create/open HDF5 groups:
creategrp(w::EasyPlotWriter, path::ElementPath) =
	g_create(w.writer, "$hdf5plotroot/$(string(path))")
opengrp(w::EasyPlotWriter, path::ElementPath) =
	g_open(w.writer, "$hdf5plotroot/$(string(path))")
opengrp(r::EasyPlotReader, path::ElementPath) =
	g_open(r.reader, "$hdf5plotroot/$(string(path))")
creategrp(w::EasyPlotWriter, path::DataPath) =
	g_create(w.writer, "$hdf5dataroot/$(string(path))")
opengrp(w::EasyPlotWriter, path::DataPath) =
	g_open(w.writer, "$hdf5dataroot/$(string(path))")
opengrp(r::EasyPlotReader, path::DataPath) =
	g_open(r.reader, "$hdf5dataroot/$(string(path))")

#Write out attribute to HDF5 file:
writeattr(grp::HDF5.HDF5Group, k::AbstractString, v::Any) = a_write(grp, k, v)
writeattr(grp::HDF5.HDF5Group, k::AbstractString, v::Symbol) =
	a_write(grp, k, ["CONST", string(v)])

#Write AttributeList to their own HDF5 group:
function writeattr{T<:AttributeList}(w::EasyPlotWriter, alist::T, elem::AbstractString)
	grp = creategrp(w, elempath(elem))

	for attrib in fieldnames(alist)
		v = eval(:($alist.$attrib))

		#Write out only AttributeList attributes that are not "nothing":
		if v != nothing
			writeattr(grp, string(attrib), v)
		end
	end
end

#EasyPlotHDF5 - read/write Waveform:
#-------------------------------------------------------------------------------
function Base.write(w::EasyPlotWriter, wfrm::Waveform, elem::AbstractString)
	grp = creategrp(w, datapath(elem))

	grp["x"] = wfrm.data.x
	grp["y"] = wfrm.data.y

#	line::LineAttributes
#	glyph::GlyphAttributes

	a_write(grp, "id", wfrm.id)
end

function add(s::Subplot, r::EasyPlotReader, elem::AbstractString)
	grp = opengrp(r, datapath(elem))
	data = Data2D(d_read(grp, "x"), d_read(grp, "y"))
#	line::LineAttributes
#	glyph::GlyphAttributes
	return add(s, data, id = a_read(grp, "id"))
end

#EasyPlotHDF5 - read/write Subplot:
#-------------------------------------------------------------------------------
function Base.write(w::EasyPlotWriter, s::Subplot, elem::AbstractString)
	grp = creategrp(w, elempath(elem))
	a_write(grp, "title", s.title)
	wfrmidx = 1

	for wfrm in s.wfrmlist
		write(w, wfrm, "$elem/wfrm$wfrmidx")
		wfrmidx += 1
	end

	writeattr(w, s.axes, "$elem/axes")
	a_write(grp, "wfrmcount", length(s.wfrmlist))

end

function add(p::Plot, r::EasyPlotReader, elem::AbstractString)
	grp = opengrp(r, elempath(elem))
	wfrmcount = a_read(grp, "wfrmcount")
	result = add(p, title = a_read(grp, "title"))

	for wfrmidx in 1:wfrmcount
		add(result, r, "$elem/wfrm$wfrmidx")
	end

#	writeattr(w, s.axes, "$elem/axes")
	return result
end

#EasyPlotHDF5 - read/write Plot:
#-------------------------------------------------------------------------------
function Base.write(w::EasyPlotWriter, p::Plot, elem::AbstractString)
	grp = creategrp(w, elempath(elem))
	subplotidx = 1

	for s in p.subplots
		write(w, s, "$elem/subplot$subplotidx")
		subplotidx += 1
	end

	a_write(grp, "title", p.title)
	a_write(grp, "subplotcount", length(p.subplots))
end

function Base.read(r::EasyPlotReader, ::Type{Plot}, elem::AbstractString)
	grp = opengrp(r, elempath(elem))
	subplotcount = a_read(grp, "subplotcount")
	result = EasyPlot.new(title = a_read(grp, "title"))

	for subplotidx in 1:subplotcount
		add(result, r, "$elem/subplot$subplotidx")
	end

	return result
end

#Open/close EasyPlotHDF5 files:
#-------------------------------------------------------------------------------
function Base.open(::Type{EasyPlotWriter}, file::File{EasyPlotHDF5})
	writer = h5open(file.path, "w")
	return EasyPlotWriter(writer)
end
Base.close(w::EasyPlotWriter) = close(w.writer)

function Base.open(::Type{EasyPlotReader}, file::File{EasyPlotHDF5})
	reader = h5open(file.path, "r")
	return EasyPlotReader(reader)
end
Base.close(r::EasyPlotReader) = close(r.reader)


#==Exported (user-level) functions:
===============================================================================#

#Save/load EasyPlotHDF5 files:
#-------------------------------------------------------------------------------
function FileIO2.save(plotlist::Vector{Plot}, file::File{EasyPlotHDF5})
	open(EasyPlotWriter, file) do writer
		grp = creategrp(writer, elempath(hdf5plotroot))
		plotidx = 1

		for plot in plotlist
			write(writer, plot, "plot$plotidx")
			plotidx += 1
		end

		a_write(grp, "plotcount", length(plotlist))
	end
end
FileIO2.save(plotlist::Vector{Plot}, file::AbstractString) =
	save(plotlist, File{EasyPlotHDF5}(file))

#Save individual plots:
FileIO2.save(plot::Plot, path::File{EasyPlotHDF5}) = save([plot], path)
FileIO2.save(plot::Plot, path::AbstractString) = save([plot], path)

function FileIO2.load(file::File{EasyPlotHDF5})
	result = Plot[]
	open(EasyPlotReader, file) do reader
		grp = opengrp(reader, elempath(hdf5plotroot))
		plotcount = a_read(grp, "plotcount")

		for plotidx in 1:plotcount
			push!(result, read(reader, Plot, "plot$plotidx"))
		end
	end

	return result
end


#Last Line
