#EasyPlotPlots Display functionnality
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#


#==Defaults
===============================================================================#
type Defaults
	renderingtool::Symbol
end

#Constructors
#-------------------------------------------------------------------------------
function Defaults()
	dflt = "pyplot"
	envstr = "EASYPLOTPLOTS_RENDERINGTOOL"
	val = get(ENV, envstr, dflt)
	renderingtool = lowercase(val)

	Defaults(symbol(renderingtool))
end

#Data
#-------------------------------------------------------------------------------
const defaults = Defaults()


#==Main Types
===============================================================================#
type PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	toolid::Symbol
	guimode::Bool
	args::Tuple
	kwargs::Vector{Any}
	PlotDisplay(toolid::Symbol, args...; guimode::Bool=true, kwargs...) =
		new(toolid, guimode, args, kwargs)
end
PlotDisplay(args...; kwargs...) =
	PlotDisplay(defaults.renderingtool, args...; kwargs...)


#==Top-level rendering functions
===============================================================================#
EasyPlot._display(fig::FigureMulti) = display(fig.subplots)
function EasyPlot._display(fig::FigureSng)
	for s in fig.subplots
		display(s) #Defined in Plots.jl
	end
	nothing
end

function EasyPlot.render(d::PlotDisplay, eplot::EasyPlot.Plot)
	local fig
	try
		bknd = Plots.backend(d.toolid) #Activate backend
		fig = Figure(d.toolid)
		render(fig, eplot)
	finally
		#TODO: Restore state
	end
	return fig
end

#Module does not yet support 
Base.mimewritable{T}(mime::MIME{T}, eplot::EasyPlot.Plot, d::PlotDisplay) = false


#==Initialization
===============================================================================#
EasyPlot.registerdefaults(:Plots,
	maindisplay = PlotDisplay(defaults.renderingtool, guimode=true),
	renderdisplay = EasyPlot.NullDisplay() #No support for render-only
)

#Last line
