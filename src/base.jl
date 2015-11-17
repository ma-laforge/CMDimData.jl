#EasyPlotMPL base types & core functions
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#

const scalemap = Dict{Symbol, AbstractString}([
	(:lin, "linear"),
	(:log, "log"),
])

#==Base types
===============================================================================#


#==Rendering functions
===============================================================================#

function _add{T<:DataMD}(ax, d::T, args...; kwargs...)
	throw("$T datasets not supported.")
end

#Add DataF1 results:
function _add(ax, d::DataF1; id::AbstractString="")
	wfrm = ax[:plot](d.x, d.y)
end

#Add collection of DataHR{DataF1} results:
function _add(ax, d::DataHR{DataF1}; id::AbstractString="")
	sweepnames = names(sweeps(d))
	for coords in subscripts(d)
#		dfltline = line(color=coords[end]) #will be used unless _line overwites it...
		values = parameter(d, coords)
		di = d.subsets[coords...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		wfrm = ax[:plot](di.x, di.y)
	end
end

#Convert DataHR{Number} to DataHR{DataF1}:
function _add{T<:Number}(ax, d::DataHR{T}; id::AbstractString="")
	return _add(ax, DataHR{DataF1}(d); id=id)
end

#Add DataEye data to an eye diagram:
function _add(ax, d::EasyPlot.DataEye; id::AbstractString="")
	if length(d.data) < 1; return; end
	_add(ax, d.data[1], id=id) #Id first element
	for i in 1:length(d.data)
		_add(ax, d.data[i]) #no id
	end
end

#Add collection of DataEye{DataEye} data to an eye diagram:
function _add(ax, d::DataHR{EasyPlot.DataEye}; id::AbstractString="")
	sweepnames = names(sweeps(d))
	for coords in subscripts(d)
#		dfltline = line(color=coords[end]) #will be used unless _line overwites it...
		values = parameter(d, coords)
		di = d.subsets[coords...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		_add(ax, di, id="$id; $crnid")
	end
end

#Add waveform to an x/y plot:
function _add(ax, wfrm::EasyPlot.Waveform)
	wfrm =_add(ax, wfrm.data, id=wfrm.id)
#TODO: support wfrm properties:
#	id::AbstractString
#	line::LineAttributes
#	glyph::GlyphAttributes
	#wfrm = ax[:plot](x, y, color="red", linewidth=2.0, linestyle="--")
	return wfrm
end

#Add a waveform to an eye diagram:
function _add(ax, wfrm::EasyPlot.Waveform, param::EasyPlot.EyeAttributes)
	eye = EasyPlot.BuildEye(wfrm.data, param.tbit, param.teye, tstart=param.tstart)
	return _add(ax, eye, id=wfrm.id)
end

function rendersubplot(ax, subplot::EasyPlot.Subplot)
	ax[:set_title](subplot.title)

	if :eye == subplot.style
		ep = subplot.eye
		if nothing == ep.teye; ep.teye = ep.tbit; end
		for wfrm in subplot.wfrmlist
			_add(ax, wfrm, ep)
		end
	else
		for wfrm in subplot.wfrmlist
			_add(ax, wfrm)
		end
	end

	srca = subplot.axes

	#Update axis limits:
	(xmin, xmax) = ax[:set_xlim]()
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	(ymin, ymax) = ax[:set_ylim]()
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	ax[:set_xlim](xmin, xmax)
	ax[:set_ylim](ymin, ymax)

	#Apply x/y scales:
	ax[:set_xscale](scalemap[srca.xscale])
	ax[:set_yscale](scalemap[srca.yscale])
	
	#Apply x/y labels:
	if srca.xlabel != nothing; ax[:set_xlabel](srca.xlabel); end
	if srca.ylabel != nothing; ax[:set_ylabel](srca.ylabel); end

	return ax
end

function render(fig::PyPlot.Figure, eplot::EasyPlot.Plot; ncols::Int=1)
	nrows = div(length(eplot.subplots)-1, ncols)+1
	subplotidx = 0

	for s in eplot.subplots
#		row = div(subplotidx, ncols) + 1
#		col = mod(subplotidx, ncols) + 1
		ax = fig[:add_subplot](nrows, ncols, subplotidx+1)
		rendersubplot(ax, s)
		subplotidx += 1
	end

	fig[:canvas][:draw]()
	return fig
end


#==EasyPlot-level rendering functions
===============================================================================#

function EasyPlot.render(::Type{EasyPlot.Backend{:MPL}}, plot::EasyPlot.Plot, args...; ncols::Int=1, kwargs...)
	fig = plt.figure(args...; kwargs...)
	fig[:suptitle](plot.title)
	return render(fig, plot, ncols=ncols)
end

function Base.display(fig::PyPlot.Figure)
	fig[:canvas][:draw]()
	return fig
end

#Last line
