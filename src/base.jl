#EasyPlotGrace base types & core functions
#-------------------------------------------------------------------------------


#==Base types
===============================================================================#

#==Helper/mapping functions
===============================================================================#

#Does not yet support symbolic color values:
#TODO: remap colors
validcolor(color) = isa(color, Integer) ? color : nothing

#Linewidth:
maplinewidth(w) = w
maplinewidth(w::Real) = w

#Glyph size:
mapglyphsize(w) = w
mapglyphsize(sz::Real) = sz/2

#==Rendering functions
===============================================================================#

function _add{T<:DataMD}(g::GracePlot.GraphRef, d::T, args...; kwargs...)
	throw("$T datasets not supported.")
end

function _add(g::GracePlot.GraphRef, d::Data2D, args...; kwargs...)
	add(g, d.x, d.y, args...; kwargs...)
end

function _add(g::GracePlot.GraphRef, d::DataHR{Data2D}, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="")
	sweepnames = names(sweeps(d))
	for coords in subscripts(d)
		dfltline = line(color=coords[end]) #will be used unless _line overwites it...
		values = parameter(d, coords)
		di = d.subsets[coords...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		add(g, di.x, di.y, dfltline, _line, _glyph, id="$id; $crnid")
	end
end

#Convert DataHR{Number} to DataHR{Data2D}:
function _add{T<:Number}(g::GracePlot.GraphRef, d::DataHR{T}, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="")
	return _add(g, DataHR{Data2D}(d), _line, _glyph; id=id)
end

function _add(g::GracePlot.GraphRef, wfrm::EasyPlot.Waveform)
	_line = line(style=wfrm.line.style,
	         width=maplinewidth(wfrm.line.width),
	         color=validcolor(wfrm.line.color),
	)

	_glyph = glyph(shape=wfrm.glyph.shape,
	          size=mapglyphsize(wfrm.glyph.size),
	          linewidth=maplinewidth(wfrm.line.width),
	          color=validcolor(wfrm.glyph.color),
	)
	return _add(g, wfrm.data, _line, _glyph, id=wfrm.id)
end

function _render(g::GracePlot.GraphRef, subplot::EasyPlot.Subplot)
	set(g, subtitle = subplot.title)

	for wfrm in subplot.wfrmlist
		_add(g, wfrm)
	end

	autofit(g)
	srca = subplot.axes
	set(g, GracePlot.axes(
		xscale = srca.xscale, yscale = srca.yscale,
		xmin = srca.xmin, xmax = srca.xmax,
		ymin = srca.ymin, ymax = srca.ymax,
	))

	#Apply x/y labels
	if srca.xlabel != nothing
		set(g, xlabel=srca.xlabel)
	end
	if srca.ylabel != nothing
		set(g, ylabel=srca.ylabel)
	end

	return g
end

function EasyPlot.render(gplot::GracePlot.Plot, eplot::EasyPlot.Plot; ncols::Int=1)
	nrows = div(length(eplot.subplots)-1, ncols)+1

	#Arrange basically allocates all subplots (GracePlot.Plot):
	arrange(gplot, (nrows, ncols))
	graphidx = 0

	for s in eplot.subplots
		g = graph(gplot, graphidx)
		_render(g, s)
		graphidx += 1
	end

	if length(eplot.subplots) > 1
		w = get(gplot, :wview); h = get(gplot, :hview)
		vgap = 0.15 #Pick a reasonable value (cannot querry state)
		title = GracePlot.text(eplot.title, loctype=:view, size=1.5, loc=(w/2,h-vgap/2.5), just=:centercenter)
		GracePlot.addannotation(gplot, title)
#		info("EasyPlotGrace: Plot.title not supported for more than 1 subplot")
	else
		set(graph(gplot, 0), title = eplot.title)
	end

	redraw(gplot)
	return gplot
end


#==EasyPlot-level rendering functions
===============================================================================#

function EasyPlot.render(::Type{EasyPlot.Backend{:Grace}}, plot::EasyPlot.Plot, args...; ncols::Int=1, kwargs...)
	return render(GracePlot.new(args...; kwargs...), plot, ncols=ncols)
end

function Base.display(plot::GracePlot.Plot)
	redraw(plot)
	return plot
end

#Last line
