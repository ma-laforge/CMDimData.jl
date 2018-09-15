#EasyPlotGrace Display functionnality
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
#TODO: support guimode=false

mutable struct PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	guimode::Bool
	dpi::Int
	args::Tuple
	kwargs::Base.Iterators.Pairs
	PlotDisplay(args...; guimode=true, dpi=GracePlot.DEFAULT_DPI, kwargs...) =
		new(guimode, dpi, args, kwargs)
end


#==Top-level rendering functions
===============================================================================#
#Do not overwrite Base.display... would circumvent display system.
function EasyPlot._display(plot::GracePlot.Plot)
	redraw(plot)
	nothing
end

function EasyPlot.render(d::PlotDisplay, eplot::EasyPlot.Plot)
	plot = GracePlot.new(d.args...; guimode=d.guimode, dpi=d.dpi, d.kwargs...)
	return render(plot, eplot)
end

Base.showable(mime::MIME, eplot::EasyPlot.Plot, d::PlotDisplay) =
	method_exists(show, (IO, typeof(mime), GracePlot.Plot))


#Last line
