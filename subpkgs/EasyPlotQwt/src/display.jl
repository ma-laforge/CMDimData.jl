#EasyPlotQwt Display functionnality
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#

const MIME2QWTFMT_MAP = Dict{String,String}(
	"image/png" => "png",
	"image/bmp" => "bmp",
	"image/tiff" => "tif",
	"image/jpeg" => "jpeg",
	"application/pdf" => "pdf",
)


#==Types
===============================================================================#
#TODO: support guimode=false

mutable struct PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	guimode::Bool
	args::Tuple
	kwargs::Base.Iterators.Pairs
	PlotDisplay(args...; guimode=true, kwargs...) = new(guimode, args, kwargs)
end

#TODO: Generate from MIME2QWTFMT_MAP?
const SupportedMIME = Union{
	MIME"image/png",
	MIME"image/bmp",
	MIME"image/tiff",
	MIME"image/jpeg",
	MIME"application/pdf",
}


#==Helper functions
===============================================================================#
mimestr(::MIME{T}) where T = string(T)


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

#Support _write function natively (use high-quality, by default):
function EasyPlot._write(filepath::String, mime::SupportedMIME, fig::Figure; draft::Bool=false)
	format = MIME2QWTFMT_MAP[mimestr(mime)]
	_save(fig, filepath, format, draft=draft)
end

#_save(fig::Figure, path::String, format::String, draft=false)
function Base.show(io::IO, mime::SupportedMIME, fig::Figure)
	tmpfile = "$(tempname())_export"
	EasyPlot._write(tmpfile, mime, fig, draft=true)
	data = readall(tmpfile)
	write(io, data)
	rm(tmpfile)
end

Base.showable(mime::MIME, eplot::EasyPlot.Plot, d::PlotDisplay) =
	method_exists(show, (IO, typeof(mime), Figure))

#Last line
