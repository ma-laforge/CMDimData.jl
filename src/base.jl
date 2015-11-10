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

function _add(ax, d::Data2D; id::AbstractString="")
	wfrm = ax[:plot](d.x, d.y)
end

function _add(ax, d::DataHR{Data2D}; id::AbstractString="")
	sweepnames = names(sweeps(d))
	for coords in subscripts(d)
#		dfltline = line(color=coords[end]) #will be used unless _line overwites it...
		values = parameter(d, coords)
		di = d.subsets[coords...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		wfrm = ax[:plot](di.x, di.y)
	end
end

#Convert DataHR{Number} to DataHR{Data2D}:
function _add{T<:Number}(ax, d::DataHR{T}; id::AbstractString="")
	return _add(ax, DataHR{Data2D}(d); id=id)
end

#Internal
function _add(ax, wfrm::EasyPlot.Waveform)
	wfrm =_add(ax, wfrm.data, id=wfrm.id)
#TODO: support wfrm properties:
#	id::AbstractString
#	line::LineAttributes
#	glyph::GlyphAttributes
	#wfrm = ax[:plot](x, y, color="red", linewidth=2.0, linestyle="--")
	return wfrm
end

function rendersubplot(ax, subplot::EasyPlot.Subplot)
	ax[:set_title](subplot.title)

	for wfrm in subplot.wfrmlist
		_add(ax, wfrm)
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
