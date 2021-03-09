#Read/write EasyPlot plots to/from HDF5
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#


#==Axis read/write functions
===============================================================================#
#(Axis is a bit strange to write out)

function _write_typed(grp::HDF5.Group, name::String, v::Axis{T}) where T
	grp[name] = String(T)
	_write_datatype_attr(grp[name], Axis)
end

function __read(::Type{Axis}, ds::HDF5.Dataset)
	scale = Symbol(HDF5.read(ds))
	return Axis(scale)
end


#==Plot read/write functions
===============================================================================#

function _writeplot(grp::HDF5.Group, plot::Plot)
	_write_typed(grp, "title", plot.title)
	_write_typed(grp, "xlabel", plot.xlabel)
	_write_typed(grp, "legend", plot.legend)
	_write_typed(grp, "xaxis", plot.xaxis)
	_write_typed(grp, "xext", plot.xext)

	grpslist = creategrp(grp, "ystriplist")
	_write_length_attr(grpslist, plot.ystriplist)
	for (i, strip) in enumerate(plot.ystriplist)
		_write_typed(grpslist, "strip$i", strip)
	end

	grpwlist = creategrp(grp, "wfrmlist")
	_write_length_attr(grpwlist, plot.wfrmlist)
	for (i, wfrm) in enumerate(plot.wfrmlist)
		_write_typed(grpwlist, "wfrm$i", wfrm)
	end
	return
end

function _readplot(grp::HDF5.Group)
	plot = Plot(title=_read_typed(grp, "title"))
	plot.ystriplist = []
	plot.xlabel = _read_typed(grp, "xlabel")
	plot.legend = _read_typed(grp, "legend")
	plot.xaxis = _read_typed(grp, "xaxis")
	plot.xext = _read_typed(grp, "xext")

	grpslist = opengrp(grp, "ystriplist")
	_len = _read_length_attr(Vector, grpslist)
	for i in 1:_len
		strip = _read_typed(grpslist, "strip$i")
		push!(plot.ystriplist, strip)
	end

	grpwlist = opengrp(grp, "wfrmlist")
	_len = _read_length_attr(Vector, grpwlist)
	for i in 1:_len
		wfrm = _read_typed(grpwlist, "wfrm$i")
		push!(plot, wfrm)
	end

	return plot
end


#==PlotCollection read/write functions
===============================================================================#
function _writepcoll(grp::HDF5.Group, pcoll::PlotCollection)
	_write_typed(grp, "title", pcoll.title)
	_write_typed(grp, "ncolumns", pcoll.ncolumns)

	grpplist = creategrp(grp, "plotlist")
	_write_length_attr(grpplist, pcoll.plotlist)
	for (i, plot) in enumerate(pcoll.plotlist)
		grpplot = creategrp(grpplist, "plot$i")
		_writeplot(grpplot, plot)
	end
	return
end

function _readpcoll(grp::HDF5.Group)
	pcoll = PlotCollection(title=_read_typed(grp, "title"))
	pcoll.ncolumns = _read_typed(grp, "ncolumns")

	grpplist = opengrp(grp, "plotlist")
	_len = _read_length_attr(Vector, grpplist)
	for i in 1:_len
		grpplot = opengrp(grpplist, "plot$i")
		plot = _readplot(grpplot)
		push!(pcoll, plot)
	end

	return pcoll
end


#==User-level interface:
===============================================================================#

function Base.write(w::EasyDataWriter, pcoll::PlotCollection, name::String)
	grp = creategrp(w, "$hdf5plotcollroot/$name")
	return _writepcoll(grp, pcoll)
end
function readplot(r::EasyDataReader, name::String) #Avoids specifying ::Type{PlotCollection}
	grp = opengrp(r, "$hdf5plotcollroot/$name")
	return _readpcoll(grp)
end
Base.read(::Type{PlotCollection}, r::EasyDataReader, name::String) = readplot(r, name)

#Interface to read/write by filepath:
#-------------------------------------------------------------------------------
function writeplot(filepath::String, pcoll::PlotCollection; name::String="_unnamed")
	openwriter(filepath) do w
		write(w, pcoll, name)
	end
end

function readplot(filepath::String; name::String="_unnamed")
	openreader(filepath) do r
		readplot(r, name)
	end
end

#Last Line
