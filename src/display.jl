#EasyPlotGrace Display functionnality
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
#TODO: support guimode=false

type PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	guimode::Bool
	args::Tuple
	kwargs::Vector{Any}
	PlotDisplay(args...; guimode=true, kwargs...) = new(guimode, args, kwargs)
end


#==Top-level rendering functions
===============================================================================#
#Do not overwrite Base.display... would circumvent display system.
function EasyPlot._display(plot::GracePlot.Plot)
	redraw(plot)
	nothing
end

function EasyPlot.render(d::PlotDisplay, eplot::EasyPlot.Plot)
	return render(GracePlot.new(d.args...; guimode=d.guimode, d.kwargs...), eplot)
end

Base.mimewritable(mime::MIME, eplot::EasyPlot.Plot, d::PlotDisplay) =
	method_exists(writemime, (IO, typeof(mime), GracePlot.Plot))


#==Initialization
===============================================================================#
EasyPlot.registerdefaults(:Grace,
	maindisplay = PlotDisplay(guimode=true),
	renderdisplay = PlotDisplay(guimode=false)
)

#Last line
