#Save/load EasyPlot plots to/from HDF5
#-------------------------------------------------------------------------------

#==Useful constants
===============================================================================#
const hdf5plotroot = "plots"
const hdf5dataroot = "data"


#==Types
===============================================================================#

#Shorthand for writing to HDF5 files:
#-------------------------------------------------------------------------------
type HDF5Path{Symbol}
	subpath::AbstractString
end
typealias ElementPath HDF5Path{:plotelement}
typealias DataPath HDF5Path{:data}
#Also changes string():
Base.print(io::IO, p::HDF5Path) = print(io, p.subpath)


#==Helper functions
===============================================================================#
#Plot element/data path:
elempath(subpath::AbstractString) = ElementPath(subpath)
datapath(subpath::AbstractString) = DataPath(subpath)

#Create/open HDF5 groups:
creategrp(w::EasyDataWriter, path::ElementPath) =
	g_create(w.writer, "$hdf5plotroot/$(string(path))")
opengrp(w::EasyDataWriter, path::ElementPath) =
	g_open(w.writer, "$hdf5plotroot/$(string(path))")
opengrp(r::EasyDataReader, path::ElementPath) =
	g_open(r.reader, "$hdf5plotroot/$(string(path))")
creategrp(w::EasyDataWriter, path::DataPath) =
	g_create(w.writer, "$hdf5dataroot/$(string(path))")
opengrp(w::EasyDataWriter, path::DataPath) =
	g_open(w.writer, "$hdf5dataroot/$(string(path))")
opengrp(r::EasyDataReader, path::DataPath) =
	g_open(r.reader, "$hdf5dataroot/$(string(path))")

#Write out attribute to HDF5 file:
writeattr(grp::HDF5.HDF5Group, k::AbstractString, v::Any) = a_write(grp, k, v)
writeattr(grp::HDF5.HDF5Group, k::AbstractString, v::Symbol) =
	a_write(grp, k, ["CONST", string(v)])

#Write AttributeList to their own HDF5 group:
function writeattr{T<:AttributeList}(w::EasyDataWriter, alist::T, elem::AbstractString)
	grp = creategrp(w, elempath(elem))

	for attrib in fieldnames(alist)
		v = eval(:($alist.$attrib))

		#Write out only AttributeList attributes that are not "nothing":
		if v != nothing
			writeattr(grp, string(attrib), v)
		end
	end
end

#EasyDataHDF5 - read/write Waveform:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, wfrm::Waveform, elem::AbstractString)
	grp = creategrp(w, datapath(elem))

	grp["x"] = wfrm.data.x
	grp["y"] = wfrm.data.y

#	line::LineAttributes
#	glyph::GlyphAttributes

	a_write(grp, "id", wfrm.id)
end

function EasyPlot.add(s::Subplot, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, datapath(elem))
	data = Data2D(d_read(grp, "x"), d_read(grp, "y"))
#	line::LineAttributes
#	glyph::GlyphAttributes
	return add(s, data, id = a_read(grp, "id"))
end

#EasyDataHDF5 - read/write Subplot:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, s::Subplot, elem::AbstractString)
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

function EasyPlot.add(p::Plot, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, elempath(elem))
	wfrmcount = a_read(grp, "wfrmcount")
	result = add(p, title = a_read(grp, "title"))

	for wfrmidx in 1:wfrmcount
		add(result, r, "$elem/wfrm$wfrmidx")
	end

#	writeattr(w, s.axes, "$elem/axes")
	return result
end

#EasyDataHDF5 - read/write Plot:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, p::Plot, elem::AbstractString)
	grp = creategrp(w, elempath(elem))
	subplotidx = 1

	for s in p.subplots
		write(w, s, "$elem/subplot$subplotidx")
		subplotidx += 1
	end

	a_write(grp, "title", p.title)
	a_write(grp, "subplotcount", length(p.subplots))
end

function Base.read(r::EasyDataReader, ::Type{Plot}, elem::AbstractString)
	grp = opengrp(r, elempath(elem))
	subplotcount = a_read(grp, "subplotcount")
	result = EasyPlot.new(title = a_read(grp, "title"))

	for subplotidx in 1:subplotcount
		add(result, r, "$elem/subplot$subplotidx")
	end

	return result
end

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


#==Exported (user-level) functions:
===============================================================================#

#Save/load EasyDataHDF5 files:
#-------------------------------------------------------------------------------
function FileIO2.save(plotlist::Vector{Plot}, file::File{EasyDataHDF5})
	open(EasyDataWriter, file) do writer
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
	save(plotlist, File{EasyDataHDF5}(file))

#Save individual plots:
FileIO2.save(plot::Plot, path::File{EasyDataHDF5}) = save([plot], path)
FileIO2.save(plot::Plot, path::AbstractString) = save([plot], path)

function FileIO2.load(file::File{EasyDataHDF5})
	result = Plot[]
	open(EasyDataReader, file) do reader
		grp = opengrp(reader, elempath(hdf5plotroot))
		plotcount = a_read(grp, "plotcount")

		for plotidx in 1:plotcount
			push!(result, read(reader, Plot, "plot$plotidx"))
		end
	end

	return result
end


#Last Line
