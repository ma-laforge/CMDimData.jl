#EasyPlot Tools to assist with themes
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
#Different from the one in base.jl (used only in WfrmAttributes)
const ColorRef_WFA = Union{Symbol, Int, Colorant}

#Low-level waveform attributes (compared to LineAttributes & GlyphAttributes)
#NOTE: line & glyph values are "untangled" here.
mutable struct WfrmAttributes
	linestyle::Symbol
	linewidth::Float64 #[0, 10]
	linecolor::ColorRef_WFA

	glyphshape::Symbol
	glyphsize::Float64 #[0, 10]
	glyphlinecolor::ColorRef_WFA
	#glyphlinewidth::Float64 #Use linewidth
	glyphfillcolor::ColorRef_WFA
end


#==Selecting colors
===============================================================================#
getcolor(::Nothing, v) = getcolor(COLORSCHEME_DEFAULT, v) #If no theme selected
#getcolor(t::Theme, v) = getcolor(t.colorscheme, v)


#==Computing final waveform attributes
===============================================================================#
#=TODO
Probably more efficient to run through this algorithm *before* calling
EasyPlot.addwfrm.  So the _addwfrm algorithms should use WfrmAttributes

Problem?:
Cannot mirror glyph.color from line.color when glyph.color==nothing
because we assign line.color AFTER we split up a mulit-dim waveform into multiple
waveforms.
=#

#Compute final attributes, given the theme:
#Assertion: no field in result will equal "nothing".
#TODO: Obtain other defaults from Theme
function WfrmAttributes(t::Theme, la::LineAttributes, ga::GlyphAttributes;
	resolvecolors::Bool = true)
	local linestyle, glyphlinecolor
	haslinestyle = (la.style != nothing)
	hasglyph = ga.shape != :none #Alt w/nothing: (ga.shape != nothing)
	hasglyphcolor = (ga.color != nothing)

	linewidth = (nothing == la.width) ? (1) : la.width
	linecolor = (nothing == la.color) ? (:default) : la.color

	glyphshape = hasglyph ? ga.shape : (:none)
	glyphsize = (nothing == ga.size) ? (1) : ga.size

	glyphfillcolor = hasglyphcolor ? ga.color : (:transparent)

	if hasglyph && !haslinestyle
		linestyle = :none
	elseif !haslinestyle
		linestyle = :solid
	else
		linestyle = la.style
	end

	if hasglyph && hasglyphcolor
		glyphlinecolor = glyphfillcolor
	else
		glyphlinecolor = linecolor #Needs something
	end

	if resolvecolors
		linecolor = getcolor(t.colorscheme, linecolor)
		glyphlinecolor = getcolor(t.colorscheme, glyphlinecolor)
		glyphfillcolor = getcolor(t.colorscheme, glyphfillcolor)
	end
	return WfrmAttributes(linestyle, linewidth, linecolor,
		glyphshape, glyphsize, glyphlinecolor, glyphfillcolor
	)
end

#Compute final, concrete values for marker lines:
function resolve_markerline(t::Theme, la::LineAttributes)
	linestyle = (nothing == la.style) ? (:solid) : la.style
	linewidth = (nothing == la.width) ? (1) : la.width
	linecolor = (nothing == la.color) ? (:default) : la.color
	linecolor = getcolor(t.colorscheme, linecolor)
	return LineAttributes(style=linestyle, width=linewidth, color=linecolor)
end

#Last line
