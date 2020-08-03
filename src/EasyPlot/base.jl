#EasyPlot base types & core functions
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

#TODO: Rename??
const NullOr{T} = Union{Nothing, T}

#ColorRef that can also reference another
#Int: Pick specific color from theme/ColorScheme
#Nothing: Pick appropriate color from theme/ColorScheme (Varies with sweep value)
const ColorRef = Union{Nothing, Colorant, Int}

#A plot theme.
mutable struct Theme
	colorscheme::NullOr{ColorScheme}

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

abstract type AbstractAxis; end

struct Axis{ID} <: AbstractAxis
	#TODO: Ensure valid id values
end
Axis(id::Symbol) = Axis{id}()

"""
    struct FoldedAxis

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

struct Extents1D
	min::PReal
	max::PReal
end
_Extents1D() = Extents1D(PNaN, PNaN)

struct LineAttributes
	style #::Symbol #will be none if set to nothing while a glyph.shape exists
	width::PReal #[0, 10]
	color::ColorRef
end
LineAttributes(;style=nothing, width=1, color=nothing) = LineAttributes(style, width, color)

struct GlyphAttributes
#==IMPORTANT:
Edge width & color taken from LineAttributes
==#
	shape::Symbol #because "type" is reserved
	size::PReal #of glyph. Edge width taken from LineAttributes
	color::ColorRef #glyph linecolor. = nothing to match line.color
	fillcolor::ColorRef
end
GlyphAttributes(;shape=:none, size=1, color=nothing, fillcolor=nothing) =
	GlyphAttributes(shape, size, color, fillcolor)

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
end
_YStrip() = YStrip(:lin, "", "", _Extents1D())

mutable struct Plot <: AbstractAttributeReceiver
	title::String
	xlabel::String
	xaxis::AbstractAxis
	xext::Extents1D
	ystriplist::Vector{YStrip}
	wfrmlist::Vector{Waveform}
end
_Plot(title::String) = Plot(title, "", Axis(:lin), _Extents1D(), YStrip[], Waveform[])
Plot(args...; title::String="", kwargs...) =
	_apply(_Plot(title), args, kwargs)

mutable struct PlotCollection <: AbstractAttributeReceiver
	title::String
	ncolumns::Int #TODO: Create a more flexible system
	plotlist::Vector{Plot}
	displaylegend::Bool
	theme::Theme
end
_PlotCollection(title::String, ncolumns::Int) = PlotCollection(title, ncolumns, Plot[], true, Theme())
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


#==Helper functions
===============================================================================#
#Create a new Extents1D with conditionally overwritten min/max values.
function _new_overwrite(srcext::Extents1D, _min, _max)
	newmin = srcext.min; newmax = srcext.max
	NoOverwrite(_min) || (newmin = _min)
	NoOverwrite(_max) || (newmax = _max)
	return Extents1D(newmin, newmax)
end


#==Methods to resolve user-supplied values
===============================================================================#
_resolve_xaxis(xscale::Symbol) = Axis(xscale)
_resolve_xaxis(a::FoldedAxis) = a

#_resolve_colorant(c::Symbol) = COLOR_NAMED[c]
#_resolve_colorant(c::Colorant) = c

#Resolve to appropriate ColorRef value:
_resolve_ColorRef(c::Nothing) = c
_resolve_ColorRef(c::Symbol) = COLOR_NAMED[c]
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
end

#Change x-axis parameters of a plot:
function _apply(p::Plot, ::DS{:xaxis}; scale=nooverwrite, min=nooverwrite, max=nooverwrite)
	NoOverwrite(scale) || (p.xaxis = _resolve_xaxis(scale))
	p.xext = _new_overwrite(p.xext, min, max)
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
end

#Change misc. strip properties:
function _apply(p::Plot, ::DS{:ystrip}, istrip::Int;
	min=nooverwrite, max=nooverwrite, scale=nooverwrite,
	axislabel=nooverwrite, striplabel=nooverwrite
)
	nstrips = length(p.ystriplist)
	if istrip < 1 || istrip > nstrips
		throw(ArgumentError("set(`::Plot`, ystrip=...): strip index=$istrip, but strip count=$nstrips"))
	end
	strip = p.ystriplist[istrip]
	strip.ext = _new_overwrite(strip.ext, min, max)
	NoOverwrite(scale) || (strip.scale = scale)
	NoOverwrite(axislabel) || (strip.axislabel = axislabel)
	NoOverwrite(striplabel) || (strip.striplabel = striplabel)
end

function _apply(p::Plot, ::DS{:xfolded}, foldinterval::PReal;
	xstart=0.0, xmin=0.0, xmax=foldinterval
)
	p.xaxis = FoldedAxis(foldinterval, xstart=xstart, xmin=xmin, xmax=xmax)
end


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

#Last line
