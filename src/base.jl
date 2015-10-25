#EasyPlotGrace base types & core functions
#-------------------------------------------------------------------------------


#==Base types
===============================================================================#


#==Rendering functions
===============================================================================#

#Internal
function _add(g::GracePlot.GraphRef, wfrm::EasyPlot.Waveform)
	ds = add(g, wfrm.data.x, wfrm.data.y)
#TODO: support wfrm properties:
#	id::String
#	line::LineAttributes
#	glyph::GlyphAttributes
	return ds
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

function render(gplot::GracePlot.Plot, eplot::EasyPlot.Plot; ncols::Int=1)
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
		#TODO: Add floating text instead of title/subtitle hack???
		info("EasyPlotGrace: Plot.title not supported for more than 1 subplot")
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
