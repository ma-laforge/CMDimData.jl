#Save/load EasyPlot plots to/from HDF5
#-------------------------------------------------------------------------------

#==Useful constants
===============================================================================#
const hdf5plotroot = "plots"


#==Helper functions
===============================================================================#

#Create/open HDF5 groups:
creategrp(w::EasyDataWriter, path::PlotElemPath) =
	g_create(w.writer, "$hdf5plotroot/$(string(path))")
opengrp(w::EasyDataWriter, path::PlotElemPath) =
	g_open(w.writer, "$hdf5plotroot/$(string(path))")
opengrp(r::EasyDataReader, path::PlotElemPath) =
	g_open(r.reader, "$hdf5plotroot/$(string(path))")


#Write AttributeList to their own HDF5 group:
function writeattr{T<:AttributeList}(w::EasyDataWriter, alist::T, elem::AbstractString)
	grp = creategrp(w, PlotElemPath(elem))

	for attrib in fieldnames(alist)
		v = eval(:($alist.$attrib))

		#Write out only AttributeList attributes that are not "nothing":
		if v != nothing
			writeattr(grp, string(attrib), v)
		end
	end
end


#==Main EasyDataHDF5 plot read/write functions
===============================================================================#

#EasyDataHDF5 - read/write Waveform:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, wfrm::Waveform, elem::AbstractString)
	grp = creategrp(w, PlotElemPath(elem))
	a_write(grp, "id", wfrm.id)
#	line::LineAttributes
#	glyph::GlyphAttributes
	write(w, wfrm.data, elem)
end

function EasyPlot.add(s::Subplot, r::EasyDataReader, elem::AbstractString)
	grp = opengrp(r, PlotElemPath(elem))
	data = read(DataMD, r, elem)
#	line::LineAttributes
#	glyph::GlyphAttributes
	return add(s, data, id = a_read(grp, "id"))
end

#EasyDataHDF5 - read/write Subplot:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, s::Subplot, elem::AbstractString)
	grp = creategrp(w, PlotElemPath(elem))
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
	grp = opengrp(r, PlotElemPath(elem))
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
	grp = creategrp(w, PlotElemPath(elem))
	subplotidx = 1

	for s in p.subplots
		write(w, s, "$elem/subplot$subplotidx")
		subplotidx += 1
	end

	a_write(grp, "title", p.title)
	a_write(grp, "subplotcount", length(p.subplots))
end

function Base.read(r::EasyDataReader, ::Type{Plot}, elem::AbstractString)
	grp = opengrp(r, PlotElemPath(elem))
	subplotcount = a_read(grp, "subplotcount")
	result = EasyPlot.new(title = a_read(grp, "title"))

	for subplotidx in 1:subplotcount
		add(result, r, "$elem/subplot$subplotidx")
	end

	return result
end


#==Exported (user-level) functions:
===============================================================================#

#Save/load EasyDataHDF5 files:
#-------------------------------------------------------------------------------
function FileIO2.save(plotlist::Vector{Plot}, file::File{EasyDataHDF5})
	open(EasyDataWriter, file) do writer
		grp = creategrp(writer, PlotElemPath(hdf5plotroot))
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
		grp = opengrp(reader, PlotElemPath(hdf5plotroot))
		plotcount = a_read(grp, "plotcount")

		for plotidx in 1:plotcount
			push!(result, read(reader, Plot, "plot$plotidx"))
		end
	end

	return result
end


#Last Line
