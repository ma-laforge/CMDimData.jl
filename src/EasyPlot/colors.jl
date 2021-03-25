#EasyPlot color tools & color schemes
#-------------------------------------------------------------------------------

#Alias in case underlying code changes:
getcolor(v::Symbol) = parse(Colorant, v)


#==Types
===============================================================================#
#ColorRef that can also reference another
#Int: Pick specific color from theme/ColorScheme
#Nothing: Pick appropriate color from theme/ColorScheme (Varies with sweep value)
const ColorRef = Union{Nothing, Colorant, Int}

#TODO: Possible to use structure from Colors module?
mutable struct ColorScheme
	colors::Vector{Colorant} #Colorant: might support alpha in the future
end


#==Color scheme definitions (not to be accessed directly)
===============================================================================#
const COLORSCHEME_DEFAULT = ColorScheme([getcolor(c) for c in
	[:blue, :yellow3, :red, :cyan, :green, :magenta, :orange, :violet, :grey50]
])


#==External interface for users
===============================================================================#
const COLORSCHEME = Dict{Symbol, ColorScheme}(
	:default => COLORSCHEME_DEFAULT,
)

getcolor(s::ColorScheme, ::Nothing) = colorant"black" #TODO: something better?

#Assumes value "v" starts at 1 (not 0):
function getcolor(s::ColorScheme, v::Integer)
	idx = mod(v-1, length(s.colors)) + 1
	return s.colors[idx]
end

#Default behaviour: ignore color scheme, and get color
#Alternative: Find closest color in scheme?
function getcolor(s::ColorScheme, v::Symbol)
	dfltcolor = getcolor(s, nothing)
	if :default == v
		return dfltcolor
	end

	result = dfltcolor
	try
		result = getcolor(v)
	catch
		@info("Color not supported: $v")
	end
	return result
end

#Default behaviour: ignore color scheme, and get color
#Alternative: Find closest color in scheme?
getcolor(s::ColorScheme, v::Colorant) = v


#Last line
