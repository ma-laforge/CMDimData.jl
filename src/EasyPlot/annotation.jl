#EasyPlot: Annotation objects and tools.
#-------------------------------------------------------------------------------
#=TODO
 - Use a better system for .align instead of using symbols? (ex: TOP|LEFT).
=#


#==Useful constants
===============================================================================#


#==Abstract types
===============================================================================#
#All annotation can use _apply() attributes system:
abstract type AbstractPlotAnnotation <: AbstractAttributeReceiver end


#==Main types
===============================================================================#
struct DefaultFontAnnotation <: AbstractFont; end

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


mutable struct TextAnnotation <: AbstractPlotAnnotation
	text::String
	pos::Pos2DOffset
#	font::AbstractFont
	angle::PReal #Degrees
	align::Symbol #tl, tc, tr, cl, cc, cr, bl, bc, br
	strip::Int #0 = all
end
_TextAnnotation(text::String, x, y, angle, align, strip) =
	TextAnnotation(text, Pos2DOffset(Point2D(x,y), Vector2D(0,0), Vector2D(0,0)),
		PReal(angle), Symbol(align), Int(strip) #Enforce type to ensure WILL call main constructor.
	)
TextAnnotation(text::String, args...; x::Real=PNaN, y::Real=PNaN, angle::Real=0.0, align::Symbol=:cc, strip::Int=0, kwargs...) =
	_apply(_TextAnnotation(text, x, y, angle, align, strip), args, kwargs)

mutable struct HVMarker <: AbstractPlotAnnotation
	isvert::Bool #else: horizontal
	pos::PReal
	line::LineAttributes
	strip::Int #0 = all
end
_HVMarker(isvert, pos, strip) =
	HVMarker(isvert, pos, LineAttributes(), strip)
vmarker(pos::Real, args...; strip=0, kwargs...) =
	_apply(_HVMarker(true, pos, strip), args, kwargs)
hmarker(pos::Real, args...; strip=1, kwargs...) =
	_apply(_HVMarker(false, pos, strip), args, kwargs)


#==Register constructors with cons() interface
===============================================================================#
cons(::DS{:vmarker}, args...; kwargs...) = vmarker(args...; kwargs...)
cons(::DS{:hmarker}, args...; kwargs...) = hmarker(args...; kwargs...)
cons(::DS{:atext}, args...; kwargs...) = TextAnnotation(args...; kwargs...)


#==Implement _apply() methods
===============================================================================#
function _apply(a::TextAnnotation, ::DS{:prop}; x=nooverwrite, y=nooverwrite,
		angle=nooverwrite, align=nooverwrite, strip=nooverwrite)
	_x = a.pos.v.x; _y= a.pos.v.y;
		NoOverwrite(x) || (_x = x)
		NoOverwrite(y) || (_y = y)
		a.pos.v = Point2D(_x, _y)
	NoOverwrite(angle) || (a.angle = angle)
	NoOverwrite(align) || (a.align = align)
	NoOverwrite(strip) || (a.strip = strip)
	return a
end
function _apply(a::TextAnnotation, ::DS{:offset}; x=nooverwrite, y=nooverwrite)
	_x = a.pos.offset.x; _y= a.pos.offset.y;
		NoOverwrite(x) || (_x = x)
		NoOverwrite(y) || (_y = y)
		a.pos.offset = Vector2D(_x, _y)
	return a
end
function _apply(a::TextAnnotation, ::DS{:reloffset}; x=nooverwrite, y=nooverwrite)
	_x = a.pos.reloffset.x; _y= a.pos.reloffset.y;
		NoOverwrite(x) || (_x = x)
		NoOverwrite(y) || (_y = y)
		a.pos.reloffset = Vector2D(_x, _y)
	return a
end

function _apply(m::HVMarker, ::DS{:line}; style=nooverwrite, width=nooverwrite, color=nooverwrite)
	_style = m.line.style; _width = m.line.width; _color = m.line.color
		NoOverwrite(style) || (_style = style)
		NoOverwrite(width) || (_width = width)
		NoOverwrite(color) || (_color = _resolve_ColorRef(color))
		m.line = LineAttributes(style=_style, width=_width, color=_color)
	return m
end

#Last line
