#EasyPlotMPL Display functionnality
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
#HACK: mimewritable works on Figure objects (not types)
#HACK: hardcoding supported mimes (might not be true for different backends)
const _supportedmimes = Set(["image/svg+xml", "image/png"])
const backends = Set(["tk", "gtk3", "gtk", "qt", "wx"])


#==Defaults
===============================================================================#
type Defaults
	backend::Symbol
end

#Constructors
#-------------------------------------------------------------------------------
function Defaults()
	dflt = "tk"
	envstr = "EASYPLOTMPL_DEFAULTBACKEND"
	val = get(ENV, envstr, dflt)
	bk = lowercase(val)

	if !in(bk, backends)
		optstr = join(backends, ", ")
		warn("$envstr valid settings are: $optstr")
		bk = dflt
	end

	Defaults(bk)
end

#Data
#-------------------------------------------------------------------------------
const defaults = Defaults()


#==Main Types
===============================================================================#
type PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	guimode::Bool
	backend::Symbol
	args::Tuple
	kwargs::Vector{Any}
	PlotDisplay(backend::Symbol, args...; guimode::Bool=true, kwargs...) =
		new(guimode, backend, args, kwargs)
end
PlotDisplay(args...; kwargs...) = PlotDisplay(defaults.backend, args...; kwargs...)

#Keeps key features of Matplotlib/PyPlot state needed for plotting
type MPLState
	interactive::Bool
	backend::Symbol
	guimode::Bool
end
MPLState(d::PlotDisplay) = MPLState(false, d.backend, d.guimode)


#==Support functions
===============================================================================#
#Do not overwrite Base.display... would circumvent display system.
function EasyPlot._display(fig::PyPlot.Figure)
	fig[:show]()
	nothing
end

function _getstate()
	return MPLState(
		PyPlot.matplotlib[:is_interactive](),
		PyPlot.pygui(),
		!PyPlot.isjulia_display[1], #TODO: Hack!... not part of PyPlot interface.
	)
end

function _applystate(s::MPLState)
	PyPlot.pygui(s.backend)
	PyPlot.pygui(s.guimode)
#@show pygui(), PyPlot.isjulia_display[1]
	#Must be applied last (in case backend does not support interactive):
	PyPlot.matplotlib[:interactive](s.interactive)
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

Base.mimewritable{T}(mime::MIME{T}, eplot::EasyPlot.Plot, d::PlotDisplay) =
	in(string(T), _supportedmimes)
#method_exists(writemime, (IO, typeof(mime), PyPlot.Figure) #Apparently not enough

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
EasyPlot.registerdefaults(:MPL,
	maindisplay = PlotDisplay(guimode=true),
	renderdisplay = PlotDisplay(guimode=false)
)

#Last line
