#Save/load EasyPlot plots to/from HDF5
#-------------------------------------------------------------------------------

#==Useful constants
===============================================================================#
const hdf5plotroot = "plots"
const hdf5dataroot = "data"


#==Helper functions
===============================================================================#

plotelempath(subpath::String) = "$hdf5plotroot/$subpath"
datapath(subpath::String) = "$hdf5dataroot/$subpath"

#Write AttributeList to their own HDF5 group:
function writeattr(w::EasyDataWriter, alist::AttributeList, elem::String)
	grp = creategrp(w, plotelempath(elem))

	for attrib in fieldnames(typeof(alist))
		v = getfield(alist, attrib)

		#Write out only AttributeList attributes that are not "nothing":
		if v != nothing
			writeattr(grp, string(attrib), v)
		end
	end
end

#Read AttributeList from an HDF5 group (using initialized AttributeList):
function readattr(r::EasyDataReader, alist::AttributeList, elem::String)
	grp = opengrp(r, plotelempath(elem))

	for attrib in names(attrs(grp))
		asymb = Symbol(attrib)
		v = readattr(grp, attrib)
		setfield!(alist, asymb, v)
	end

	return alist
end


#==Main EasyDataHDF5 plot read/write functions
===============================================================================#

#EasyDataHDF5 - read/write Waveform:
#-------------------------------------------------------------------------------
function __write(w::EasyDataWriter, wfrm::Waveform, elem::String)
	grp = creategrp(w, plotelempath(elem))
	a_write(grp, "id", wfrm.id)
#	line::LineAttributes
#	glyph::GlyphAttributes
	write(w, datapath(elem), wfrm.data)
end

function __read(s::Subplot, r::EasyDataReader, elem::String)
	grp = opengrp(r, plotelempath(elem))
	data = read(r, datapath(elem), DataMD)
#	line::LineAttributes
#	glyph::GlyphAttributes
	return add(s, data, id = a_read(grp, "id"))
end

#EasyDataHDF5 - read/write Subplot:
#-------------------------------------------------------------------------------
function __write(w::EasyDataWriter, s::Subplot, elem::String)
	grp = creategrp(w, plotelempath(elem))
	a_write(grp, "title", s.title)
	wfrmidx = 1

	for wfrm in s.wfrmlist
		__write(w, wfrm, "$elem/wfrm$wfrmidx")
		wfrmidx += 1
	end

	writeattr(w, s.axes, "$elem/axes")
	a_write(grp, "wfrmcount", length(s.wfrmlist))

end

function __read(p::Plot, r::EasyDataReader, elem::String)
	grp = opengrp(r, plotelempath(elem))
	wfrmcount = a_read(grp, "wfrmcount")
	subplot = add(p, title = a_read(grp, "title"))

	for wfrmidx in 1:wfrmcount
		__read(subplot, r, "$elem/wfrm$wfrmidx")
	end

	set(subplot, readattr(r, EasyPlot.paxes(), "$elem/axes"))
	return subplot
end

#EasyDataHDF5 - read/write Plot:
#-------------------------------------------------------------------------------
function __write(w::EasyDataWriter, p::Plot, elem::String)
	grp = creategrp(w, plotelempath(elem))
	subplotidx = 1

	for s in p.subplots
		__write(w, s, "$elem/subplot$subplotidx")
		subplotidx += 1
	end

	a_write(grp, "title", p.title)
	a_write(grp, "subplotcount", length(p.subplots))
end

function __read(r::EasyDataReader, ::Type{Plot}, elem::String)
	grp = opengrp(r, plotelempath(elem))
	subplotcount = a_read(grp, "subplotcount")
	result = EasyPlot.new(title = a_read(grp, "title"))

	for subplotidx in 1:subplotcount
		__read(result, r, "$elem/subplot$subplotidx")
	end

	return result
end


#==Exported (user-level) functions:
===============================================================================#

#TODO: Think of a better high-level read/write interface.

#Read/write from EasyDataReader/EasyDataWriter:
#-------------------------------------------------------------------------------
function Base.write(w::EasyDataWriter, plotlist::Vector{Plot})
	grp = creategrp(w, hdf5plotroot)

	for i in 1:length(plotlist)
		__write(w, plotlist[i], "plot$i")
	end

	a_write(grp, "plotcount", length(plotlist))
end
Base.write(w::EasyDataWriter, plot::Plot) = write(w, [plot])

function Base.read(r::EasyDataReader, ::Type{Vector{Plot}})
	result = Plot[]
	grp = opengrp(r, hdf5plotroot)
	plotcount = a_read(grp, "plotcount")

	for i in 1:plotcount
		push!(result, __read(r, Plot, "plot$i"))
	end

	return result
end
Base.read(r::EasyDataReader, ::Type{Plot}; idx::Int=1) =
	__read(r, Plot, "plot$idx")

#Read/write from files directly:
#-------------------------------------------------------------------------------
function Base.write(::Type{EasyDataWriter}, path::String,
	opt::IOOptionsWrite, plotlist::Vector{Plot})
	open(EasyDataWriter, path) do w
		write(w, plotlist)
	end
end
Base.write(::Type{EasyDataWriter}, path::String, opt::IOOptionsWrite, plot::Plot) =
	write(EasyDataWriter, path, opt, [plot])

function Base.read(::Type{EasyDataReader}, path::String, T::Type{Vector{Plot}})
	open(EasyDataReader, path) do r
		read(r, T)
	end
end
function Base.read(::Type{EasyDataReader}, path::String, T::Type{Plot}; idx::Int=1)
	open(EasyDataReader, path) do r
		read(r, T, idx=idx)
	end
end
	

#==Un-"Exported", user-level functions:
===============================================================================#

#Explicit module-level read/write functions:
#-------------------------------------------------------------------------------
_write(path::String, plotlist::Vector{Plot}) =
	write(EasyDataWriter, path, IOOptions(write=true), plotlist)
_write(path::String, plot::Plot) =
	write(EasyDataWriter, path, IOOptions(write=true), plot)

_read(path::String, T::Type{Vector{Plot}}) =
	read(EasyDataReader, path, T)
_read(path::String, T::Type{Plot}; idx::Int = 1) =
	read(EasyDataReader, path, T, idx=idx)

#Last Line
