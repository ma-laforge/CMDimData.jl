#EasyPlotMPL base types & core functions
#-------------------------------------------------------------------------------

#Find
#GracePlot, 


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

#Internal
function addwfrm(ax, wfrm::EasyPlot.Waveform)
	wfrm = ax[:plot](wfrm.data.x, wfrm.data.y)
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
		addwfrm(ax, wfrm)
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
		row = div(subplotidx, ncols) + 1
		col = mod(subplotidx, ncols) + 1
		ax = fig[:add_subplot](row, col, 1)
		rendersubplot(ax, s)
		subplotidx += 1
	end

	fig[:canvas][:draw]()
	return fig
end


#==EasyPlot-level rendering functions
===============================================================================#

function EasyPlot.render(::Type{EasyPlot.Backend{:MPL}}, plot::EasyPlot.Plot, args...; ncols::Int=1, kwargs...)
	title = plot.title
	fig = plt.figure(title, args...; kwargs...)
	return render(fig, plot, ncols=ncols)
end

function Base.display(fig::PyPlot.Figure)
	fig[:canvas][:draw]()
	return fig
end

#Last line
