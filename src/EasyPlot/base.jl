#EasyPlot base type, constant & function definitions
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#

#=Not used! Informative at the moment.

#const VALID_AXISSCALES = Set([:lin, :log, :dB10, :dB20, :reciprocal])
#const VALID_LINESTYLES = Set([:none, :solid, :dash, :dot, :dashdot])

#In case specified glyph (symbol/marker) not supported...
#implementations should provide default (hopefully not none).
const VALID_GLYPHS = Set([:none, 
	:square, :diamond,
	:uarrow, :darrow, :larrow, :rarrow, #usually triangles
	:cross, :+, :diagcross, :x,
	:circle, :o, :star, :*,
])
=#


#==Main types
===============================================================================#
#A plot theme.
mutable struct Theme
	colorscheme::Optional{ColorScheme}

#=Under consideration
	axisline::LineAttributes
	vgridline::LineAttributes
	hgridline::LineAttributes
	dfltline::LineAttributes
	dfltglyph::LineAttributes
	dfltglyphfill
	widthscheme #ex: [1, 3, 5, 7, 9]
=#
end
Theme() = Theme(nothing)

#w & h for plot dimensions (pixels):
abstract type AbstractPlotDimensions; end
struct PlotAutosize <: AbstractPlotDimensions; end
const plotautosize = PlotAutosize()
struct PlotDim <: AbstractPlotDimensions
	w::Int; h::Int
end

abstract type AbstractAxis; end

struct Axis{ID} <: AbstractAxis
	#TODO: Ensure valid id values
end
Axis(id::Symbol) = Axis{id}()

"""`struct FoldedAxis`

Describe how a folded axis is to be displayed.
"""
struct FoldedAxis <: AbstractAxis
	foldinterval::PReal #Interval with which to start overlaying data
	xstart::PReal #Discard data before this point
	xmin::PReal
	xmax::PReal
end
FoldedAxis(foldinterval; xstart=0, xmin=0, xmax=foldinterval) =
	FoldedAxis(foldinterval, xstart, xmin, xmax)

mutable struct Waveform <: AbstractAttributeReceiver
	data::DataMD
	label::String
	line::LineAttributes
	glyph::GlyphAttributes
	strip::Int
end
_Waveform(data::DataMD, label::String, strip::Int) =
	Waveform(data, label, LineAttributes(), GlyphAttributes(), strip)
Waveform(data::DataMD, args...; label::String="", strip=1, kwargs...) =
	_apply(_Waveform(data, label, strip), args, kwargs)

mutable struct YStrip
	scale::Symbol
	striplabel::String
	axislabel::String
	ext::Extents1D
	grid::AbstractGrid
end
_YStrip() = YStrip(:lin, "", "", _Extents1D(), GridCartesian())

mutable struct Plot <: AbstractAttributeReceiver
	title::String
	xlabel::String
	legend::Bool
	xaxis::AbstractAxis
	xext::Extents1D
	ystriplist::Vector{YStrip}
	wfrmlist::Vector{Waveform}
	annot::Vector{AbstractPlotAnnotation}
end
_Plot(title::String, legend::Bool) =
	Plot(title, "", legend, Axis(:lin), _Extents1D(), YStrip[_YStrip()], Waveform[], AbstractPlotAnnotation[])
Plot(args...; title::String="", legend=true, kwargs...) =
	_apply(_Plot(title, legend), args, kwargs)

mutable struct PlotCollection <: AbstractAttributeReceiver
	title::String
	ncolumns::Int #TODO: Create a more flexible system
	plotlist::Vector{Plot}
	bblist::NullOr{Vector{BoundingBox}} #User can specify where to draw plots
	theme::Theme
	opt::Any #Optional data/instructions to relay to builder
end
_PlotCollection(title::String, ncolumns::Int) =
	PlotCollection(title, ncolumns, Plot[], nothing, Theme(), nothing)
PlotCollection(args...; title::String="", ncolumns::Int=1, kwargs...) =
	_apply(_PlotCollection(title, ncolumns), args, kwargs)


#==Register constructors with cons() interface
===============================================================================#
cons(::DS{:plot_collection}, args...; kwargs...) = PlotCollection(args...; kwargs...)
cons(::DS{:plotcoll}, args...; kwargs...) = PlotCollection(args...; kwargs...)
cons(::DS{:plot}, args...; kwargs...) = Plot(args...; kwargs...)
cons(::DS{:wfrm}, args...; kwargs...) = Waveform(args...; kwargs...)
cons(::DS{:fldaxis}, args...; kwargs...) = FoldedAxis(args...; kwargs...)


#==Accessors
===============================================================================#
Base.Symbol(a::Axis{T}) where T = Symbol(T)
Base.Symbol(a::FoldedAxis) = :lin
isauto(d::AbstractPlotDimensions) = false
isauto(d::PlotAutosize) = true


#==Copy constructors
===============================================================================#
Base.copy(src::Waveform) =
	Waveform(src.data, src.label, deepcopy(src.line), deepcopy(src.glyph), src.strip)


#==Helper functions
===============================================================================#
#Create a new Extents1D with conditionally overwritten min/max values.
function _new_overwrite(srcext::Extents1D, _min, _max)
	newmin = srcext.min; newmax = srcext.max
	NoOverwrite(_min) || (newmin = _min)
	NoOverwrite(_max) || (newmax = _max)
	return Extents1D(newmin, newmax)
end

function _get_strip(p::Plot, istrip::Int)
	nstrips = length(p.ystriplist)
	if istrip < 1 || istrip > nstrips
		throw(ArgumentError("set(`::Plot`, ystrip=...): strip index=$istrip, but strip count=$nstrips"))
	end
	return p.ystriplist[istrip]
end

_setgrid(::DS, p::Plot, istrip::Int; kwargs...) =
	throw(ArgumentError("set(`::Plot`, grid=set(fmt=...), ...): fmt must be one of: {:cartesian}"))

function _setgrid(::DS{:cartesian}, p::Plot, istrip::Int; kwargs...)
	strip = _get_strip(p, istrip)
	strip.grid = GridCartesian(; kwargs...)
	return p
end


#==Methods to resolve user-supplied values
===============================================================================#
_resolve_xaxis(xscale::Symbol) = Axis(xscale)
_resolve_xaxis(a::FoldedAxis) = a

#_resolve_colorant(c::Symbol) = getcolor(c)
#_resolve_colorant(c::Colorant) = c

#Resolve to appropriate ColorRef value:
_resolve_ColorRef(c::Nothing) = c
_resolve_ColorRef(c::Symbol) = getcolor(c)
_resolve_ColorRef(c::Int) = c
_resolve_ColorRef(c::Colorant) = c


#==Implement _apply() methods
===============================================================================#
function _apply(w::Waveform, ::DS{:line}; style=nooverwrite, width=nooverwrite, color=nooverwrite)
	_style = w.line.style; _width = w.line.width; _color = w.line.color
	NoOverwrite(style) || (_style = style)
	NoOverwrite(width) || (_width = width)
	NoOverwrite(color) || (_color = _resolve_ColorRef(color))
	w.line = LineAttributes(style=_style, width=_width, color=_color)
	return w
end

function _apply(w::Waveform, ::DS{:glyph}; shape=nooverwrite, size=nooverwrite,
	color=nooverwrite, fillcolor=nooverwrite)
	g=w.glyph; _shape=g.shape; _size=g.size; _color=g.color; _fillcolor=g.fillcolor
	NoOverwrite(shape) || (_shape = shape)
	NoOverwrite(size) || (_size = size)
	NoOverwrite(color) || (_color = _resolve_ColorRef(color))
	NoOverwrite(fillcolor) || (_fillcolor = _resolve_ColorRef(fillcolor))
	w.glyph = GlyphAttributes(shape=_shape, size=_size, color=_color, fillcolor=_fillcolor)
	return w
end

#Configure Plot with x/y axes (single y-strip) and change scales:
function _apply(p::Plot, ::DS{:xyaxes}; xscale=nooverwrite, yscale=nooverwrite,
	xmin=nooverwrite, xmax=nooverwrite, ymin=nooverwrite, ymax=nooverwrite)
	if length(p.ystriplist) > 0
		resize!(p.ystriplist, 1)
	else
		push!(p.ystriplist, _YStrip())
	end
	strip = p.ystriplist[1]
	NoOverwrite(xscale) || (p.xaxis = _resolve_xaxis(xscale))
	NoOverwrite(yscale) || (strip.scale = yscale)
	p.xext = _new_overwrite(p.xext, xmin, xmax)
	strip.ext = _new_overwrite(strip.ext, ymin, ymax)
	return p
end

#Change plot labels:
function _apply(p::Plot, ::DS{:labels}; title=nooverwrite,
	xaxis=nooverwrite, yaxis=nooverwrite)
	if !NoOverwrite(yaxis) && length(p.ystriplist) < 1
		push!(p.ystriplist, _YStrip())
	end
	NoOverwrite(title) || (p.title = title)
	NoOverwrite(xaxis) || (p.xlabel = xaxis)
	NoOverwrite(yaxis) || (p.ystriplist[1].axislabel = yaxis)
	return p
end

#Change x-axis parameters of a plot:
function _apply(p::Plot, ::DS{:xaxis}; scale=nooverwrite,
	min=nooverwrite, max=nooverwrite, label=nooverwrite)
	NoOverwrite(scale) || (p.xaxis = _resolve_xaxis(scale))
	NoOverwrite(label) || (p.xlabel = label)
	p.xext = _new_overwrite(p.xext, min, max)
	return p
end

#Change number of y-strips in a plot:
function _apply(p::Plot, ::DS{:nstrips}, nstrips::Int)
	if length(p.ystriplist) > nstrips
		resize!(p.ystriplist, 1)
	else
		newstrips = nstrips - length(p.ystriplist)
		for i in 1:newstrips
			push!(p.ystriplist, _YStrip())
		end
	end
	return p
end

#Change misc. strip properties:
function _apply(p::Plot, ::DS{:ystrip}, istrip::Int;
	min=nooverwrite, max=nooverwrite, scale=nooverwrite,
	axislabel=nooverwrite, striplabel=nooverwrite
)
	strip = _get_strip(p, istrip)
	strip.ext = _new_overwrite(strip.ext, min, max)
	NoOverwrite(scale) || (strip.scale = scale)
	NoOverwrite(axislabel) || (strip.axislabel = axislabel)
	NoOverwrite(striplabel) || (strip.striplabel = striplabel)
	return p
end
#Strip aliases to avoid parameter name collisions (can only set ystrip=set(...) once):
_apply(p::Plot, ::DS{:ystrip1}; kwargs...) = _apply(p, DS(:ystrip), 1; kwargs...)
_apply(p::Plot, ::DS{:ystrip2}; kwargs...) = _apply(p, DS(:ystrip), 2; kwargs...)
_apply(p::Plot, ::DS{:ystrip3}; kwargs...) = _apply(p, DS(:ystrip), 3; kwargs...)
_apply(p::Plot, ::DS{:ystrip4}; kwargs...) = _apply(p, DS(:ystrip), 4; kwargs...)
_apply(p::Plot, ::DS{:ystrip5}; kwargs...) = _apply(p, DS(:ystrip), 5; kwargs...)
_apply(p::Plot, ::DS{:ystrip6}; kwargs...) = _apply(p, DS(:ystrip), 6; kwargs...)
_apply(p::Plot, ::DS{:ystrip7}; kwargs...) = _apply(p, DS(:ystrip), 7; kwargs...)
_apply(p::Plot, ::DS{:ystrip8}; kwargs...) = _apply(p, DS(:ystrip), 8; kwargs...)
_apply(p::Plot, ::DS{:ystrip9}; kwargs...) = _apply(p, DS(:ystrip), 9; kwargs...)

function _apply(p::Plot, ::DS{:xfolded}, foldinterval::PReal;
	xstart=0.0, xmin=0.0, xmax=foldinterval
)
	p.xaxis = FoldedAxis(foldinterval, xstart=xstart, xmin=xmin, xmax=xmax)
	return p
end

function _apply(g::GridCartesian; vmajor=nooverwrite, vminor=nooverwrite,
	hmajor=nooverwrite, hminor=nooverwrite
)
	NoOverwrite(vmajor) || (g.vmajor = vmajor)
	NoOverwrite(vminor) || (g.vminor = vminor)
	NoOverwrite(hmajor) || (g.hmajor = hmajor)
	NoOverwrite(hminor) || (g.hminor = hminor)
	return g
end

function _apply(p::Plot, ::DS{:grid}, istrip::Int=1; fmt=nooverwrite, kwargs...)
	if NoOverwrite(fmt)
		strip = _get_strip(p, istrip)
		_apply(strip.grid; kwargs...)
	elseif typeof(fmt) != Symbol
		_setgrid(DS(:throwerror), p, istrip)
	else
		_setgrid(DS(:cartesian), p, istrip; kwargs...)
	end
	return p
end

#Grid aliases to avoid parameter name collisions (can only set ystrip=set(...) once):
_apply(p::Plot, ::DS{:grid1}; kwargs...) = _apply(p, DS(:grid), 1; kwargs...)
_apply(p::Plot, ::DS{:grid2}; kwargs...) = _apply(p, DS(:grid), 2; kwargs...)
_apply(p::Plot, ::DS{:grid3}; kwargs...) = _apply(p, DS(:grid), 3; kwargs...)
_apply(p::Plot, ::DS{:grid4}; kwargs...) = _apply(p, DS(:grid), 4; kwargs...)
_apply(p::Plot, ::DS{:grid5}; kwargs...) = _apply(p, DS(:grid), 5; kwargs...)
_apply(p::Plot, ::DS{:grid6}; kwargs...) = _apply(p, DS(:grid), 6; kwargs...)
_apply(p::Plot, ::DS{:grid7}; kwargs...) = _apply(p, DS(:grid), 7; kwargs...)
_apply(p::Plot, ::DS{:grid8}; kwargs...) = _apply(p, DS(:grid), 8; kwargs...)
_apply(p::Plot, ::DS{:grid9}; kwargs...) = _apply(p, DS(:grid), 9; kwargs...)



#==push! interface
===============================================================================#
function Base.push!(c::PlotCollection, p::Plot, args...)
	push!(c.plotlist, p)
	if length(args)>0; push!(c, args...); end
	return c
end
function Base.push!(p::Plot, w::Waveform, args...)
	push!(p.wfrmlist, w)
	if length(args)>0; push!(p, args...); end
	return p
end
function Base.push!(p::Plot, a::AbstractPlotAnnotation, args...)
	push!(p.annot, a)
	if length(args)>0; push!(p, args...); end
	return p
end

#Last line
