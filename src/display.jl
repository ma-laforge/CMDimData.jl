#EasyPlotInspect Display functionnality
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
#Default width/height for rendering inline plots (preferably low res):
const DEFAULT_RENDERW = 300.0
const DEFAULT_RENDERH = DEFAULT_RENDERW / φ #φ: golden ratio


#==Defaults
===============================================================================#
mutable struct Defaults
	#Default width/height for rendering inline plots:
	wrender::Float64
	hrender::Float64
end

function Defaults()
	const ENVSTR_RENDERW = "EASYPLOTINSPECT_RENDERW"
	const ENVSTR_RENDERH = "EASYPLOTINSPECT_RENDERH"
	wrender = get(ENV, ENVSTR_RENDERW, "$DEFAULT_RENDERW")
	hrender = get(ENV, ENVSTR_RENDERH, "$DEFAULT_RENDERH")

	try
		wrender = parse(Float64, wrender)
	catch
		warn("Invalid value for $ENVSTR_RENDERW: $wrender.  Setting to $DEFAULT_RENDERW.")
		wrender = DEFAULT_RENDERW
	end

	try
		hrender = parse(Float64, hrender)
	catch
		warn("Invalid value for $ENVSTR_RENDERH: $hrender.  Setting to $DEFAULT_RENDERH.")
		hrender = DEFAULT_RENDERH
	end

	Defaults(wrender, hrender)
end

const defaults = Defaults()


#==Types
===============================================================================#
mutable struct PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	#w/h of data area:
	wdata::Float64
	hdata::Float64
	args::Tuple
	kwargs::Vector{Any}
	PlotDisplay(args...;
		wdata=InspectDR.DEFAULT_DATA_WIDTH, hdata=InspectDR.DEFAULT_DATA_HEIGHT, kwargs...) =
		new(wdata, hdata, args, kwargs)
end


#==Top-level rendering functions
===============================================================================#
#Do not overwrite Base.display... would circumvent display system.
function EasyPlot._display(mplot::InspectDR.Multiplot)
	gplot = display(InspectDR.GtkDisplay(), mplot)
	nothing
end

function EasyPlot.render(d::PlotDisplay, eplot::EasyPlot.Plot)
	mplot = InspectDR.Multiplot() #d.kwargs...
	layout = InspectDR.Layout()
	layout.wdata = d.wdata
	layout.hdata = d.hdata
	render(mplot, eplot, layout)
	return mplot
end

Base.mimewritable(mime::MIME, eplot::EasyPlot.Plot, d::PlotDisplay) =
	method_exists(show, (IO, typeof(mime), InspectDR.Multiplot))


#==Initialization
===============================================================================#
EasyPlot.registerdefaults(:EasyPlotInspect,
	maindisplay = PlotDisplay(),
	renderdisplay = PlotDisplay(wrender=defaults.wrender, hrender=defaults.hrender)
)

#Last line
