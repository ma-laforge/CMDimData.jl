#EasyPlotQwt Display functionnality
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
function EasyPlot._display(fig::Figure)
	fig[:show]()

#=IMPORTANT:
	#PyCall.pygui_start(:qt_pyqt4) seems to handle QT events in background thread.
	#For blocking show(), the following can be used instead:
	app = GUICore.qapplication()
	app[:exec_]() #Process app events (modal)
=#
	nothing
end

function EasyPlot.render(d::PlotDisplay, eplot::EasyPlot.Plot)
	fig = Figure()
	return render(fig, eplot)
end

Base.mimewritable(mime::MIME, eplot::EasyPlot.Plot, d::PlotDisplay) =
	method_exists(writemime, (IO, typeof(mime), Figure))

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
EasyPlot.registerdefaults(:Qwt,
	maindisplay = PlotDisplay(guimode=true),
	renderdisplay = EasyPlot.NullDisplay() #No support at the moment.
)

#Last line
