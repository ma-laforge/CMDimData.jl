#EasyPlot Tools to assist with themes
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
typealias ColorRef Union{Symbol, Int, Colorant}

#Low-level waveform attributes (compared to LineAttributes & GlyphAttributes)
#NOTE: line & glyph values are "untangled" here.
type WfrmAttributes
	linestyle::Symbol
	linewidth::Float64 #[0, 10]
	linecolor::ColorRef

	glyphshape::Symbol
	glyphsize::Float64 #[0, 10]
	glyphlinecolor::ColorRef
	#glyphlinewidth::Float64 #Use linewidth
	glyphfillcolor::ColorRef
end


#==Selecting colors
===============================================================================#
getcolor(::Void, v) = getcolor(COLORSCHEME_DEFAULT, v) #If no theme selected
#getcolor(t::Theme, v) = getcolor(t.colorscheme, v)


#==Computing final waveform attributes
===============================================================================#
#=TODO
Probably more efficient to run through this algorithm *before* calling
EasyPlot.addwfrm.  So the _addwfrm algorithms should use WfrmAttributes
=#

#Compute final attributes, given the theme:
#Assertion: no field in result will equal "nothing".
#TODO: Obtain other defaults from Theme
function WfrmAttributes(t::Theme, la::LineAttributes, ga::GlyphAttributes;
	resolvecolors::Bool = true)
	local linestyle, glyphlinecolor
	haslinestyle = (la.style != nothing)
	hasglyph = (ga.shape != nothing)
	hasglyphcolor = (ga.color != nothing)

	linewidth = (nothing == la.width)? (1): la.width
	linecolor = (nothing == la.color)? (:default): la.color

	glyphshape = hasglyph? ga.shape: (:none)
	glyphsize = (nothing == ga.size)? (1): ga.size

	glyphfillcolor = hasglyphcolor? ga.color: (:transparent)

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


#Last line
