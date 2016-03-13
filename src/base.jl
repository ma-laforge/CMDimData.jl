#EasyPlot base types & core functions
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#

const VALID_AXISSCALES = Set([:lin, :log, :reciprocal])
#TODO: should we support :db20, :db10?

const VALID_LINESTYLES = Set([:none, :solid, :dash, :dot, :dashdot])

#In case specified glyph (symbol/marker) not supported...
#implementations should provide default (hopefully not none).
const VALID_GLYPHS = Set([:none, 
	:square, :diamond,
	:uarrow, :darrow, :larrow, :rarrow, #usually triangles
	:cross, :+, :diagcross, :x,
	:circle, :o, :star, :*,
])

const VALID_SUBPLOTSTYLES = Set([:xy, :strip, :eye, :stripeye])

#==Plot/subplot/waveform attributes
===============================================================================#

typealias NullOr{T} Union{Void, T}

#-------------------------------------------------------------------------------
type LineAttributes <: AttributeList
	style
	width #[0, 10]
	color
end

#"line" constructor:
eval(genexpr_attriblistbuilder(:line, LineAttributes, reqfieldcnt=0))

#-------------------------------------------------------------------------------
type GlyphAttributes <: AttributeList #Don't use "Symbol" - name used by Julia
#==IMPORTANT:
Edge width & color taken from LineAttributes
==#
	shape #because "type" is reserved
	size #of glyph.  edge width taken from LineAttributes
	color #Fill color.  Do not set to leave unfilled.
end

#"glyph" constructor:
eval(genexpr_attriblistbuilder(:glyph, GlyphAttributes, reqfieldcnt=0))

type AxesAttributes <: AttributeList
	xlabel; ylabel
	xmin; xmax; ymin; ymax
	xscale; yscale #VALID_AXISSCALES
end

#"axes" constructor:
eval(genexpr_attriblistbuilder(:axes, AxesAttributes, reqfieldcnt=0))

type EyeAttributes <: AttributeList
	tbit
	teye
	tstart
end

#"eyeparam" constructor:
eval(genexpr_attriblistbuilder(:eyeparam, EyeAttributes, reqfieldcnt=1))

#Plot theme.
#Thought: Renering function can also be passed a theme when plot does not
#specify values.
type Theme
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

#==Main data structures
===============================================================================#
#Provides advanced functionality to rendering modules.
abstract AbstractAxes{T} #One of VALID_SUBPLOTSTYLES (symbol)

#-------------------------------------------------------------------------------
type Waveform
	data::DataMD
	id::AbstractString
	line::LineAttributes
	glyph::GlyphAttributes
end
Waveform(data::DataMD) = Waveform(data, "", line(), glyph())

#-------------------------------------------------------------------------------
#TODO: Find a better way to deal with different subplot types
type Subplot
	title::AbstractString
	style::Symbol
	wfrmlist::Vector{Waveform}
	axes::AxesAttributes
	eye::EyeAttributes #TODO: should not be available in all plot types
end
Subplot() = Subplot("", :xy, Waveform[], axes(xscale=:lin, yscale=:lin), eyeparam(1, tstart=0))


#-------------------------------------------------------------------------------
type Plot
	title::AbstractString
	ncolumns::Int #TODO: Create a more flexible
	subplots::Vector{Subplot}
	displaylegend::Bool
	theme::Theme
end
Plot() = Plot("", 1, Subplot[], true, Theme())


#==Main data constructors
===============================================================================#
function new(args...; kwargs...)
	plot = Plot()
	set(plot, args...; kwargs...)
	return plot
end

function add(p::Plot, args...; kwargs...)
	subplot = Subplot()
	set(subplot, args...; kwargs...)
	push!(p.subplots, subplot)
	return subplot
end

function add(s::Subplot, wfrm::Waveform, args...; kwargs...)
	set(wfrm, args...; kwargs...)
	push!(s.wfrmlist, wfrm)
	return wfrm
end

function add(s::Subplot, data::DataMD, args...; kwargs...)
	return add(s, Waveform(data), args...; kwargs...)
end


#==Generate friendly show functions
===============================================================================#
const SHOW_INDENTSTR = "   "
const SHOW_DEFAULTSTR = "default"

function string_scales(axes::AxesAttributes)
	xscale = nothing==axes.xscale? SHOW_DEFAULTSTR : string(axes.xscale)
	yscale = nothing==axes.yscale? SHOW_DEFAULTSTR : string(axes.yscale)
	return "$xscale/$yscale"
end

function showshorthand(io::IO, wfrm::Waveform)
	typestr = string(typeof(wfrm.data))
	id = wfrm.id
	print(io, "Waveform(\"$id\", $typestr)")
end

function Base.show(io::IO, s::Subplot; indent="")
	title = s.title
	axes = string_scales(s.axes)
	print(io, "$(indent)Subplot(\"$title\", $axes)[\n")
	wfrmindent = indent * SHOW_INDENTSTR
	for wfrm in s.wfrmlist
		print(io, wfrmindent); showshorthand(io, wfrm); println(io)
	end
	print(io, "$(indent)]")
end

function Base.show(io::IO, p::Plot)
	title = p.title
	print(io, "Plot(\"$title\")[\n")
	for s in p.subplots
		show(io, s, indent=SHOW_INDENTSTR); println(io)
	end
	print(io, "]")
end

#Last line
