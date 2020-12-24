#EasyPlot I/O facilities
#-------------------------------------------------------------------------------


#==getmime(): map extension symbol => MIME
===============================================================================#
_getmimetype(::DS{EXT}) where EXT =
	error("Not a recognized extension: $EXT.")
_getmimetype(::DS{:png}) = MIME"image/png"
_getmimetype(::DS{:svg}) = MIME"image/svg+xml"
_getmimetype(::DS{:eps}) = MIME"image/eps"
_getmimetype(::DS{:ps})  = MIME"application/postscript"
_getmimetype(::DS{:pdf}) = MIME"application/pdf"
_getmimetype(ext::Symbol) = _getmimetype(DS(ext))
_getmime(ext::Symbol) = _getmimetype(ext::Symbol)()


#==Dimension calculators
===============================================================================#
function griddims(pc::PlotCollection)
	nplots = length(pc.plotlist)
	ncols = pc.ncolumns
	nrows = div(nplots-1, ncols) + 1
	return (nrows, ncols)
end

#Computes suggested canvas size for a PlotCollection object (row/col-dependant)
function _CanvasDim(pc::PlotCollection, dim::PlotDim)
	nrows, ncols = griddims(pc)
	return CanvasDim(dim.w*ncols, dim.h*nrows)
end
_CanvasDim(pc::PlotCollection, dim::CanvasDim) = dim #Already canvas dimensions
CanvasDim(pc::PlotCollection, opt::ShowOptions) = _CanvasDim(pc, opt.dim)


#==Implement show/showable interface for Plot/PlotCollection
===============================================================================#
#Basic text/plain output:
Base.showable(mime::MIME"text/plain", pc::PlotCollection) = true
Base.show(io::IO, ::MIME"text/plain", pc::PlotCollection) = Base.show(io, pc)
Base.showable(mime::MIME"text/plain", plot::Plot) = true
Base.show(io::IO, ::MIME"text/plain", plot::Plot) = Base.show(io, plot)

_showable(mime::MIME, ::Nothing) = false
Base.showable(mime::MIME, pc::PlotCollection) = _showable(mime, EasyPlot.defaults.mimebuilder)
Base.showable(mime::MIME"image/svg+xml", pc::PlotCollection) =
	EasyPlot.defaults.rendersvg && _showable(mime, EasyPlot.defaults.mimebuilder)
Base.showable(mime::MIME, plot::Plot) = _showable(mime, PlotCollection())

function Base.show(io::IO, mime::MIME, pc::PlotCollection)
	b = EasyPlot.defaults.mimebuilder
	#Try to figure out if possible *before* rendering:
	if !_showable(mime, b)
		throw(MethodError(show, (io, mime, pc)))
	end
	nativeplot = build(b, pc)
	_show(io, mime, EasyPlot.defaults.mimeshowopt, nativeplot)
end
function Base.show(io::IO, mime::MIME, plot::Plot)
	pcoll = push!(PlotCollection(ncolumns = 1), plot)
	show(io, mime, pcoll)
end


#==_write/show interface (internal)
===============================================================================#
function _write(filepath::String, mime::MIME, opt::ShowOptions, nativeplot::T) where T
	open(filepath, "w") do io
		_show(io, mime, opt, nativeplot)
	end
end

function _write(filepath::String, mime::MIME, opt::ShowOptions, b::AbstractBuilder, pc::PlotCollection)
	nativeplot = build(b, pc)
	_write(filepath, mime, opt, nativeplot)
end


#==_write interface (user-facing)
===============================================================================#
#=Examples
   _write(:png, "img.png", nativeplot, dim=set(w=480, h=300)) #dim: size of canvas
   _write(:png, "img.png", nativeplot, plotdim=set(w=480, h=300)) #plotdim: size for each subplot
   _write(:png, "img.png", ::AbstractBuilder, ::PlotCollection, dim=set(w=480, h=300))
   _write(:png, "img.png", ::PlotCollection, dim=set(w=480, h=300)) #Use default builder
   _write(:png, "img.png", :InspectDR, ::PlotCollection, dim=set(w=480, h=300))
=#

_write(mime::Symbol, filepath::String, opt::ShowOptions, nativeplot) =
	_write(filepath, _getmime(mime), opt, nativeplot)
_write(mime::Symbol, filepath::String, opt::ShowOptions, b::AbstractBuilder, pc::PlotCollection) =
	_write(filepath, _getmime(mime), opt, b, pc)
#_write(mime::Symbol, filepath::String, opt::ShowOptions, pc::PlotCollection) =
#	_write(filepath, _getmime(mime), opt, AbstractBuilder(builderid), pc)
function _write(mime::Symbol, filepath::String, opt::ShowOptions, builderid::Symbol, pc::PlotCollection)
	b = getbuilder(:image, builderid)
	_write(filepath, _getmime(mime), opt, b, pc)
end

_write(mime::Symbol, filepath::String, nativeplot; opt_kwargs...) =
	_write(mime, filepath, ShowOptions(; opt_kwargs...), nativeplot)
_write(mime::Symbol, filepath::String, b::AbstractBuilder, pc::PlotCollection; opt_kwargs...) =
	_write(mime, filepath, ShowOptions(; opt_kwargs...), b, pc)
_write(mime::Symbol, filepath::String, builderid::Symbol, pc::PlotCollection; opt_kwargs...) =
	_write(mime, filepath, ShowOptions(; opt_kwargs...), builderid, pc)

#Last line
