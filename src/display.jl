#EasyPlotGrace Display functionnality
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
DEFAULT_RENDERDPI = 75 #Low res for inline graphics


#==Defaults
===============================================================================#
type Defaults
	renderdpi::Int #Low res for inline graphics
end

function Defaults()
	const ENVSTR_RENDERDPI = "EASYPLOTGRACE_RENDERDPI"
	renderdpi = get(ENV, ENVSTR_RENDERDPI, "$DEFAULT_RENDERDPI")

	try
		renderdpi = parse(Int, renderdpi)
	catch
		warn("Invalid value for $ENVSTR_RENDERDPI: $renderdpi.  Setting to $(DEFAULT_RENDERDPI).")
		renderdpi = DEFAULT_RENDERDPI
	end

	Defaults(renderdpi)
end

const defaults = Defaults()


#==Types
===============================================================================#
#TODO: support guimode=false

type PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	guimode::Bool
	dpi::Int
	args::Tuple
	kwargs::Vector{Any}
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

Base.mimewritable(mime::MIME, eplot::EasyPlot.Plot, d::PlotDisplay) =
	method_exists(show, (IO, typeof(mime), GracePlot.Plot))


#==Initialization
===============================================================================#
EasyPlot.registerdefaults(:Grace,
	maindisplay = PlotDisplay(guimode=true),
	renderdisplay = PlotDisplay(guimode=false, dpi=defaults.renderdpi)
)

#Last line
