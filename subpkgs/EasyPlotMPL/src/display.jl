#EasyPlotMPL Display functionnality
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
#HACK: showable works on Figure objects (not types)
#HACK: hardcoding supported mimes (might not be true for different backends)
const SUPPORTED_MIMES = Set(["image/svg+xml", "image/png"])
const SUPPORTED_BACKENDS = Set(["tk", "gtk3", "gtk", "qt", "wx"])


#==Main Types
===============================================================================#
mutable struct PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	guimode::Bool
	backend::Symbol
	args::Tuple
	kwargs::Base.Iterators.Pairs
	PlotDisplay(backend::Symbol, args...; guimode::Bool=true, kwargs...) =
		new(guimode, backend, args, kwargs)
end
PlotDisplay(args...; kwargs...) = PlotDisplay(defaults.backend, args...; kwargs...)

#Keeps key features of Matplotlib/PyPlot state needed for plotting
mutable struct MPLState
	interactive::Bool
	backend::Symbol
	guimode::Bool
end
MPLState(d::PlotDisplay) = MPLState(false, d.backend, d.guimode)


#==Support functions
===============================================================================#
#Do not overwrite Base.display... would circumvent display system.
function EasyPlot._display(fig::PyPlot.Figure)
	fig.show()
	nothing
end

function _getstate()
	return MPLState(
		PyPlot.matplotlib.is_interactive(),
		PyPlot.pygui(),
		!PyPlot.isjulia_display[1], #TODO: Hack!... not part of PyPlot interface.
	)
end

function _applystate(s::MPLState)
	PyPlot.pygui(s.backend)
	PyPlot.pygui(s.guimode)
#@show pygui(), PyPlot.isjulia_display[1]
	#Must be applied last (in case backend does not support interactive):
	PyPlot.matplotlib.interactive(s.interactive)
end


#==Top-level rendering functions
===============================================================================#
function render(d::PlotDisplay, eplot::EasyPlot.Plot)
	local fig
	origstate = _getstate()
	newstate = MPLState(d)
	try
		_applystate(newstate)
		fig = PyPlot.figure(d.args...; d.kwargs...)
		render(fig, eplot)
	finally
		#Do not restore guimode... PyPlot will not display properly
		origstate.guimode = newstate.guimode
		_applystate(origstate)
	end
	return fig
end

Base.showable(mime::MIME{T}, eplot::EasyPlot.Plot, d::PlotDisplay) where T =
	in(string(T), SUPPORTED_MIMES)
#method_exists(writemime, (IO, typeof(mime), PyPlot.Figure) #Apparently not enough

#Last line
