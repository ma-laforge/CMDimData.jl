#EasyPlotInspect base types & core functions
#-------------------------------------------------------------------------------
#(Also implements AbstractWfrmBuilder)


#==Constants
===============================================================================#

const scalemap = Dict{Symbol, Symbol}(
	:lin => :lin,
	:log => :log10,
	:log10 => :log10,
	:dB10 => :dB10,
	:dB20 => :dB20,
)

const linestylemap = Dict{Symbol, Symbol}(
	:none    => :none,
	:solid   => :solid,
	:dash    => :dash,
	:dot     => :dot,
	:dashdot => :dashdot,
)

const glyphmap = Dict{Symbol, Symbol}(
	:none      => :none,
	:square    => :square,
	:diamond   => :diamond,
	:uarrow    => :uarrow, :darrow => :darrow,
	:larrow    => :larrow, :rarrow => :rarrow,
	:cross     => :cross, :+ => :+,
	:diagcross => :diagcross, :x => :x,
	:circle    => :circle, :o => :o,
	:star      => :star, :* => :*,
)


#==Base types
===============================================================================#
mutable struct WfrmBuilder <: EasyPlot.AbstractWfrmBuilder
	ref::InspectDR.Plot2D #Plot reference
	theme::EasyPlot.Theme
	fold::Optional{EasyPlot.FoldedAxis}
end

mutable struct WfrmAttributes
	label
	linecolor
	linewidth #[0, 10]
	linestyle
	glyphshape
	glyphsize
	glyphcolor
	glyphfillcolor #Fill color.
end
WfrmAttributes(;label=nothing,
	linecolor=nothing, linewidth=nothing, linestyle=nothing,
	glyphshape=nothing, glyphsize=nothing,
	glyphcolor=nothing, glyphfillcolor=nothing) =
	WfrmAttributes(label, linecolor, linewidth, linestyle,
		glyphshape, glyphsize, glyphcolor, glyphfillcolor
)


#==Helper functions
===============================================================================#
mapcolor(v::Colorant) = v
mapglyphcolor(v) = mapcolor(v) #In case we want to diverge

#Linewidth:
maplinewidth(w) = w
maplinewidth(::Nothing) = maplinewidth(1) #default

#Glyph size:
mapglyphsize(sz) = 6*sz
mapglyphsize(::Nothing) = mapglyphsize(1) #default

function maplinestyle(v::Symbol)
	result = get(linestylemap, v, missing)
	if ismissing(result)
		@info("Line style not supported: :$v")
		result = maplinestyle(nothing)
	end
	return result
end
maplinestyle(::Nothing) = "-" #default

function mapglyphshape(v::Symbol)
	result = get(glyphmap, v, missing)
	if ismissing(result)
		@info("Glyph shape not supported: :$v")
		result = :o #Use some supported glyph shape
	end
	return result
end
mapglyphshape(::Nothing) = :none #default (no glyph)

function WfrmAttributes(id::String, attr::EasyPlot.WfrmAttributes)
	return WfrmAttributes(label=id,
		linecolor=mapcolor(attr.linecolor),
		linewidth=maplinewidth(attr.linewidth),
		linestyle=maplinestyle(attr.linestyle),
		glyphshape=mapglyphshape(attr.glyphshape),
		glyphsize=mapglyphsize(attr.glyphsize),
		glyphcolor=mapglyphcolor(attr.glyphlinecolor),
		glyphfillcolor=mapglyphcolor(attr.glyphfillcolor),
	)
end

function mapmarkerline(t::EasyPlot.Theme, la::EasyPlot.LineAttributes)
	la = EasyPlot.resolve_markerline(t, la)
	return line(
		color=mapcolor(la.color),
		width=maplinewidth(la.width),
		style=maplinestyle(la.style)
	)
end

function mapgrid(g::EasyPlot.AbstractGrid)
	@warn("Grid not supported: $g")
	return InspectDR.GridRect()
end
function mapgrid(g::EasyPlot.GridCartesian)
	return InspectDR.GridRect(
		vmajor=g.vmajor, vminor=g.vminor, hmajor=g.hmajor, hminor=g.hminor
	)
end


#==Annotation
===============================================================================#

addannot(::EasyPlot.Theme, ::InspectDR.Plot2D, args...) = nothing

function addannot(t::EasyPlot.Theme, iplot::InspectDR.Plot2D, m::EasyPlot.HVMarker)
	la = mapmarkerline(t, m.line)
 
	if m.isvert
		_m = vmarker(m.pos, la, strip=m.strip)
	else
		_m = hmarker(m.pos, la, strip=m.strip)
	end
	add(iplot, _m)
	return nothing
end

function addannot(t::EasyPlot.Theme, iplot::InspectDR.Plot2D, a::EasyPlot.TextAnnotation)
	#TODO: support custom fonts/colors.
	afont = iplot.layout[:font_annotation] #Grab default annotation font
	_a = atext(a.text, x=a.pos.v.x, y=a.pos.v.y,
		xoffset=a.pos.offset.x, yoffset=a.pos.offset.y,
		xoffset_rel=a.pos.reloffset.x, yoffset_rel=a.pos.reloffset.y,
		font=afont, angle=a.angle, align=a.align, strip=a.strip
	)
	add(iplot, _a)
	return nothing
end


#==AbstractWfrmBuilder implementation
===============================================================================#
EasyPlot.needsfold(b::WfrmBuilder) = b.fold

#Add DataF1 results:
function _addwfrm(plot::InspectDR.Plot2D, d::DataF1, a::WfrmAttributes, strip::Int)
	wfrm = add(plot, d.x, d.y, id=a.label, strip=strip)
	wfrm.line = line(color=a.linecolor, width=a.linewidth, style=a.linestyle)
	wfrm.glyph = glyph(shape=a.glyphshape, size=a.glyphsize,
		color=a.glyphcolor, fillcolor=a.glyphfillcolor
	)
end

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(b::WfrmBuilder, d::DataF1, id::String,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes, strip::Int)
	attr = EasyPlot.WfrmAttributes(b.theme, la, ga) #Apply theme to attributes
	inspectattr = WfrmAttributes(id, attr) #Attributes understood by InspectDR
	_addwfrm(b.ref, d, inspectattr, strip)
end

#Last line
