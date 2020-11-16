#EasyPlotPlots Display functionnality
#-------------------------------------------------------------------------------


#==Main Types
===============================================================================#
mutable struct PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	toolid::Symbol
	guimode::Bool
	args::Tuple
	kwargs::Base.Iterators.Pairs
	PlotDisplay(toolid::Symbol, args...; guimode::Bool=true, kwargs...) =
		new(toolid, guimode, args, kwargs)
end
PlotDisplay(args...; kwargs...) =
	PlotDisplay(defaults.renderingtool, args...; kwargs...)



#==Top-level rendering functions
===============================================================================#
EasyPlot._display(fig::FigureMulti) = display(fig.p)
function EasyPlot._display(fig::FigureSng)
	for s in fig.subplots
		display(s) #Defined in Plots.jl
	end
	nothing
end

function EasyPlot.render(d::PlotDisplay, ecoll::EasyPlot.PlotCollection)
	local fig
	try
		bknd = Plots.backend(d.toolid) #Activate backend
		fig = Figure(d.toolid)
		build(fig, ecoll)
	finally
		#TODO: Restore state
	end
	return fig
end

#Module does not yet support other inline formats (must figure out how)
Base.showable(mime::MIME, ecoll::EasyPlot.PlotCollection, d::PlotDisplay) = false
#Assume PNG is supported by all backends:
Base.showable(mime::MIME"image/png", ecoll::EasyPlot.PlotCollection, d::PlotDisplay) = true

#Maintain text/plain MIME support.
Base.show(io::IO, ::MIME"text/plain", fig::Figure) = Base.show(io, fig)
Base.show(io::IO, ::MIME"text/plain", fig::FigureMulti) = Base.show(io, fig)

#Currently no support for non-FigureMulti plots... but could generate a single image...:
Base.show(io::IO, mime::MIME, fig::Figure) =
	throw(MethodError(show, (io, mime, fig)))
Base.show(io::IO, mime::MIME, fig::FigureMulti) =
	show(io, mime, fig.p)


#==Support saving
===============================================================================#
#Support for saving FigureSng to multiple files:
function EasyPlot._write(filepath::String, mime::MIME, fig::FigureSng)
	fsplit = splitext(filepath)
	for (i, s) in enumerate(fig.subplots)
		spath = join(fsplit, "_subplot$i")
		open(spath, "w") do io
			Base.show(io, mime, s)
		end
	end
end

#Last line
