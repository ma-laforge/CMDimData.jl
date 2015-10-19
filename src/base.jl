#EasyPlot base types & core functions
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#

#colors: black, red, orange, yellow, green, blue, indigo, violet, rgb(x,y,z)
#TODO: create preset colors as a map of RGB values

const valid_axisscales = Set({:lin, :log, :reciprocal})
#TODO: should we support :db20, :db10?

const valid_linestyles = Set({:solid, :dash, :dot, :dashdot})

#In case specified symbol not supported...
#implementations should provide default (hopefully not none).
const valid_symbols = Set({:none, 
	:square, :diamond,
	:uarrow, :darrow, :larrow, :rarrow, #usually triangles
	:cross, :+, :diagcross, :x,
	:circle, :o, :star, :*,
})


#==Plot/subplot/waveform attributes
===============================================================================#

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
	shape #because "type" is reserved
	size
	color
end

#"glyph" constructor:
eval(genexpr_attriblistbuilder(:glyph, GlyphAttributes, reqfieldcnt=0))

type AxesAttributes <: AttributeList
	xlabel; ylabel
	xmin; xmax; ymin; ymax
	xscale; yscale #valid_axisscales
end

#"axes" constructor:
eval(genexpr_attriblistbuilder(:axes, AxesAttributes, reqfieldcnt=0))


#==Main data structures
===============================================================================#

#-------------------------------------------------------------------------------
type Waveform
	data::Data2D
	id::String
	line::LineAttributes
	glyph::GlyphAttributes
end
Waveform(data::Data2D) = Waveform(data, "", line(), glyph())

#-------------------------------------------------------------------------------
type Subplot
	title::String
	wfrmlist::Vector{Waveform}
	axes::AxesAttributes
end
Subplot() = Subplot("", Waveform[], axes(xscale=:lin, yscale=:lin))


#-------------------------------------------------------------------------------
type Plot
	title::String
	subplots::Vector{Subplot}
end
Plot() = Plot("", Subplot[])


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

function add(s::Subplot, data::Data2D, args...; kwargs...)
	return add(s, Waveform(data), args...; kwargs...)
end


#==Rendering interface (to be implemented externally):
===============================================================================#

#For user to specify which backend to use for rendering:
type Backend{Symbol}; end

#Catch-all:
function render{T<:Backend}(::Type{T}, plot::Plot, args...; kwargs...)
	throw("\"render\" not supported for $(string(T))")
end

function Base.display{T<:Backend}(::Type{T}, plot::Plot, args...; kwargs...)
	result = render(T, plot, args...; kwargs...)
	return display(result)
end

#Just in case...
function render(plot::Plot, args...; kwargs...)
	throw("Must specify backend: render(Backend{:<BKND>}, ...)")
end
function Base.display(plot::Plot, args...; kwargs...)
	throw("Must specify backend: display(Backend{:<BKND>}, ...)")
end


#==Generate friendly show functions
===============================================================================#
const show_intentstr = "   "
const dfltstr = "default"

function string_scales(axes::AxesAttributes)
	xscale = nothing==axes.xscale? dfltstr : string(axes.xscale)
	yscale = nothing==axes.yscale? dfltstr : string(axes.yscale)
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
	wfrmindent = indent * show_intentstr
	for wfrm in s.wfrmlist
		print(io, wfrmindent); showshorthand(io, wfrm); println(io)
	end
	print(io, "$(indent)]")
end

function Base.show(io::IO, p::Plot)
	title = p.title
	print(io, "Plot(\"$title\")[\n")
	for s in p.subplots
		show(io, s, indent=show_intentstr); println(io)
	end
	print(io, "]")
end

#Last line
