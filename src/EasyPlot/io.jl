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
   _write(:png, "img.png", nativeplot, set(w=480, h=300))
   _write(:png, "img.png", ::AbstractBuilder, ::PlotCollection, set(w=480, h=300))
   _write(:png, "img.png", ::PlotCollection, set(w=480, h=300)) #Use default builder
   _write(:png, "img.png", :InspectDR, ::PlotCollection, set(w=480, h=300))
=#

_write(mime::Symbol, filepath::String, nativeplot, a::AttributeChangeData=set()) =
	_write(filepath, _getmime(mime), ShowOptions(a), nativeplot)
_write(mime::Symbol, filepath::String, b::AbstractBuilder, pc::PlotCollection, a::AttributeChangeData=set()) =
	_write(filepath, _getmime(mime), ShowOptions(a), b, pc)
#_write(mime::Symbol, filepath::String, pc::PlotCollection, a::AttributeChangeData=set()) =
#	_write(filepath, _getmime(mime), ShowOptions(a), AbstractBuilder(builderid), pc)
function _write(mime::Symbol, filepath::String, builderid::Symbol, pc::PlotCollection, a::AttributeChangeData=set())
	b = getbuilder(:image, builderid)
	_write(filepath, _getmime(mime), ShowOptions(a), b, pc)
end


#Last line
