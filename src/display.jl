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
	return render(GracePlot.new(d.args...; d.kwargs...), eplot)
end

Base.mimewritable(mime::MIME, eplot::EasyPlot.Plot, d::PlotDisplay) =
	method_exists(writemime, (IO, typeof(mime), GracePlot.Plot))

function Base.writemime(io::IO, mime::MIME, eplot::EasyPlot.Plot, d::PlotDisplay)
	#Try to figure out if possible *before* rendering:
	if !mimewritable(mime, eplot, d)
		throw(MethodError(writemime, (io, mime, eplot)))
	end
	plot = render(d, eplot)
	writemime(io, mime, plot)
end


#==Initialization
===============================================================================#
EasyPlot.registerdefaults(:Grace,
	maindisplay = PlotDisplay(guimode=true),
	renderdisplay = PlotDisplay(guimode=false)
)

#Last line
