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

#Module does not yet support other inline formats (must figure out how)
Base.mimewritable(mime::MIME, eplot::EasyPlot.Plot, d::PlotDisplay) = false
#Assume PNG is supported by all backends:
Base.mimewritable(mime::MIME"image/png", eplot::EasyPlot.Plot, d::PlotDisplay) = true

#Maintain text/plain MIME support (Is this ok?... showlimited is not exported).
Base.writemime(io::IO, ::MIME"text/plain", fig::Figure) = Base.showlimited(io, fig)
Base.writemime(io::IO, ::MIME"text/plain", fig::FigureMulti) = Base.showlimited(io, fig)

#Currently no support for non-FigureMulti plots... but could generate a single image...:
Base.writemime(io::IO, mime::MIME, fig::Figure) =
	throw(MethodError(writemime, (io, mime, fig)))
Base.writemime(io::IO, mime::MIME, fig::FigureMulti) =
	writemime(io, mime, fig.subplots)


#==Support saving
===============================================================================#
#Support for saving FigureSng to multiple files:
function EasyPlot._write(filepath::AbstractString, mime::MIME, fig::FigureSng)
	fsplit = splitext(filepath)
	for (i, s) in enumerate(fig.subplots)
		spath = join(fsplit, "_subplot$i")
		open(spath, "w") do io
			Base.writemime(io, mime, s)
		end
	end
end


#==Initialization
===============================================================================#
EasyPlot.registerdefaults(:Plots,
	maindisplay = PlotDisplay(defaults.renderingtool, guimode=true),
	renderdisplay = EasyPlot.NullDisplay() #No support for render-only
)

#Last line
